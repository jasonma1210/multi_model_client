"""
VoxCPM2 TTS Server
基于 FastAPI 的 VoxCPM2 语音合成服务

使用方法:
1. 安装依赖: pip install fastapi uvicorn voxcpm soundfile numpy
2. 运行服务: python voxcpm_server.py
3. 默认端口: 8080

API 端点:
- GET  /health        - 健康检查
- POST /tts           - 同步语音合成
- POST /tts/stream    - 流式语音合成 (返回 WAV 音频流)
"""

import os
import sys
import json
import asyncio
import numpy as np
from typing import Optional, List
from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import StreamingResponse, JSONResponse
import uvicorn
import soundfile as sf
from io import BytesIO

# 尝试导入 VoxCPM
try:
    from voxcpm import VoxCPM
    VOXCPM_AVAILABLE = True
except ImportError:
    VOXCPM_AVAILABLE = False
    print("⚠️  VoxCPM 未安装，请运行: pip install voxcpm")

app = FastAPI(title="VoxCPM2 TTS Server", version="1.0.0")

# 全局模型实例
model: Optional[VoxCPM] = None
model_loaded = False

# 音色预设
VOICE_PRESETS = {
    'default': None,
    'gentle_woman': 'A young woman, gentle and sweet voice',
    'mature_man': 'A middle-aged man, mature and steady voice',
    'young_boy': 'A young boy, lively and cute voice',
    'young_girl': 'A young girl, lively and sweet voice',
    'elderly_woman': 'An elderly woman, kind and gentle voice',
    'professional': 'A professional news anchor voice, clear and authoritative',
    'friendly': 'A friendly customer service representative voice, warm and helpful',
}


def load_model():
    """加载 VoxCPM2 模型"""
    global model, model_loaded
    
    if not VOXCPM_AVAILABLE:
        raise RuntimeError("VoxCPM 未安装")
    
    if model_loaded:
        return
    
    print("📥 正在加载 VoxCPM2 模型...")
    print("   首次运行会自动从 HuggingFace 下载模型 (~2GB)")
    
    try:
        model = VoxCPM.from_pretrained(
            "openbmb/VoxCPM2",
            load_denoiser=False,
        )
        model_loaded = True
        print("✅ VoxCPM2 模型加载成功!")
    except Exception as e:
        print(f"❌ 模型加载失败: {e}")
        raise


@app.on_event("startup")
async def startup_event():
    """服务启动时加载模型"""
    if VOXCPM_AVAILABLE:
        try:
            load_model()
        except Exception as e:
            print(f"⚠️  启动时加载模型失败: {e}")


@app.get("/health")
async def health_check():
    """健康检查"""
    return {
        "status": "ok",
        "model_loaded": model_loaded,
        "voxcpm_available": VOXCPM_AVAILABLE,
    }


@app.get("/model/status")
async def model_status():
    """模型状态"""
    return {
        "loaded": model_loaded,
        "available": VOXCPM_AVAILABLE,
    }


@app.post("/model/load")
async def load_model_endpoint():
    """手动加载模型"""
    if not VOXCPM_AVAILABLE:
        raise HTTPException(status_code=500, detail="VoxCPM 未安装")
    
    try:
        load_model()
        return {"status": "success", "message": "模型加载成功"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/tts")
async def synthesize_speech(request: Request):
    """
    同步语音合成
    
    请求体:
    {
        "text": "要合成的文本",
        "voice": "gentle_woman",  // 音色 ID
        "cfg_value": 2.0,         // CFG 强度 (0-3)
        "inference_timesteps": 10 // 推理步数 (10-50)
    }
    
    返回: WAV 音频文件
    """
    if not model_loaded:
        raise HTTPException(status_code=503, detail="模型未加载")
    
    try:
        body = await request.json()
        text = body.get("text", "")
        voice_id = body.get("voice", "default")
        cfg_value = body.get("cfg_value", 2.0)
        inference_timesteps = body.get("inference_timesteps", 10)
        
        if not text:
            raise HTTPException(status_code=400, detail="文本不能为空")
        
        # 获取音色提示
        voice_prompt = VOICE_PRESETS.get(voice_id, VOICE_PRESETS['default'])
        
        # 构造输入文本
        if voice_prompt:
            input_text = f"({voice_prompt}){text}"
        else:
            input_text = text
        
        # 生成语音
        print(f"🎤 正在合成: {text[:50]}...")
        wav = model.generate(
            text=input_text,
            cfg_value=cfg_value,
            inference_timesteps=inference_timesteps,
        )
        
        # 转换为 WAV 格式
        buffer = BytesIO()
        sf.write(buffer, wav, model.tts_model.sample_rate, format='WAV')
        buffer.seek(0)
        
        return StreamingResponse(
            buffer,
            media_type="audio/wav",
            headers={
                "Content-Disposition": "attachment; filename=tts.wav"
            }
        )
        
    except Exception as e:
        print(f"❌ 合成失败: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/tts/stream")
async def synthesize_speech_stream(request: Request):
    """
    流式语音合成 (简化版本，返回完整音频)
    
    请求体与 /tts 相同
    """
    return await synthesize_speech(request)


@app.post("/tts/voices")
async def list_voices():
    """获取可用的音色列表"""
    voices = []
    for voice_id, prompt in VOICE_PRESETS.items():
        voices.append({
            "id": voice_id,
            "name": voice_id.replace("_", " ").title(),
            "prompt": prompt or "默认音色",
        })
    return voices


@app.post("/tts/test")
async def test_tts():
    """测试语音合成"""
    if not model_loaded:
        raise HTTPException(status_code=503, detail="模型未加载")
    
    try:
        wav = model.generate(
            text="你好，这是 VoxCPM2 语音合成测试。",
            cfg_value=2.0,
            inference_timesteps=10,
        )
        
        buffer = BytesIO()
        sf.write(buffer, wav, model.tts_model.sample_rate, format='WAV')
        buffer.seek(0)
        
        return StreamingResponse(
            buffer,
            media_type="audio/wav",
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="VoxCPM2 TTS Server")
    parser.add_argument("--port", type=int, default=8080, help="服务端口")
    parser.add_argument("--host", type=str, default="0.0.0.0", help="服务地址")
    parser.add_argument("--reload", action="store_true", help="开发模式热重载")
    args = parser.parse_args()
    
    print(f"""
╔═══════════════════════════════════════════════════╗
║         VoxCPM2 TTS Server 启动中...               ║
║                                                   ║
║   访问地址: http://{args.host}:{args.port}                 ║
║   API 文档: http://{args.host}:{args.port}/docs             ║
║                                                   ║
║   端点:                                           ║
║   - GET  /health        健康检查                  ║
║   - POST /tts           语音合成                  ║
║   - POST /tts/stream    流式合成                  ║
║   - POST /tts/voices    音色列表                  ║
║   - POST /tts/test      测试合成                  ║
╚═══════════════════════════════════════════════════╝
    """)
    
    uvicorn.run(
        "voxcpm_server:app",
        host=args.host,
        port=args.port,
        reload=args.reload,
    )