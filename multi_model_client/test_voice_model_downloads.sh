#!/bin/bash
# ASR/TTS 模型下载地址测试脚本 (v2 - 使用 Range GET)
# 验证国内主源（hf-mirror.com）和国外备源（huggingface.co）的有效性

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

# 测试函数：使用 Range GET (下载 1 字节) 检查 URL
test_url() {
    local url=$1
    local label=$2
    local timeout=15

    # Range: bytes=0-0 仅下载 1 字节，避免大文件下载，-w 输出 HTTP 码
    local code
    code=$(curl -s -o /dev/null -w "%{http_code}" -L \
        -H "Range: bytes=0-0" \
        --max-time $timeout \
        -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
        "$url" 2>/dev/null || echo "000")

    if [ "$code" = "200" ] || [ "$code" = "206" ] || [ "$code" = "302" ] || [ "$code" = "301" ]; then
        echo -e "${GREEN}✅ $label${NC} → HTTP $code"
        PASS=$((PASS+1))
        return 0
    elif [ "$code" = "000" ]; then
        echo -e "${YELLOW}⚠️  $label${NC} → 连接超时/失败"
        WARN=$((WARN+1))
        return 1
    else
        echo -e "${RED}❌ $label${NC} → HTTP $code"
        FAIL=$((FAIL+1))
        return 1
    fi
}

echo "================================================"
echo "  ASR/TTS 模型下载地址测试 (v2)"
echo "  测试方式: HTTP Range GET (下载 1 字节验证)"
echo "  主源: hf-mirror.com (国内)"
echo "  备源: huggingface.co (国外)"
echo "================================================"
echo

# ─────────────────────────────────────────────────
# ASR 模型 (测试每个模型的第一个文件)
# ─────────────────────────────────────────────────
echo "═══ ASR 模型 (7 个) ═══"

test_url "https://hf-mirror.com/csukuangfj/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17/resolve/main/model.int8.onnx" \
         "ASR-SenseVoice-int8 (主源)"
test_url "https://huggingface.co/csukuangfj/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17/resolve/main/model.int8.onnx" \
         "ASR-SenseVoice-int8 (备源)"

test_url "https://hf-mirror.com/csukuangfj/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17/resolve/main/model.onnx" \
         "ASR-SenseVoice (主源)"
test_url "https://huggingface.co/csukuangfj/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17/resolve/main/model.onnx" \
         "ASR-SenseVoice (备源)"

test_url "https://hf-mirror.com/csukuangfj/sherpa-onnx-whisper-tiny.en/resolve/main/tiny.en-decoder.int8.onnx" \
         "ASR-Whisper-tiny-en (主源)"
test_url "https://huggingface.co/csukuangfj/sherpa-onnx-whisper-tiny.en/resolve/main/tiny.en-decoder.int8.onnx" \
         "ASR-Whisper-tiny-en (备源)"

test_url "https://hf-mirror.com/csukuangfj/sherpa-onnx-whisper-tiny/resolve/main/tiny-decoder.int8.onnx" \
         "ASR-Whisper-tiny (主源)"
test_url "https://huggingface.co/csukuangfj/sherpa-onnx-whisper-tiny/resolve/main/tiny-decoder.int8.onnx" \
         "ASR-Whisper-tiny (备源)"

test_url "https://hf-mirror.com/csukuangfj/sherpa-onnx-whisper-base.en/resolve/main/base.en-decoder.int8.onnx" \
         "ASR-Whisper-base-en (主源)"
test_url "https://huggingface.co/csukuangfj/sherpa-onnx-whisper-base.en/resolve/main/base.en-decoder.int8.onnx" \
         "ASR-Whisper-base-en (备源)"

test_url "https://hf-mirror.com/csukuangfj/sherpa-onnx-paraformer-zh-small-2024-03-09/resolve/main/model.int8.onnx" \
         "ASR-Paraformer-small (主源)"
test_url "https://huggingface.co/csukuangfj/sherpa-onnx-paraformer-zh-small-2024-03-09/resolve/main/model.int8.onnx" \
         "ASR-Paraformer-small (备源)"

test_url "https://hf-mirror.com/csukuangfj/sherpa-onnx-paraformer-zh-2024-03-09/resolve/main/model.int8.onnx" \
         "ASR-Paraformer-int8 (主源)"
test_url "https://huggingface.co/csukuangfj/sherpa-onnx-paraformer-zh-2024-03-09/resolve/main/model.int8.onnx" \
         "ASR-Paraformer-int8 (备源)"

echo
echo "═══ TTS 模型 (9 个) ═══"

test_url "https://hf-mirror.com/csukuangfj/vits-melo-tts-zh_en/resolve/main/model.onnx" \
         "TTS-MeloTTS-zh-en (主源)"
test_url "https://huggingface.co/csukuangfj/vits-melo-tts-zh_en/resolve/main/model.onnx" \
         "TTS-MeloTTS-zh-en (备源)"

test_url "https://hf-mirror.com/csukuangfj/vits-zh-hf-keqing/resolve/main/keqing.onnx" \
         "TTS-VITS-Keqing (主源)"
test_url "https://huggingface.co/csukuangfj/vits-zh-hf-keqing/resolve/main/keqing.onnx" \
         "TTS-VITS-Keqing (备源)"

test_url "https://hf-mirror.com/csukuangfj/vits-zh-hf-echo/resolve/main/echo.onnx" \
         "TTS-VITS-Echo (主源)"
test_url "https://huggingface.co/csukuangfj/vits-zh-hf-echo/resolve/main/echo.onnx" \
         "TTS-VITS-Echo (备源)"

test_url "https://hf-mirror.com/csukuangfj/vits-zh-hf-eula/resolve/main/eula.onnx" \
         "TTS-VITS-Eula (主源)"
test_url "https://huggingface.co/csukuangfj/vits-zh-hf-eula/resolve/main/eula.onnx" \
         "TTS-VITS-Eula (备源)"

test_url "https://hf-mirror.com/csukuangfj/vits-zh-hf-bronya/resolve/main/bronya.onnx" \
         "TTS-VITS-Bronya (主源)"
test_url "https://huggingface.co/csukuangfj/vits-zh-hf-bronya/resolve/main/bronya.onnx" \
         "TTS-VITS-Bronya (备源)"

test_url "https://hf-mirror.com/csukuangfj/vits-zh-aishell3/resolve/main/vits-aishell3.onnx" \
         "TTS-VITS-AiShell3 (主源)"
test_url "https://huggingface.co/csukuangfj/vits-zh-aishell3/resolve/main/vits-aishell3.onnx" \
         "TTS-VITS-AiShell3 (备源)"

test_url "https://hf-mirror.com/csukuangfj/vits-cantonese-hf-xiaomaiiwn/resolve/main/vits-cantonese-hf-xiaomaiiwn.onnx" \
         "TTS-VITS-Cantonese (主源)"
test_url "https://huggingface.co/csukuangfj/vits-cantonese-hf-xiaomaiiwn/resolve/main/vits-cantonese-hf-xiaomaiiwn.onnx" \
         "TTS-VITS-Cantonese (备源)"

test_url "https://hf-mirror.com/csukuangfj/vits-melo-tts-en/resolve/main/model.onnx" \
         "TTS-MeloTTS-en (主源)"
test_url "https://huggingface.co/csukuangfj/vits-melo-tts-en/resolve/main/model.onnx" \
         "TTS-MeloTTS-en (备源)"

test_url "https://hf-mirror.com/csukuangfj/vits-piper-en_US-ljspeech-medium/resolve/main/en_US-ljspeech-medium.onnx" \
         "TTS-VITS-Piper-EN (主源)"
test_url "https://huggingface.co/csukuangfj/vits-piper-en_US-ljspeech-medium/resolve/main/en_US-ljspeech-medium.onnx" \
         "TTS-VITS-Piper-EN (备源)"

echo
echo "================================================"
echo "  测试结果汇总"
echo "================================================"
echo -e "  ${GREEN}通过: $PASS${NC}"
echo -e "  ${RED}失败: $FAIL${NC}"
echo -e "  ${YELLOW}警告 (超时): $WARN${NC}"
echo "  总计: $((PASS+FAIL+WARN))"
echo "================================================"

if [ $FAIL -eq 0 ] && [ $PASS -gt 0 ]; then
    echo -e "${GREEN}✅ 所有模型地址验证通过，可用于后续对接工作${NC}"
    exit 0
elif [ $PASS -gt $((PASS+FAIL+WARN/2)) ]; then
    echo -e "${YELLOW}⚠️  大部分地址可用，少量失败/超时${NC}"
    exit 0
else
    echo -e "${RED}❌ 多地址不可用，请检查网络或仓库状态${NC}"
    exit 1
fi
