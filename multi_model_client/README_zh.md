# MJ Nexus Series:灵犀通 - 多模态 AI 助手

<p align="center">
  <img src="assets/mj_nexus_logo.png" width="120" alt="MJ Nexus Series Logo"/>
</p>

<p align="center">
  <a href="README.md">English</a> · <a href="README_zh.md">简体中文</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-0.40.0-blue" alt="版本"/>
  <img src="https://img.shields.io/badge/flutter-3.x-blue" alt="Flutter"/>
  <img src="https://img.shields.io/badge/dart-3.10.7+-blue" alt="Dart"/>
  <img src="https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20macOS-green" alt="平台"/>
  <img src="https://img.shields.io/badge/license-Private-red" alt="许可"/>
</p>

---

**MJ Nexus Series:灵犀通** 是一款功能强大的跨平台 AI 助手应用，支持本地和远程大语言模型、实时语音对话、RAG 知识库、记忆引擎和多模态推理能力。

## ✨ 核心功能

### 🤖 多模型推理引擎
- **本地模型**：通过 llama.cpp FFI (llamadart) 加载 GGUF 格式模型，支持 Metal/Vulkan GPU 加速
- **远程模型**：兼容 OpenAI / Anthropic / Ollama API
- **多模态模型**：支持 Qwen2-VL、LLaVA 视觉语言模型，自动下载 mmproj 投影仪
- **模型市场**：内置热门模型推荐，支持断点续传下载
- **GPU 崩溃防护**：多层安全策略 — 参数安全上限、崩溃标记 + 安全模式自动恢复、GGUF 文件头预验证、推理阶段 GPU→CPU 自动回退

### 🎤 语音交互系统
- **ASR 语音识别**：Whisper API + Sherpa-ONNX 本地离线方案
- **TTS 语音合成**：4 种后端 — MiMo TTS（云端）、Sherpa-ONNX（本地离线）、OpenAI TTS API、系统内置 TTS
- **语音克隆**：MiMo TTS 语音复刻 API — 录音 → 转录 → 克隆自定义音色
- **TTS 风格控制**：导演级语音控制，支持风格标签、情绪标签、导演模式、自然语言控制
- **实时语音对话**：全链路流式 ASR → LLM → TTS，支持打断

### 💬 会话管理
- **会话隔离**：每个会话独立模型、上下文和配置
- **文件夹组织**：支持会话分组、置顶、归档
- **角色人设**：10+ 种预设人设（AI 工程师、提示词工程师、女王大人、小可爱等）
- **专家技能**：30+ 位领域专家角色（设计、工程技术、市场营销、法务、金融等）
- **会话导出**：Markdown 格式导出

### 🧠 记忆与知识库
- **记忆宫殿**：四级记忆分层（即时 → 工作 → 长期 → 归档），智能权重衰减，跨会话记忆融合
- **RAG 知识库**：PDF/Word/TXT/OCR 文档解析，FTS + BM25 + 语义搜索三路混合检索
- **语义搜索**：基于 Embedding 的向量相似度搜索
- **中文分词**：jieba 集成，优化中文检索质量

### 🎨 多模态能力
- **视觉理解**：发送图片到多模态模型进行分析
- **视频理解**：视频文件理解 + 连续对话
- **OCR 识别**：Google ML Kit 原生 OCR + textify 纯 Dart OCR

### 🔌 MCP 协议支持
- **MCP 服务管理**：统一管理所有 MCP 连接
- **工具调用**：标准化 MCP 协议工具调用接口
- **服务器管理**：MCP 连接管理器和服务器管理器

### 🔒 安全与隐私
- **AES-256 加密**：数据加密存储
- **安全密钥存储**：iOS Keychain / Android Keystore
- **应用锁**：PIN 码 + 生物识别（Face ID / Touch ID）
- **隐私优先**：所有数据本地存储，无遥测

### ⚙️ 系统功能
- **数据备份**：JSON 格式导入/导出，合并/覆盖模式
- **主题切换**：暗色 / 亮色 / 跟随系统
- **多语言**：中文 / 英文（国际化）
- **macOS 沙盒**：Security-Scoped Bookmark 外部文件访问
- **新手引导**：首次使用引导页

## 🏗️ 项目架构

```
lib/
├── core/                          # 核心功能层
│   ├── adapters/                  # API 适配器（OpenAI、Anthropic）
│   ├── constants/                 # 应用常量
│   ├── engines/                   # 推理引擎
│   │   ├── local_ffi_engine       # llama.cpp FFI 本地推理
│   │   ├── model_inference_engine # 统一推理路由
│   │   ├── piper_tts_engine       # Piper TTS 引擎
│   │   └── whisper_engine         # Whisper ASR 引擎
│   ├── models/                    # 数据模型
│   ├── providers/                 # Riverpod 状态管理
│   ├── services/                  # 核心服务（TTS、ASR、MCP、记忆等）
│   ├── security/                  # 安全服务（加密、书签）
│   ├── protocols/                 # MCP 协议实现
│   ├── platform/                  # 平台适配（硬件、加速）
│   ├── router/                    # go_router 路由
│   └── storage/                   # Drift ORM 数据库
├── features/                      # 功能模块
│   ├── session/                   # 会话管理与对话引擎
│   ├── model/                     # 模型管理与市场
│   ├── skill/                     # 技能系统（专家与插件）
│   ├── rag/                       # RAG 知识库
│   ├── memory/                    # 记忆引擎
│   ├── prompt/                    # 提示词引擎
│   ├── settings/                  # 设置页面
│   └── workflow/                  # 工作流引擎
├── generated/                     # 国际化生成代码
├── l10n/                          # 本地化 ARB 文件
├── app.dart                       # 应用根组件
└── main.dart                      # 入口函数
```

## 🛠️ 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter 3.x + Dart 3.10.7+ |
| 状态管理 | Riverpod 2.x + 代码生成 |
| 路由 | go_router 17.x |
| 数据库 | Drift ORM (SQLite) |
| 本地推理 | llamadart 0.6.16 (llama.cpp FFI b9010) |
| 网络 | Dio 5.x + http + web_socket_channel |
| 后台下载 | background_downloader（原生后台服务，断点续传） |
| TTS | Sherpa-ONNX 1.12.x / flutter_tts / MiMo TTS API |
| ASR | speech_to_text / Sherpa-ONNX |
| 录音 | record 6.x + flutter_recorder (miniaudio FFI) |
| OCR | Google ML Kit + textify (纯 Dart) |
| PDF | pdfx + syncfusion_flutter_pdf |
| 加密 | encrypt + crypto (AES-256) |
| 安全存储 | flutter_secure_storage |
| 生物识别 | local_auth |
| 中文分词 | jieba_flutter |
| 位置服务 | geolocator |

## 🚀 快速开始

### 环境要求

- Flutter SDK 3.10.7+
- Dart SDK 3.10.7+
- Xcode 15+（iOS/macOS 开发）
- Android Studio（Android 开发）

### 安装

```bash
# 克隆仓库
git clone https://github.com/jasonma1210/multi_model_client.git
cd multi_model_client

# 安装依赖
flutter pub get

# 生成代码（Drift / Riverpod）
dart run build_runner build --delete-conflicting-outputs

# 运行应用
flutter run
```

### 构建发布版

```bash
# Android APK
flutter build apk --release

# macOS
flutter build macos --release

# iOS
flutter build ios --release
```

## 📱 支持平台

| 平台 | 状态 | GPU 加速 | 最低版本 |
|------|------|----------|----------|
| iOS | ✅ 已支持 | Metal | 15.0+ (iPhone 8+) |
| Android | ✅ 已支持 | Vulkan | 10.0+ (arm64-v8a) |
| macOS | ✅ 已支持 | Metal (Apple Silicon) | Apple Silicon & Intel |
| Windows | 🔧 部分支持 | CUDA/CPU | - |
| Linux | 🔧 部分支持 | CUDA/CPU | - |

## 📊 性能指标

| 指标 | 目标 |
|------|------|
| 冷启动 | ≤ 2 秒 |
| 7B 模型加载 | ≤ 3 秒 |
| 推理速度 | ≥ 30 tokens/sec |
| 语音延迟 | ≤ 500ms |
| 内存占用 | ≤ 1GB |

## 📦 发布版本

从 [Releases](https://github.com/jasonma1210/multi_model_client/releases) 页面下载最新版本 (v0.40.0)：
- `app-release.apk` — Android APK
- `MJ_Nexus_Series.dmg` — macOS DMG

## 📋 更新日志

### v0.40.0 (2026-06-06)

**品牌更新**
- 应用更名为 **MJ Nexus Series:Synpse**（英文） / **MJ Nexus Series:灵犀通**（中文）
- 更新所有平台的应用标题（Android、iOS、macOS）

**TTS 语音改进**
- 默认 TTS 提供商更改为 **MiMo**（云端 TTS），语音质量更好
- 移除自动降级/回退逻辑 — 用户完全控制 TTS 提供商切换
- 新增 **1分钟总超时** 机制 — 语音输出如在1分钟内未完成，自动停止
- 不再需要等待 20-30 秒自动切换提供商

## 📄 许可证

私有项目，保留所有权利。

## 🤝 参与贡献

欢迎提交 Issue 和 Pull Request！

## 📞 联系方式

如有问题或建议，请在 GitHub 上提交 Issue。

---

## 📝 会话记录

### Session #42 — 灵感一瞬播放按钮简化 + 全选/一键总结 + mmproj 模型过滤 (2026-05-29)

**会话背景**：用户提出3个问题：(1) 播放按钮过于复杂（4个按钮），需要简化为播放/停止两个按钮切换；(2) 详细页面缺少全选勾选按钮和一键总结功能；(3) 加载模型时报错 `Failed to load model gemma-4-26B-A4B-it-mmproj-BF16.gguf`，原因是加载了 mmproj（视觉模型投影器）文件而非主模型。

**会话目的**：简化播放控件、补全详细页面功能、修复模型加载错误。

**完成的主要任务**：
1. 主页面录音项播放控件简化：从4个按钮（播放/暂停/停止/速度）改为2个按钮切换（播放/停止）
2. 详细页面录音项同样简化为播放/停止切换
3. 详细页面顶部添加全选 Checkbox，支持一键全选/取消全选所有录音
4. 详细页面底部添加"一键总结"按钮（仅在有选中录音时显示）
5. 添加 `_loadFilteredModels()` 方法，过滤掉 filePath 包含 'mmproj' 的模型文件
6. 在3处模型加载代码中应用过滤
7. 验证 `flutter analyze` 和 `flutter build macos --debug` 均通过

**技术栈**：Flutter, Dart, SharedPreferences, ModelEntry, LocalFFIEngine, globalModelEngine

**关键决策和解决方案**：
1. 播放控件简化：使用 `isPlaying ? Icons.stop_circle : Icons.play_circle` 实现图标切换
2. 全选逻辑：`allIds.every((id) => _selectedRecordingIds.contains(id))` 判断是否全选
3. mmproj 过滤：检查 `m.filePath!.contains('mmproj')`，跳过视觉模型投影器文件
4. 详细页面一键总结按钮放在 ListView 底部，仅当有选中录音时显示

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `inspiration_page.dart` | 添加 `_loadFilteredModels()` 方法，过滤 mmproj 文件 | 防止加载视觉模型投影器导致崩溃 |
| `inspiration_page.dart` | 主页面和详细页面播放按钮简化为播放/停止切换 | 用户要求简化操作 |
| `inspiration_page.dart` | 详细页面添加全选 Checkbox + 一键总结按钮 | 用户要求补全功能 |
| `README.md` | 追加 Session #42 会话记录 | 按要求记录会话总结 |
| `README_zh.md` | 追加 Session #42 会话记录 | 按要求记录会话总结 |

### Session #43 — 播放按钮切换修复 + 一键总结加载动画 + 模型选择记忆 (2026-05-29)

**会话背景**：用户反馈两个问题：(1) 播放按钮点击播放后，再次点击不会停止播放（逻辑 bug）；(2) 一键总结按钮没有加载动画，且模型选择没有记忆功能。

**会话目的**：修复播放按钮切换逻辑、添加加载动画、实现模型选择记忆。

**完成的主要任务**：
1. 修复主页面和详细页面的 `_playRecording` 方法：当录音正在播放时，再次点击调用 `_stopPlayback()` 停止播放
2. 详细页面 AppBar 和底部一键总结按钮：生成中显示加载动画
3. 模型选择记忆：用户选择模型后保存到 `SharedPreferences`，下次自动选中

**技术栈**：Flutter, Dart, SharedPreferences, AudioPlayer, CircularProgressIndicator

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `inspiration_page.dart` | 修复播放/停止切换逻辑 | 修复点击播放后无法停止的 bug |
| `inspiration_page.dart` | 添加加载动画 | 用户体验优化 |
| `inspiration_page.dart` | 添加模型保存逻辑 | 实现模型选择记忆功能 |
| `README.md` | 追加 Session #43 会话记录 | 按要求记录会话总结 |
| `README_zh.md` | 追加 Session #43 会话记录 | 按要求记录会话总结 |

### Session #44 — 播放按钮颜色优化：停止按钮改为红色 (2026-05-29)

**会话背景**：用户要求播放按钮点击播放后变成红色停止按钮，再次点击停止后变回播放按钮。

**会话目的**：优化播放按钮颜色，停止状态使用明确的红色。

**完成的主要任务**：
1. 主页面和详细页面播放按钮：停止状态颜色改为 `Colors.red`
2. 验证构建通过

**技术栈**：Flutter, Dart, Colors

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `inspiration_page.dart` | 播放按钮停止状态改为 `Colors.red` | 用户要求红色停止按钮 |
| `README.md` | 追加 Session #44 会话记录 | 按要求记录会话总结 |
| `README_zh.md` | 追加 Session #44 会话记录 | 按要求记录会话总结 |

### Session #45 — ASR 架构升级：VAD预处理 + 说话人分离 + 模型更新检测 (2026-05-29)

**会话背景**：用户要求对 ASR 功能进行全面升级，包括 VAD 预处理、说话人分离、模型版本管理。

**会话目的**：设计并实现企业级 ASR 架构。

**完成的主要任务**：
1. 创建 VAD 服务：Silero VAD 模型集成，语音活动检测
2. 创建说话人分离服务：ECAPA-TDNN 声纹嵌入，AHC 聚类算法
3. 创建音频处理管道：整合 VAD + ASR + 说话人分离
4. 创建模型更新服务：GitHub Release 检测，多源下载

**技术栈**：Flutter, Dart, Sherpa-ONNX, Silero VAD, ECAPA-TDNN

**新增的文件**：
| 文件 | 内容 | 用途 |
|------|------|------|
| `vad_service.dart` | VAD 预处理服务 | 语音活动检测 |
| `speaker_diarization_service.dart` | 说话人分离服务 | 声纹嵌入，聚类 |
| `audio_processing_pipeline.dart` | 音频处理管道 | 整合处理流程 |
| `model_update_service.dart` | 模型更新服务 | 版本检测，下载 |

**架构设计**：
```
原始音频 → VAD → ASR + 说话人分离（并行）→ 时间戳对齐 → 最终输出
```

### Session #46 — 灵感一瞬录音时间限制 + 计时显示 + 倒计时提示 (2026-05-29)

**会话背景**：用户要求灵感一瞬录音功能增加时间限制，方便管理录音时长。

**会话目的**：实现5分钟录音时间限制，录制时显示计时，剩余10秒时提示。

**完成的主要任务**：
1. 添加录音时间限制：最大5分钟（300秒），超时自动停止
2. 录制计时显示：实时显示已录制时长和总时长（如 01:30 / 05:00）
3. 进度条显示：LinearProgressIndicator 显示录制进度
4. 10秒倒计时提示：剩余10秒时显示橙色警告，SnackBar 提示用户

**技术栈**：Flutter, Dart, Timer, LinearProgressIndicator

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `inspiration_page.dart` | 添加5分钟时间限制和倒计时功能 | 用户要求限制录音时长 |
| `README.md` | 追加 Session #46 会话记录 | 按要求记录会话总结 |
| `README_zh.md` | 追加 Session #46 会话记录 | 按要求记录会话总结 |
