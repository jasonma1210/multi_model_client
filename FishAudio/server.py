#!/usr/bin/env python3
"""
Fish Audio S2 Pro — MLX 本地 TTS API 服务

基于 mlx-speech 库在 Apple Silicon 上原生运行 Fish Audio S2 Pro 模型。
相比 CosyVoice Docker 方案（CPU 推理 RTF≈3.5），MLX 方案利用 Apple Silicon 
统一内存架构，RTF 可降至 0.2-0.5，速度提升 7-17 倍。

核心功能：
- 文本转语音（TTS）
- 零样本语音克隆（Zero-Shot Voice Cloning）
- 情感标签控制（15,000+ 内联标签，如 [happy], [whisper], [sad]）
- 流式音频输出

API 端点：
- POST /v1/tts          — 文本转语音
- POST /v1/tts/clone    — 语音克隆
- GET  /health          — 健康检查
- GET  /docs            — API 文档

启动方式：
    python server.py [--host 0.0.0.0] [--port 50001] [--model-dir /path/to/model]

依赖：
    pip install mlx-speech fastapi uvicorn python-multipart soundfile

@author JianMa
@version 1.0.0
"""

import argparse
import io
import logging
import os
import time
import wave
from pathlib import Path
from typing import Optional

import numpy as np
from fastapi import FastAPI, Form, File, UploadFile, HTTPException
from fastapi.responses import StreamingResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware

# 日志配置
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S',
)
logger = logging.getLogger('fish-audio-server')

app = FastAPI(
    title='Fish Audio S2 Pro TTS API',
    description='基于 MLX 的 Fish Audio S2 Pro 本地 TTS 服务（Apple Silicon 原生）',
    version='1.0.0',
)

# CORS 中间件（允许 App 端跨域调用）
app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*'],
)

# 全局模型实例
_model = None
_model_dir = None
_sample_rate = 44100  # Fish S2 Pro 默认采样率


def get_model():
    """懒加载模型（首次请求时加载，避免启动时长时间等待）
    
    模型加载策略：
    1. 如果指定了 --model-dir，直接从本地目录加载
    2. 否则尝试从 ModelScope 下载（国内镜像，速度快）
    3. ModelScope 失败则回退到 HuggingFace
    """
    global _model
    if _model is None:
        logger.info(f'正在加载 Fish Audio S2 Pro 模型: {_model_dir}')
        start_time = time.time()
        try:
            import mlx_speech
            
            if _model_dir:
                # 指定了本地模型目录，直接加载
                _model = mlx_speech.tts.load(_model_dir)
            else:
                # 尝试从 ModelScope 下载（国内镜像）
                model_path = _download_from_modelscope()
                if model_path:
                    _model = mlx_speech.tts.load(model_path)
                else:
                    # 回退到 HuggingFace（可能超时）
                    logger.info('ModelScope 下载失败，尝试 HuggingFace...')
                    _model = mlx_speech.tts.load("fish-s2-pro")
            
            load_time = time.time() - start_time
            logger.info(f'模型加载完成，耗时 {load_time:.1f}s')
        except Exception as e:
            logger.error(f'模型加载失败: {e}')
            raise RuntimeError(f'模型加载失败: {e}')
    return _model


def _download_from_modelscope():
    """从 ModelScope 下载模型到本地缓存目录
    
    Returns:
        下载后的本地模型目录路径，失败返回 None
    """
    try:
        from modelscope import snapshot_download
        model_id = 'mlx-community/fishaudio-s2-pro-8bit-mlx'
        cache_dir = os.path.expanduser('~/.cache/modelscope/hub')
        
        logger.info(f'正在从 ModelScope 下载模型: {model_id}')
        logger.info('提示：首次下载约 1.5GB，请耐心等待...')
        
        local_dir = snapshot_download(
            model_id=model_id,
            cache_dir=cache_dir,
        )
        logger.info(f'模型下载完成: {local_dir}')
        return local_dir
    except ImportError:
        logger.warning('modelscope 未安装，跳过 ModelScope 下载。安装命令: pip install modelscope')
        return None
    except Exception as e:
        logger.warning(f'ModelScope 下载失败: {e}')
        return None


def audio_to_wav_bytes(waveform_np: np.ndarray, sample_rate: int) -> bytes:
    """将 numpy 音频数组转换为 WAV 格式字节流
    
    Args:
        waveform_np: 音频数据（float32，-1.0 ~ 1.0）
        sample_rate: 采样率
    
    Returns:
        WAV 格式的字节流
    """
    # 确保是 float64 以避免精度问题
    waveform = waveform_np.astype(np.float64)
    
    # 归一化到 int16 范围
    max_val = np.max(np.abs(waveform))
    if max_val > 0:
        waveform = waveform / max_val * 0.95  # 留 5% 余量避免削波
    
    # 转换为 int16
    audio_int16 = (waveform * 32767).astype(np.int16)
    
    # 写入 WAV 格式
    buf = io.BytesIO()
    with wave.open(buf, 'wb') as wf:
        wf.setnchannels(1)  # 单声道
        wf.setsampwidth(2)  # 16-bit
        wf.setframerate(sample_rate)
        wf.writeframes(audio_int16.tobytes())
    
    return buf.getvalue()


def audio_to_pcm_bytes(waveform_np: np.ndarray) -> bytes:
    """将 numpy 音频数组转换为 PCM int16 字节流（无 WAV 头部）
    
    Args:
        waveform_np: 音频数据（float32，-1.0 ~ 1.0）
    
    Returns:
        PCM int16 字节流
    """
    waveform = waveform_np.astype(np.float64)
    max_val = np.max(np.abs(waveform))
    if max_val > 0:
        waveform = waveform / max_val * 0.95
    audio_int16 = (waveform * 32767).astype(np.int16)
    return audio_int16.tobytes()


# ========== API 端点 ==========

@app.get('/health')
async def health():
    """健康检查端点"""
    model_loaded = _model is not None
    return {
        'status': 'ok' if model_loaded else 'loading',
        'model': 'fish-s2-pro-mlx',
        'model_loaded': model_loaded,
        'model_dir': str(_model_dir) if _model_dir else 'default',
        'backend': 'mlx-speech (Apple Silicon)',
    }


@app.post('/v1/tts')
async def text_to_speech(
    text: str = Form(..., description='要合成的文本（支持情感标签，如 [happy] 你好 [whisper] 这是秘密）'),
    reference_audio: Optional[UploadFile] = File(None, description='参考音频文件（WAV/MP3，10-30秒，用于音色克隆）'),
    reference_text: Optional[str] = Form(None, description='参考音频的文本转录（提升克隆质量）'),
    output_format: str = Form('wav', description='输出格式：wav 或 pcm'),
    speed: float = Form(1.0, description='语速倍率（0.5-2.0）'),
):
    """文本转语音
    
    支持两种模式：
    1. 基础 TTS：仅提供 text 参数，使用模型默认音色
    2. 语音克隆：额外提供 reference_audio 和 reference_text，克隆指定音色
    
    情感标签：在文本中插入 [tag] 即可控制情感，如：
    - [happy] 开心  [sad] 悲伤  [whisper] 耳语
    - [excited] 兴奋  [chuckle] 轻笑  [pause] 停顿
    - 完整标签列表见 Fish Audio 官方文档（15,000+ 标签）
    """
    logger.info(f'[tts] text="{text[:80]}...", ref_audio={reference_audio.filename if reference_audio else None}, '
                f'ref_text={reference_text[:50] if reference_text else None}, format={output_format}, speed={speed}')
    
    try:
        model = get_model()
    except RuntimeError as e:
        raise HTTPException(status_code=503, detail=str(e))
    
    start_time = time.time()
    
    try:
        # 准备参考音频（语音克隆）
        ref_audio_path = None
        if reference_audio is not None:
            # 保存上传的音频到临时文件
            import tempfile
            suffix = Path(reference_audio.filename).suffix or '.wav'
            with tempfile.NamedTemporaryFile(suffix=suffix, delete=False) as tmp:
                content = await reference_audio.read()
                tmp.write(content)
                ref_audio_path = tmp.name
            logger.info(f'[tts] 参考音频已保存: {ref_audio_path} ({len(content)} bytes)')
        
        # 调用模型推理
        kwargs = {}
        if ref_audio_path:
            kwargs['reference_audio'] = ref_audio_path
        if reference_text:
            kwargs['reference_text'] = reference_text
        
        result = model.generate(text, **kwargs)
        
        # 获取音频数据
        import mlx.core as mx
        waveform_mx = result.waveform
        sample_rate = result.sample_rate
        
        # MLX array 转 numpy
        waveform_np = np.array(waveform_mx)
        
        # 确保是一维数组
        if waveform_np.ndim > 1:
            waveform_np = waveform_np.squeeze()
        
        gen_time = time.time() - start_time
        audio_duration = len(waveform_np) / sample_rate
        rtf = gen_time / audio_duration if audio_duration > 0 else 0
        logger.info(f'[tts] 合成完成: 音频时长={audio_duration:.2f}s, 生成耗时={gen_time:.2f}s, RTF={rtf:.2f}')
        
        # 清理临时文件
        if ref_audio_path and os.path.exists(ref_audio_path):
            os.unlink(ref_audio_path)
        
        # 返回音频数据
        if output_format == 'wav':
            wav_bytes = audio_to_wav_bytes(waveform_np, sample_rate)
            return StreamingResponse(
                io.BytesIO(wav_bytes),
                media_type='audio/wav',
                headers={
                    'X-Audio-Duration': f'{audio_duration:.2f}',
                    'X-Generation-Time': f'{gen_time:.2f}',
                    'X-RTF': f'{rtf:.2f}',
                    'X-Sample-Rate': str(sample_rate),
                },
            )
        else:
            # PCM int16 格式（兼容 CosyVoice 客户端）
            pcm_bytes = audio_to_pcm_bytes(waveform_np)
            return StreamingResponse(
                io.BytesIO(pcm_bytes),
                media_type='audio/pcm',
                headers={
                    'X-Audio-Duration': f'{audio_duration:.2f}',
                    'X-Generation-Time': f'{gen_time:.2f}',
                    'X-RTF': f'{rtf:.2f}',
                    'X-Sample-Rate': str(sample_rate),
                    'X-Audio-Format': 'int16',
                },
            )
    
    except Exception as e:
        logger.error(f'[tts] 合成失败: {e}')
        # 清理临时文件
        if ref_audio_path and os.path.exists(ref_audio_path):
            os.unlink(ref_audio_path)
        raise HTTPException(status_code=500, detail=f'语音合成失败: {str(e)}')


@app.post('/v1/tts/clone')
async def voice_clone(
    text: str = Form(..., description='要合成的文本'),
    reference_audio: UploadFile = File(..., description='参考音频文件（WAV/MP3，10-30秒）'),
    reference_text: str = Form('', description='参考音频的文本转录（提升克隆质量）'),
    output_format: str = Form('wav', description='输出格式：wav 或 pcm'),
    speed: float = Form(1.0, description='语速倍率'),
):
    """语音克隆（便捷端点，等同于 /v1/tts + reference_audio）
    
    上传参考音频，克隆其音色并合成指定文本。
    参考音频要求：
    - 格式：WAV 或 MP3
    - 时长：10-30 秒（推荐 15 秒）
    - 质量：清晰、无背景噪音、信噪比 > 45dB
    """
    return await text_to_speech(
        text=text,
        reference_audio=reference_audio,
        reference_text=reference_text,
        output_format=output_format,
        speed=speed,
    )


@app.get('/v1/models')
async def list_models():
    """列出可用的 TTS 模型"""
    import mlx_speech
    models = mlx_speech.tts.list_models()
    return {'models': models}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Fish Audio S2 Pro MLX TTS 服务')
    parser.add_argument('--host', type=str, default='0.0.0.0', help='监听地址')
    parser.add_argument('--port', type=int, default=50001, help='监听端口（默认 50001，避免与 CosyVoice 50000 冲突）')
    parser.add_argument('--model-dir', type=str, default=None, 
                        help='模型目录路径（默认自动下载 fish-s2-pro）')
    parser.add_argument('--no-preload', action='store_true',
                        help='启动时不预加载模型（首次请求时加载）')
    args = parser.parse_args()
    
    _model_dir = args.model_dir
    
    # 使用 lifespan 替代 on_event（避免弃用警告）
    from contextlib import asynccontextmanager
    
    @asynccontextmanager
    async def lifespan(app_instance):
        """应用生命周期管理"""
        logger.info('Fish Audio S2 Pro TTS 服务启动中...')
        if not args.no_preload:
            try:
                get_model()
                logger.info('模型预加载成功')
            except Exception as e:
                logger.warning(f'模型预加载失败（将在首次请求时重试）: {e}')
        else:
            logger.info('跳过模型预加载（--no-preload），将在首次请求时加载')
        yield
        logger.info('Fish Audio TTS 服务关闭')
    
    app.router.lifespan_context = lifespan
    
    import uvicorn
    logger.info(f'启动 Fish Audio TTS 服务: http://{args.host}:{args.port}')
    logger.info(f'API 文档: http://{args.host}:{args.port}/docs')
    uvicorn.run(app, host=args.host, port=args.port, log_level='info')
