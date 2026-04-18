#!/usr/bin/env python3
"""
VoxCPM2 TTS Server for LLM Studio
基于 FastAPI 的 HTTP API 服务，支持流式音频输出

安装依赖:
    pip install voxcpm fastapi uvicorn python-multipart aiofiles soundfile numpy

启动服务:
    python voxcpm2_server.py --port 8080 --model openbmb/VoxCPM2

API 端点:
    POST /tts - 文本转语音
    GET  /voices - 获取可用音色列表
    POST /clone - 声音克隆
"""

import argparse
import base64
import io
import json
import logging
import os
import tempfile
import threading
from typing import Optional

import numpy as np
import soundfile as sf
from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse, JSONResponse
from pydantic import BaseModel

# 配置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 全局变量
app = FastAPI(title="VoxCPM2 TTS Server", version="1.0.0")
model = None
model_lock = threading.Lock()

# CORS 配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class TTSRequest(BaseModel):
    text: str
    voice: Optional[str] = "default"
    speed: Optional[float] = 1.0
    temperature: Optional[float] = 1.0
    cfg_value: Optional[float] = 2.0
    inference_timesteps: Optional[int] = 10


class CloneRequest(BaseModel):
    text: str
    reference_audio: str  # base64 编码的音频数据
    speed: Optional[float] = 1.0
    cfg_value: Optional[float] = 2.0


# 内置音色列表
PRESET_VOICES = {
    "default": {
        "name": "默认音色",
        "description": "中性自然音色",
        "prompt": None,
    },
    "gentle_woman": {
        "name": "温柔女性",
        "description": "温柔甜美的女性声音",
        "prompt": "A young woman, gentle and sweet voice",
    },
    "mature_man": {
        "name": "成熟男性",
        "description": "成熟稳重的男性声音",
        "prompt": "A middle-aged man, mature and steady voice",
    },
    "young_boy": {
        "name": "年轻男孩",
        "description": "活泼可爱的男孩声音",
        "prompt": "A young boy, lively and cute voice",
    },
    "young_girl": {
        "name": "年轻女孩",
        "description": "活泼可爱的女孩声音",
        "prompt": "A young girl, lively and sweet voice",
    },
    "elderly_woman": {
        "name": "老年女性",
        "description": "慈祥温和的老年女性声音",
        "prompt": "An elderly woman, kind and gentle voice",
    },
    "professional": {
        "name": "专业播音",
        "description": "新闻播音员风格",
        "prompt": "A professional news anchor voice, clear and authoritative",
    },
    "friendly": {
        "name": "友好客服",
        "description": "亲切友好的客服声音",
        "prompt": "A friendly customer service representative voice, warm and helpful",
    },
}


def load_model(model_name: str = "openbmb/VoxCPM2"):
    """加载 VoxCPM2 模型"""
    global model
    
    if model is not None:
        return model
    
    logger.info(f"正在加载 VoxCPM2 模型: {model_name}")
    
    try:
        from voxcpm import VoxCPM
        
        model = VoxCPM.from_pretrained(
            model_name,
            load_denoiser=False,
        )
        logger.info("VoxCPM2 模型加载成功!")
        return model
    except Exception as e:
        logger.error(f"模型加载失败: {e}")
        raise


@app.on_event("startup")
async def startup():
    """启动时自动加载模型"""
    try:
        load_model()
    except Exception as e:
        logger.warning(f"启动时模型加载失败: {e}，将在首次请求时重试")


@app.get("/")
async def root():
    """健康检查"""
    return {
        "status": "ok",
        "model": "VoxCPM2",
        "version": "1.0.0",
        "sample_rate": 48000,
        "voices": list(PRESET_VOICES.keys()),
    }


@app.get("/health")
async def health():
    """健康检查"""
    return {"status": "healthy", "model_loaded": model is not None}


@app.get("/voices")
async def get_voices():
    """获取可用音色列表"""
    return {
        "voices": PRESET_VOICES,
        "total": len(PRESET_VOICES),
    }


@app.post("/tts")
async def text_to_speech(request: TTSRequest):
    """
    文本转语音 API
    
    请求体:
    {
        "text": "要转换的文本",
        "voice": "音色名称 (可选, 默认 default)",
        "speed": "语速 (可选, 默认 1.0)",
        "cfg_value": "CFG 值 (可选, 默认 2.0)",
        "inference_timesteps": "推理步数 (可选, 默认 10)"
    }
    
    返回: audio/wav 格式的音频流
    """
    if model is None:
        try:
            load_model()
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"模型加载失败: {str(e)}")
    
    if not request.text or len(request.text.strip()) == 0:
        raise HTTPException(status_code=400, detail="文本不能为空")
    
    # 获取音色提示
    voice_prompt = None
    if request.voice and request.voice in PRESET_VOICES:
        voice_prompt = PRESET_VOICES[request.voice].get("prompt")
    
    # 构建文本
    text = request.text
    if voice_prompt:
        text = f"({voice_prompt}){text}"
    
    try:
        with model_lock:
            # 生成音频
            wav = model.generate(
                text=text,
                cfg_value=request.cfg_value,
                inference_timesteps=request.inference_timesteps,
            )
        
        # 转换为 WAV 格式
        buffer = io.BytesIO()
        sf.write(buffer, wav, model.tts_model.sample_rate, format="WAV")
        buffer.seek(0)
        
        return StreamingResponse(
            buffer,
            media_type="audio/wav",
            headers={
                "Content-Disposition": f'attachment; filename="tts_{hash(text)}.wav"',
                "X-Voice": request.voice or "default",
                "X-Sample-Rate": str(model.tts_model.sample_rate),
            },
        )
    except Exception as e:
        logger.error(f"TTS 生成失败: {e}")
        raise HTTPException(status_code=500, detail=f"音频生成失败: {str(e)}")


@app.post("/tts/stream")
async def text_to_speech_stream(request: TTSRequest):
    """
    流式文本转语音 API
    
    流式返回音频块，适合长文本的实时播放
    """
    if model is None:
        try:
            load_model()
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"模型加载失败: {str(e)}")
    
    if not request.text or len(request.text.strip()) == 0:
        raise HTTPException(status_code=400, detail="文本不能为空")
    
    # 获取音色提示
    voice_prompt = None
    if request.voice and request.voice in PRESET_VOICES:
        voice_prompt = PRESET_VOICES[request.voice].get("prompt")
    
    # 构建文本
    text = request.text
    if voice_prompt:
        text = f"({voice_prompt}){text}"
    
    async def generate_chunks():
        """异步生成音频块"""
        try:
            with model_lock:
                chunks = list(model.generate_streaming(text=text))
            
            # 合并所有块
            wav = np.concatenate(chunks)
            
            # 写入临时文件
            with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
                sf.write(f, wav, model.tts_model.sample_rate, format="WAV")
                temp_path = f.name
            
            # 读取并删除
            with open(temp_path, "rb") as f:
                yield f.read()
            os.unlink(temp_path)
            
        except Exception as e:
            logger.error(f"流式生成失败: {e}")
            error_msg = json.dumps({"error": str(e)}).encode()
            yield error_msg
    
    return StreamingResponse(
        generate_chunks(),
        media_type="audio/wav",
        headers={
            "Content-Disposition": f'attachment; filename="tts_stream.wav"',
            "X-Voice": request.voice or "default",
            "X-Sample-Rate": str(model.tts_model.sample_rate),
        },
    )


@app.post("/clone")
async def voice_clone(
    text: str = File(...),
    reference_audio: UploadFile = File(...),
    cfg_value: float = Form(2.0),
):
    """
    声音克隆 API
    
    上传参考音频和文本，返回克隆声音的语音
    """
    if model is None:
        try:
            load_model()
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"模型加载失败: {str(e)}")
    
    try:
        # 保存上传的音频
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
            content = await reference_audio.read()
            f.write(content)
            temp_path = f.name
        
        try:
            with model_lock:
                # 使用参考音频克隆
                wav = model.generate(
                    text=text,
                    reference_wav_path=temp_path,
                    cfg_value=cfg_value,
                )
            
            # 转换为 WAV 格式
            buffer = io.BytesIO()
            sf.write(buffer, wav, model.tts_model.sample_rate, format="WAV")
            buffer.seek(0)
            
            return StreamingResponse(
                buffer,
                media_type="audio/wav",
                headers={"Content-Disposition": 'attachment; filename="cloned.wav"'},
            )
        finally:
            # 清理临时文件
            if os.path.exists(temp_path):
                os.unlink(temp_path)
                
    except Exception as e:
        logger.error(f"声音克隆失败: {e}")
        raise HTTPException(status_code=500, detail=f"声音克隆失败: {str(e)}")


@app.post("/design")
async def voice_design(request: TTSRequest):
    """
    语音设计 API
    
    通过自然语言描述创建全新声音
    """
    if model is None:
        try:
            load_model()
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"模型加载失败: {str(e)}")
    
    if not request.text:
        raise HTTPException(status_code=400, detail="文本不能为空")
    
    # Voice Design 格式: (描述性文本)实际文本
    try:
        with model_lock:
            wav = model.generate(
                text=request.text,
                cfg_value=request.cfg_value,
                inference_timesteps=request.inference_timesteps,
            )
        
        buffer = io.BytesIO()
        sf.write(buffer, wav, model.tts_model.sample_rate, format="WAV")
        buffer.seek(0)
        
        return StreamingResponse(
            buffer,
            media_type="audio/wav",
            headers={"Content-Disposition": 'attachment; filename="voice_design.wav"'},
        )
    except Exception as e:
        logger.error(f"语音设计失败: {e}")
        raise HTTPException(status_code=500, detail=f"语音设计失败: {str(e)}")


def main():
    parser = argparse.ArgumentParser(description="VoxCPM2 TTS Server")
    parser.add_argument("--port", type=int, default=8080, help="服务端口")
    parser.add_argument("--host", type=str, default="0.0.0.0", help="服务地址")
    parser.add_argument("--model", type=str, default="openbmb/VoxCPM2", help="模型名称或路径")
    parser.add_argument("--reload", action="store_true", help="开发模式热重载")
    args = parser.parse_args()
    
    print(f"""
╔══════════════════════════════════════════════════════════╗
║              VoxCPM2 TTS Server v1.0.0                  ║
║                                                          ║
║  模型: {args.model:<50}  ║
║  端口: http://{args.host}:{args.port}                            ║
║                                                          ║
║  API 端点:                                              ║
║    GET  /          - 健康检查                           ║
║    GET  /health    - 服务状态                          ║
║    GET  /voices    - 可用音色列表                       ║
║    POST /tts       - 文本转语音                        ║
║    POST /tts/stream - 流式文本转语音                   ║
║    POST /clone     - 声音克隆                          ║
║    POST /design    - 语音设计                          ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
    """)
    
    import uvicorn
    uvicorn.run(
        "voxcpm2_server:app",
        host=args.host,
        port=args.port,
        reload=args.reload,
        log_level="info",
    )


if __name__ == "__main__":
    main()
