# MJ Nexus 平台能力矩阵

> v0.44.0 | 更新日期：2026-06-30

本文档描述 MJ Nexus 在 iOS、Android、macOS 三端的功能覆盖情况，帮助开发者快速识别平台差异。

## 功能覆盖矩阵

| 功能模块 | iOS | Android | macOS | 说明 |
|---------|-----|---------|-------|------|
| 会话管理 | ✅ | ✅ | ✅ | 完全支持 |
| 流式推理（远程 API） | ✅ | ✅ | ✅ | OpenAI/Anthropic/Ollama |
| 流式推理（本地 FFI） | ✅ Metal | ✅ Vulkan | ✅ Metal | llama.cpp 加速 |
| 多模态图片输入 | ✅ | ✅ | ✅ | v0.43.0+ Isolate 优化 |
| Function Calling（远程） | ✅ | ✅ | ✅ | OpenAI tools / Anthropic tool_use |
| Function Calling（本地 FFI） | ✅ | ✅ | ✅ | v0.44.0 多模板 FC |
| MCP 工具调用 | ⚠️ 仅 In-App | ⚠️ 仅 In-App | ✅ 全模式 | 移动端不支持 npx/node 子进程 |
| MCP 工具调用可视化 | ✅ | ✅ | ✅ | v0.43.0 McpToolCallCard |
| Realtime Voice | ✅ | ✅ | ✅ | CosyVoice/FishAudio |
| ASR 语音识别 | ✅ | ✅ | ✅ | Whisper.cpp |
| TTS 语音合成 | ✅ | ✅ | ✅ | 多引擎支持 |
| 记忆宫殿 | ✅ | ✅ | ✅ | Drift 本地数据库 |
| RAG 知识库 | ✅ | ✅ | ✅ | 向量检索 |
| 模型市场 | ✅ | ✅ | ✅ | ModelScope/HuggingFace 下载 |
| 上下文压缩 | ✅ | ✅ | ✅ | 智能压缩 + LLM 摘要 |
| 网络搜索 | ✅ | ✅ | ✅ | Tavily/DuckDuckGo/Wikipedia |
| 深度研究模式 | ✅ | ✅ | ✅ | v0.42.0+ |
| 项目/工作区 | ✅ | ✅ | ✅ | v0.42.0+ |
| LRU 模型缓存 | ✅ | ✅ | ✅ | v0.44.0 容量 2 |
| 流式取消 + 错误重试 | ✅ | ✅ | ✅ | v0.44.0 StreamController |

## 平台限制说明

### iOS / Android 移动端限制

1. **MCP 子进程模式不可用**：移动端不支持 `npx`/`node`/`uvx` 等外部命令，MCP 服务器仅支持：
   - In-App Dart MCP Server（推荐）：纯 Dart 实现，无需子进程
   - Streamable HTTP MCP：远程服务
   - WebSocket MCP：远程服务（向后兼容）

2. **文件系统访问受限**：
   - iOS：App Sandbox 限制，需通过 Files App 或分享扩展
   - Android：Scoped Storage 限制，需通过 SAF
   - macOS：需用户授权目录访问（Security-Scoped Bookmark）

3. **内存限制**：
   - iOS：通常 1-2GB 可用内存，建议模型 ≤ 3B Q4
   - Android：因设备而异，建议模型 ≤ 7B Q4
   - macOS：通常 8GB+ 可用内存

### macOS 桌面端优势

1. **全模式 MCP 支持**：支持 stdio 子进程模式（npx/node/python）
2. **大模型支持**：可加载 13B+ 参数模型（Metal 加速）
3. **多窗口支持**：可同时打开多个会话窗口

## 平台特定代码路径

| 模块 | 文件路径 | 说明 |
|------|---------|------|
| 平台抽象 | `lib/core/platform/platform_utils.dart` | 统一平台判断门面 |
| 设备能力 | `lib/core/platform/models/device_capabilities.dart` | 内存分档 + 上下文大小推荐 |
| GPU 加速 | `lib/core/platform/acceleration/` | Metal/CUDA 双加速器 |
| 硬件检测 | `lib/core/services/hardware_*.dart` | RAM/CPU/GPU 探测 |
| 库加载 | `lib/core/services/llama_library_loader.dart` | 动态加载 native llama 库 |
| 沙盒 | `lib/core/engines/sandbox/` | llama.cpp 沙盒执行环境 |

## 已知不支持的功能

| 功能 | 平台 | 原因 | 替代方案 |
|------|------|------|---------|
| MCP stdio 子进程 | iOS/Android | 系统不支持 npx/node 命令 | In-App Dart MCP Server |
| CUDA 加速 | iOS/macOS | 仅 NVIDIA GPU 支持 | Metal 加速 |
| Vulkan 加速 | iOS/macOS | 仅 Android/Windows/Linux 支持 | Metal 加速 |
| Windows/Linux 构建 | 当前版本 | pubspec 已声明平台，但未验证 | 使用 macOS/iOS/Android |

## 编译验证状态

| 平台 | 验证状态 | 产物 | 大小 |
|------|---------|------|------|
| iOS | ✅ v0.44.0 验证 | MJ_Nexus_v0.44.0.ipa | ~54MB |
| macOS | 🔄 待验证 | MJ_Nexus.app | - |
| Android | 🔄 待验证 | app-release.apk | - |

---

**注意**：本文档随版本更新维护。新增功能时请同步更新此矩阵。
