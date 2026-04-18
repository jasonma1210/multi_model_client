# 🔧 Multi-Model Client 故障排查指南

**版本：** v1.0
**更新日期：** 2026-04-09

---

## 📋 目录

1. [网络问题](#网络问题)
2. [模型问题](#模型问题)
3. [性能问题](#性能问题)
4. [数据问题](#数据问题)
5. [平台特定问题](#平台特定问题)
6. [高级诊断](#高级诊断)

---

## 网络问题

### 问题1：无法访问HuggingFace

**症状：**
- 模型下载失败
- 错误信息：`Connection failed` 或 `Timeout`
- 搜索模型无结果

**诊断步骤：**

1. **运行网络诊断**
   ```
   设置 → 网络诊断 → 开始诊断
   ```

2. **查看诊断结果**
   - ✅ 本地网络已连接
   - ❌ HuggingFace 官方无法访问
   - ✅ HuggingFace 镜像可访问

**解决方案：**

**方案A：使用国内镜像（推荐）**
- 系统已自动配置镜像切换
- 优先使用：`https://hf-mirror.com`
- 无需手动操作

**方案B：使用ModelScope**
- 切换到 ModelScope 模型源
- 国内访问速度快，无需代理
- 推荐国内用户使用

**方案C：配置代理**
```yaml
# 设置 → 网络 → 代理配置
代理类型: HTTP
地址: 127.0.0.1
端口: 7890
```

**方案D：检查防火墙**
- macOS: 系统偏好设置 → 安全性与隐私 → 防火墙
- Windows: 控制面板 → Windows Defender 防火墙
- 添加应用到允许列表

---

### 问题2：API调用失败

**症状：**
- 云端模型无响应
- 错误：`API key invalid` 或 `Rate limit exceeded`

**诊断：**

1. **检查API密钥**
   - 设置 → API管理
   - 查看密钥状态
   - 测试连接

2. **查看错误详情**
   - 点击「查看日志」
   - 找到具体错误代码

**解决方案：**

| 错误代码 | 含义 | 解决方法 |
|---------|------|----------|
| 401 | API Key无效 | 重新输入密钥 |
| 429 | 请求频率超限 | 等待1分钟后重试 |
| 500 | 服务器错误 | 稍后再试 |
| 503 | 服务不可用 | 检查服务商状态页 |

**验证API密钥：**
```bash
# 测试OpenAI API
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer YOUR_API_KEY"

# 测试Anthropic API
curl https://api.anthropic.com/v1/models \
  -H "x-api-key: YOUR_API_KEY"
```

---

### 问题3：网络权限被拒绝

**症状：**
- macOS提示：网络访问被系统阻止
- 错误：`Operation not permitted`

**解决方案：**

**macOS系统：**

1. **检查应用权限**
   ```
   系统偏好设置 → 安全性与隐私 → 防火墙 → 防火墙选项
   ```
   - 找到 Multi-Model Client
   - 允许传入连接

2. **检查Entitlements文件**
   ```xml
   <!-- macOS/Runner/Release.entitlements -->
   <key>com.apple.security.network.client</key>
   <true/>
   <key>com.apple.security.network.server</key>
   <true/>
   ```

3. **重新安装应用**
   - 卸载现有应用
   - 重新下载安装
   - 首次启动时授予网络权限

**Windows系统：**

1. **检查防火墙规则**
   ```
   控制面板 → Windows Defender 防火墙 → 允许应用通过防火墙
   ```

2. **添加应用规则**
   - 点击「更改设置」
   - 点击「允许其他应用」
   - 添加 Multi-Model Client

---

## 模型问题

### 问题4：模型加载失败

**症状：**
- 点击加载后闪退
- 错误：`Failed to load model`
- 内存占用异常

**诊断步骤：**

1. **检查系统内存**
   - macOS: 活动监视器
   - Windows: 任务管理器
   - 查看可用内存

2. **查看日志**
   ```
   设置 → 开发者选项 → 查看日志
   ```

**内存需求参考：**

| 模型参数 | 内存需求（FP16） | 内存需求（Q4_K_M） |
|---------|------------------|-------------------|
| 7B | ~14GB | ~5GB |
| 13B | ~26GB | ~8GB |
| 30B | ~60GB | ~20GB |
| 70B | ~140GB | ~40GB |

**解决方案：**

**方案A：释放内存**
```bash
# macOS: 关闭不必要应用
killall Safari Chrome

# Windows: 使用任务管理器结束进程
```

**方案B：使用量化模型**
- 选择更小的量化级别（Q4_K_M）
- 降低内存占用50%+

**方案C：减少上下文长度**
```yaml
# 会话设置 → 高级设置
max_context: 2048  # 从4096降低到2048
```

**方案D：检查模型文件完整性**
```bash
# 计算文件哈希值
shasum -a 256 model.gguf

# 对比官方哈希值
```

---

### 问题5：模型推理慢

**症状：**
- 生成速度 < 10 tok/s
- GPU利用率低
- CPU占用100%

**诊断：**

1. **检查硬件加速**
   ```
   设置 → 系统信息 → 查看GPU信息
   ```

2. **监控性能**
   - macOS: 活动监视器 → GPU历史记录
   - Windows: 任务管理器 → 性能 → GPU

**解决方案：**

**macOS (Metal加速)：**

```bash
# 检查Metal支持
system_profiler SPDisplaysDataType | grep Metal

# 确保使用Metal
# 应用会自动检测并启用
```

**Windows (CUDA加速)：**

1. **检查CUDA驱动**
   ```bash
   nvidia-smi
   ```

2. **安装CUDA Toolkit**
   - 下载：https://developer.nvidia.com/cuda-downloads
   - 版本要求：CUDA 11.8+

3. **验证CUDA**
   ```bash
   nvcc --version
   ```

**通用优化：**

1. **选择合适的量化级别**
   ```
   Q4_K_M: 推荐（平衡速度和质量）
   Q5_K_S: 高质量，稍慢
   Q8_0: 最高质量，最慢
   ```

2. **调整线程数**
   ```yaml
   # 模型设置 → 高级设置
   n_threads: 8  # CPU核心数
   n_gpu_layers: 35  # GPU层数
   ```

3. **减少生成Token数**
   ```yaml
   max_tokens: 500  # 降低到500
   ```

---

### 问题6：模型下载中断

**症状：**
- 下载进度卡住
- 网络超时
- 文件损坏

**解决方案：**

**方案A：使用断点续传**
- 应用支持自动续传
- 等待网络恢复后继续

**方案B：切换下载源**
- ModelScope ↔ HuggingFace
- 尝试不同镜像

**方案C：手动下载**
1. 从浏览器下载模型文件
2. 放到应用模型目录：
   ```
   macOS: ~/Library/Application Support/MultiModelClient/models/
   Windows: C:\Users\<用户名>\AppData\Local\MultiModelClient\models\
   ```
3. 应用会自动识别

**方案D：使用下载工具**
```bash
# 使用wget下载
wget -c https://huggingface.co/.../model.gguf

# 使用aria2加速
aria2c -x 16 -s 16 https://huggingface.co/.../model.gguf
```

---

## 性能问题

### 问题7：应用卡顿

**症状：**
- UI响应慢
- 滚动卡顿
- CPU占用高

**诊断：**

1. **检查系统资源**
   - 内存占用
   - CPU占用
   - 磁盘IO

2. **查看应用日志**
   ```
   设置 → 开发者选项 → 性能日志
   ```

**解决方案：**

**方案A：清理会话历史**
```
设置 → 数据管理 → 清理旧会话
保留最近30天数据
```

**方案B：减少加载的模型数**
- 卸载不常用的模型
- 释放内存

**方案C：优化向量数据库**
```
知识库设置 → 向量索引 → 重建索引
```

**方案D：检查后台任务**
- 关闭不必要的MCP服务器
- 停止自动同步

---

### 问题8：内存泄漏

**症状：**
- 内存占用持续增长
- 应用变慢
- 需要频繁重启

**诊断：**

1. **监控内存增长**
   ```bash
   # macOS
   ps aux | grep MultiModelClient

   # Windows
   tasklist | findstr MultiModelClient
   ```

2. **检查日志**
   ```
   设置 → 开发者选项 → 内存日志
   ```

**解决方案：**

**临时方案：**
- 定期重启应用
- 清理会话缓存

**永久方案：**
- 更新到最新版本
- 反馈给开发团队

**报告问题：**
```
GitHub Issues: https://github.com/multi-model-client/issues
提供：
- 系统版本
- 应用版本
- 内存日志
- 重现步骤
```

---

## 数据问题

### 问题9：数据丢失

**症状：**
- 会话消失
- 消息记录丢失
- 配置重置

**诊断：**

1. **检查数据目录**
   ```
   macOS: ~/Library/Application Support/MultiModelClient/
   Windows: C:\Users\<用户名>\AppData\Local\MultiModelClient\
   ```

2. **查看数据库文件**
   ```
   data/app.db  # SQLite数据库
   ```

**解决方案：**

**方案A：从备份恢复**
```
设置 → 数据管理 → 导入备份
```

**方案B：手动恢复数据库**
```bash
# 检查数据库完整性
sqlite3 app.db "PRAGMA integrity_check;"

# 修复数据库
sqlite3 app.db "REINDEX;"

# 导出数据
sqlite3 app.db ".dump" > backup.sql
```

**方案C：使用自动备份**
- 启用：设置 → 数据管理 → 自动备份
- 设置备份频率：每日/每周
- 选择备份位置

---

### 问题10：数据库损坏

**症状：**
- 启动失败
- 错误：`Database disk image is malformed`
- 数据读取异常

**解决方案：**

**方案A：自动修复**
```
应用会自动检测并尝试修复
重启应用查看结果
```

**方案B：手动修复**
```bash
# 1. 备份当前数据库
cp app.db app_backup.db

# 2. 导出数据
sqlite3 app.db ".dump" > dump.sql

# 3. 创建新数据库
sqlite3 app_new.db < dump.sql

# 4. 替换数据库
mv app_new.db app.db
```

**方案C：重置应用**
```bash
# ⚠️ 注意：会清除所有数据
rm -rf ~/Library/Application Support/MultiModelClient/

# 重新启动应用
```

---

## 平台特定问题

### macOS问题

#### 问题11：应用无法启动

**症状：**
- 点击应用无反应
- 提示：应用已损坏

**解决方案：**

**方案A：移除隔离属性**
```bash
xattr -cr /Applications/MultiModelClient.app
```

**方案B：允许任何来源**
```bash
sudo spctl --master-disable
```

**方案C：重新签名**
```bash
codesign --force --deep --sign - /Applications/MultiModelClient.app
```

---

#### 问题12：权限问题

**症状：**
- 无法访问文件
- 网络被阻止
- 麦克风/摄像头无法使用

**解决方案：**

**检查权限设置：**
```
系统偏好设置 → 安全性与隐私 → 隐私
```

**需要的权限：**
- ✅ 网络访问（必需）
- ✅ 文件访问（可选，用于文档管理）
- ✅ 麦克风（可选，用于语音输入）
- ✅ 摄像头（可选，用于视频理解）

---

### Windows问题

#### 问题13：CUDA初始化失败

**症状：**
- 错误：`CUDA initialization failed`
- 无法使用GPU加速

**解决方案：**

**步骤1：检查显卡驱动**
```bash
nvidia-smi
```

如果命令不存在：
- 安装NVIDIA驱动
- 重启电脑

**步骤2：安装CUDA Toolkit**
- 下载：https://developer.nvidia.com/cuda-downloads
- 选择对应版本
- 安装并重启

**步骤3：验证环境变量**
```bash
echo %CUDA_PATH%
```

应输出：`C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8`

---

### iOS问题

#### 问题14：应用闪退

**症状：**
- 启动时闪退
- 加载模型时崩溃

**解决方案：**

**方案A：检查设备内存**
- 7B模型需要设备内存 > 4GB
- iPhone 12以下机型可能不支持大模型

**方案B：使用小模型**
- 选择1.8B-3B参数模型
- 降低量化级别

**方案C：重新安装**
- 卸载应用
- 重启设备
- 重新安装

---

### Android问题

#### 问题15：NNAPI加速失效

**症状：**
- 模型推理慢
- GPU未被使用

**解决方案：**

**检查NNAPI支持：**
```bash
adb shell getprop ro.hardware
```

**启用NNAPI：**
```yaml
# 模型设置 → 高级设置
use_nnapi: true
nnapi_accelerator_name: "qti-tpu"  # 根据设备调整
```

**兼容性检查：**
- Android 8.1+ required
- 部分设备可能不支持

---

## 高级诊断

### 日志收集

**启用详细日志：**
```yaml
# 设置 → 开发者选项
日志级别: DEBUG
保存日志: true
日志路径: ~/Desktop/MMC_logs/
```

**日志文件位置：**
```
macOS: ~/Library/Logs/MultiModelClient/
Windows: C:\Users\<用户名>\AppData\Local\MultiModelClient\Logs\
iOS/Android: 应用内查看
```

---

### 性能分析

**CPU分析：**
```bash
# macOS
instruments -t "Time Profiler" MultiModelClient

# Windows
Windows Performance Analyzer
```

**内存分析：**
```bash
# macOS
leaks --atExit -- MultiModelClient

# Windows
DebugDiag
```

---

### 数据库分析

**检查数据库：**
```bash
# 连接数据库
sqlite3 ~/Library/Application\ Support/MultiModelClient/data/app.db

# 检查完整性
PRAGMA integrity_check;

# 查看表信息
.schema

# 查询会话数
SELECT COUNT(*) FROM sessions;

# 查询消息数
SELECT COUNT(*) FROM messages;
```

---

## 📞 获取帮助

### 自助资源

1. **官方文档**
   - 快速入门指南
   - 用户手册
   - API文档

2. **社区论坛**
   - 常见问题解答
   - 用户经验分享
   - 功能建议

### 联系支持

**提交问题时请提供：**

1. **系统信息**
   - 操作系统和版本
   - 应用版本
   - 硬件配置

2. **问题描述**
   - 详细症状
   - 重现步骤
   - 期望行为

3. **附件文件**
   - 错误日志
   - 截图/录屏
   - 配置文件

**联系方式：**
- GitHub Issues: https://github.com/multi-model-client/issues
- 邮件支持: support@multi-model-client.dev
- 社区论坛: https://community.multi-model-client.dev

---

**最后更新：** 2026-04-09
**版本：** v1.0
