# MJ Nexus v0.41.0 更新日志

**发布日期**: 2026-06-10
**版本号**: 0.41.0
**构建号**: 0.41.0

---

## 关键修复

### ASR 跨页面资源泄漏修复（闪退修复）
- **问题**: 在对话界面使用 ASR（按住说话）后，导航到灵感一瞬页面录音并点击转录，有一定概率闪退
- **根因**: `AsrInputService` 中的 `_dynamicAsrService`（含 sherpa_onnx 的 `OfflineRecognizer` 原生 C++ 对象）在录音停止后从未被释放。当灵感一瞬页面创建新的 `ASRService` + `OfflineRecognizer` 时，与未释放的旧实例产生 ONNX Runtime 进程级资源冲突，触发 C++ 层 SIGSEGV/SIGABRT 闪退
- **修复**:
  - `AsrInputService.stopRecording()` 中增加 `_dynamicAsrService?.dispose()` 和 `_dynamicAsrService = null`
  - `AsrInputService.dispose()` 中增加 `_dynamicAsrService?.dispose()`
  - 灵感一瞬转录函数中 `asr.dispose()` 移到 `finally` 块，确保异常时也释放
  - 媒体管道 `_transcribeWithASR` 中 `asrService.dispose()` 移到 `finally` 块

### 录音器资源冲突修复
- 新增 `RecorderManager` 集中管理录音器和 AVAudioSession，解决跨页面录音器冲突
- 新增 `audio_format_utils.dart` 音频格式转换工具
- `AsrInputService` 录音停止后立即释放 `_recorder`，避免 iOS 不允许两个录音器共存

## 功能增强

### TTS 服务优化
- 流式分句合成架构
- mimo 克隆音色修复（正确传递 cloneReferenceAudioPath）
- 语音克隆服务超时处理和文件验证增强

### 会话页面语音交互优化
- 会话详情页语音功能全面优化
- 实时语音页面录音器清理重构
- 灵感一瞬页面转录流程优化

## 修改的文件

| 文件 | 修改内容 |
|------|---------|
| `asr_input_service.dart` | 录音停止后释放 `_dynamicAsrService` 和 `_recorder` |
| `inspiration_page.dart` | 转录函数 `asr.dispose()` 移到 `finally` 块 |
| `media_ingestion_pipeline.dart` | `_transcribeWithASR` 中 `asrService.dispose()` 移到 `finally` 块 |
| `recorder_manager.dart` | 新增：集中管理录音器和 AVAudioSession |
| `audio_format_utils.dart` | 新增：音频格式转换工具 |
| `tts_service.dart` | 流式分句合成、mimo 克隆音色修复 |
| `voice_clone_service.dart` | 超时处理、文件验证增强 |
| `session_detail_page.dart` | 语音交互优化 |
| `realtime_voice_page.dart` | 录音器清理重构 |
| `voice_settings_page.dart` | 语音设置页面增强 |

## 安装说明

1. 将 `MJ_Nexus_v0.41.0.ipa` 传输到 iOS 设备
2. 通过 AltStore / Sideloadly / 其他工具安装
3. 首次安装需在「设置 → 通用 → VPN与设备管理」中信任开发者证书

## 已知问题

- IPA 使用开发证书签名，需通过侧载方式安装（非 App Store 分发）
- 全局 `asrService` 实例在灵感一瞬页面声明但未使用，不影响功能
