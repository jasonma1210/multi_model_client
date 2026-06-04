# Flutter macOS 应用访问外部大模型文件的完整解决方案

你遇到的两个问题都很典型：第一个是 **macOS App Sandbox 权限问题**，第二个是 **Flutter 状态管理问题**。下面分别详细解答。

---

## 问题一：`Operation not permitted (errno = 1)` 无法读取外部 GGUF 文件

### 🔍 原因分析

Flutter macOS 应用默认启用 **App Sandbox**（沙盒机制），应用只能访问：
- 自己的容器目录（`Application Support/你的应用名`）
- 用户**显式选择**的文件/目录（通过系统 NSOpenPanel）

你能看到文件名是因为目录元数据可能通过某些 API 可见，但当 llama.cpp 通过 FFI 调用 `fopen` / `mmap` 读取文件内容时，沙盒直接拒绝，返回 `EPERM`。

---

### ✅ 解决方案（推荐组合使用）

#### 步骤 1：配置 Entitlements 权限

打开 `macos/Runner/DebugProfile.entitlements` 和 `macos/Runner/Release.entitlements`，添加：

```xml
<!-- 允许访问用户通过系统面板选择的文件（只读即可） -->
<key>com.apple.security.files.user-selected.read-only</key>
<true/>

<!-- 如果需要写入日志/缓存到用户选择目录 -->
<key>com.apple.security.files.user-selected.read-write</key>
<true/>

<!-- 支持 Security-Scoped Bookmarks（持久化访问权限） -->
<key>com.apple.security.files.bookmarks.app-scope</key>
<true/>
```

> ⚠️ 不要直接关闭 `com.apple.security.app-sandbox`，否则无法上架 App Store，且不安全。

---

#### 步骤 2：通过 NSOpenPanel 让用户选择目录 + 创建 Bookmark

关键点：**必须通过系统原生面板选择目录**，才能获得沙盒授权。使用 `file_picker` 插件或通过 MethodChannel 自己封装。

**方案 A：使用 `file_picker` 插件（快速上手）**

```yaml
# pubspec.yaml
dependencies:
  file_picker: ^8.0.0
  shared_preferences: ^2.2.0  # 用于持久化 bookmark
```

```dart
import 'package:file_picker/file_picker.dart';

Future<String?> pickModelDirectory() async {
  String? dirPath = await FilePicker.platform.getDirectoryPath(
    dialogTitle: '请选择模型目录',
  );
  return dirPath;
}
```

但 `file_picker` **不会自动创建 Security-Scoped Bookmark**，意味着重启应用后权限会丢失。要持久化访问，必须自己写 MethodChannel。

---

**方案 B：MethodChannel 封装（推荐，支持 Bookmark 持久化）**

`macos/Runner/MainFlutterWindow.swift`：

```swift
import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
    override func awakeFromNib() {
        let flutterViewController = FlutterViewController()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)

        // 注册 MethodChannel
        let channel = FlutterMethodChannel(
            name: "com.yourapp/model_access",
            binaryMessenger: flutterViewController.engine.binaryMessenger
        )
        channel.setMethodCallHandler(handleMethodCall)

        RegisterGeneratedPlugins(registry: flutterViewController)
        super.awakeFromNib()
    }

    // 当前活跃的 security-scoped URL（用于 stopAccess）
    private var activeScopedURL: URL?

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "pickDirectory":
            let panel = NSOpenPanel()
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
            panel.allowsMultipleSelection = false
            panel.message = "请选择包含 GGUF 模型的文件夹"
            panel.begin { [weak self] response in
                if response == .OK, let url = panel.url {
                    do {
                        let bookmark = try url.bookmarkData(
                            options: .withSecurityScope,
                            includingResourceValuesForKeys: nil,
                            relativeTo: nil
                        )
                        result([
                            "path": url.path,
                            "bookmark": bookmark.base64EncodedString()
                        ])
                    } catch {
                        result(FlutterError(code: "BOOKMARK_ERR", 
                                           message: error.localizedDescription, 
                                           details: nil))
                    }
                } else {
                    result(nil)
                }
            }

        case "startAccess":
            guard let args = call.arguments as? [String: Any],
                  let b64 = args["bookmark"] as? String,
                  let data = Data(base64Encoded: b64) else {
                result(false); return
            }
            var isStale = false
            do {
                let url = try URL(
                    resolvingBookmarkData: data,
                    options: .withSecurityScope,
                    relativeTo: nil,
                    bookmarkDataIsStale: &isStale
                )
                if isStale {
                    // TODO: 重新创建 bookmark 并通知 Flutter 端更新
                }
                let ok = url.startAccessingSecurityScopedResource()
                if ok { self.activeScopedURL = url }
                result(["success": ok, "path": url.path])
            } catch {
                result(["success": false, "error": error.localizedDescription])
            }

        case "stopAccess":
            activeScopedURL?.stopAccessingSecurityScopedResource()
            activeScopedURL = nil
            result(true)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
```

Flutter 端调用：

```dart
class ModelAccessService {
  static const _channel = MethodChannel('com.yourapp/model_access');
  static const _bookmarkKey = 'saved_model_dir_bookmark';

  /// 让用户选择目录并保存 bookmark
  static Future<String?> pickAndSaveDirectory() async {
    final result = await _channel.invokeMethod<Map>('pickDirectory');
    if (result == null) return null;

    final path = result['path'] as String;
    final bookmark = result['bookmark'] as String;

    // 持久化 bookmark
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bookmarkKey, bookmark);
    return path;
  }

  /// 启动访问权限（在 llama.cpp 加载模型前调用）
  static Future<bool> startAccess() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmark = prefs.getString(_bookmarkKey);
    if (bookmark == null) return false;

    final result = await _channel.invokeMethod<Map>('startAccess', {
      'bookmark': bookmark,
    });
    return result?['success'] == true;
  }

  /// 停止访问（模型加载完成后、或切换目录时调用）
  static Future<void> stopAccess() async {
    await _channel.invokeMethod('stopAccess');
  }
}
```

---

#### 步骤 3：在 llama.cpp 加载模型时保持权限激活

这是**最容易被忽略**的关键点：Security-Scoped 必须在 llama.cpp `fopen`/`mmap` 文件的**整个过程中保持激活**。

```dart
Future<bool> loadModel(String modelPath) async {
  // 1. 激活 security scope
  final hasAccess = await ModelAccessService.startAccess();
  if (!hasAccess) {
    print('❌ 无法获取目录访问权限');
    return false;
  }

  try {
    // 2. 验证文件可读（提前发现权限问题）
    final file = File(modelPath);
    final length = await file.length();
    print('📦 模型文件大小: ${(length / 1024 / 1024 / 1024).toStringAsFixed(2)} GB');

    // 3. 调用 llama.cpp FFI 加载模型
    // 注意：如果 llama.cpp 用 mmap，scope 必须一直保留到模型 unload
    final loaded = await yourLlamaCppBinding.loadModel(modelPath);
    return loaded;
  } catch (e) {
    print('❌ 加载失败: $e');
    return false;
  }
  // ⚠️ 注意：如果 llama.cpp 用 mmap 映射文件，这里不能 stopAccess！
  // 只有在模型完全 unload 后才能 stopAccess
}

// 卸载模型时
Future<void> unloadModel() async {
  yourLlamaCppBinding.unloadModel();
  await ModelAccessService.stopAccess();  // 此时才能释放
}
```

---

#### 💡 大文件（15GB+）额外注意

| 问题                     | 说明                                                         |
| ------------------------ | ------------------------------------------------------------ |
| **mmap 失败**            | llama.cpp 默认用 mmap，需要足够虚拟地址空间。macOS 64位下一般没问题 |
| **APFS 稀疏文件**        | 某些下载工具创建的稀疏文件可能显示 15GB 但实际不全，用 `ls -lah` 和 `du -sh` 对比 |
| **FAT32/exFAT 外置硬盘** | 不支持 >4GB 单文件，确认文件系统是 APFS/HFS+                 |
| **首次 mmap 延迟**       | 首次访问会触发磁盘读取，15GB 可能要几十秒，UI 要做 loading   |

---

#### 方案 C（仅调试）：临时关闭沙盒

如果你只是在开发阶段快速验证，可以临时关闭沙盒：

`macos/Runner/DebugProfile.entitlements`：
```xml
<key>com.apple.security.app-sandbox</key>
<false/>
```

⚠️ **不要**在 Release 版本这样做，App Store 会拒绝，且存在安全风险。

---

## 问题二：切换目录后旧模型列表不清空

### 🔍 原因分析

这是典型的 **状态未重置** 问题。常见原因：
1. 切换目录时，新目录的模型被 **追加（addAll）** 到旧列表，而不是替换
2. Provider/Riverpod/Bloc 的状态对象没有被清空
3. 异步加载旧目录的结果在切换后才返回，覆盖了新状态（竞态条件）

---

### ✅ 解决方案（以 Provider 为例）

#### 1. 在 ViewModel 中正确处理切换逻辑

```dart
class ModelListNotifier extends ChangeNotifier {
  List<ModelFile> _models = [];
  List<ModelFile> get models => List.unmodifiable(_models);

  String? _currentDirectory;
  String? get currentDirectory => _currentDirectory;

  // 用于取消旧请求，避免竞态
  int _loadSessionId = 0;

  /// 切换目录：先清空，再加载
  Future<void> switchDirectory(String newPath) async {
    // 1. 立即清空当前列表（UI 立即响应）
    _models = [];
    _currentDirectory = newPath;
    notifyListeners();

    // 2. 停止上一个目录的 security scope
    await ModelAccessService.stopAccess();

    // 3. 递增 session id，使旧请求失效
    final sessionId = ++_loadSessionId;

    // 4. 激活新目录权限
    final hasAccess = await ModelAccessService.startAccess();
    if (!hasAccess || sessionId != _loadSessionId) return;

    // 5. 加载新目录
    try {
      final dir = Directory(newPath);
      final entities = await dir.list().toList();
      
      // 再次检查是否已被新请求取代
      if (sessionId != _loadSessionId) return;

      final ggufFiles = entities
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.gguf'))
          .map((f) => ModelFile(
                name: f.uri.pathSegments.last,
                path: f.path,
                size: f.lengthSync(),
              ))
          .toList();

      // 第三次检查
      if (sessionId != _loadSessionId) return;

      _models = ggufFiles;
      notifyListeners();
    } catch (e) {
      print('❌ 加载目录失败: $e');
      if (sessionId == _loadSessionId) {
        _models = [];
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    ModelAccessService.stopAccess();
    super.dispose();
  }
}
```

#### 2. UI 层绑定

```dart
class ModelListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ModelListNotifier>(
      builder: (context, vm, _) {
        return Column(
          children: [
            // 当前路径显示 + 切换按钮
            ListTile(
              title: Text(vm.currentDirectory ?? '未选择目录'),
              trailing: IconButton(
                icon: Icon(Icons.folder_open),
                onPressed: () async {
                  final path = await ModelAccessService.pickAndSaveDirectory();
                  if (path != null) {
                    await vm.switchDirectory(path);
                  }
                },
              ),
            ),
            // 模型列表
            Expanded(
              child: vm.models.isEmpty
                  ? Center(child: Text('该目录下没有 GGUF 模型'))
                  : ListView.builder(
                      itemCount: vm.models.length,
                      itemBuilder: (ctx, i) {
                        final m = vm.models[i];
                        return ListTile(
                          title: Text(m.name),
                          subtitle: Text('${(m.size / 1024 / 1024 / 1024).toStringAsFixed(2)} GB'),
                          onTap: () => loadModel(m.path),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
```

---

### 🔑 关键设计要点

| 要点                  | 说明                                                         |
| --------------------- | ------------------------------------------------------------ |
| **立即清空**          | 切换目录时第一时间 `_models = []` + `notifyListeners()`，用户感知流畅 |
| **Session ID 防竞态** | 异步操作期间用户可能多次切换，旧结果返回时要丢弃             |
| **释放旧 scope**      | 切换前先 `stopAccess`，避免权限泄漏                          |
| **dispose 清理**      | 页面销毁时释放 security scope，防止资源泄漏                  |

如果你用的是 **Riverpod**，把 `switchDirectory` 放到 `AsyncNotifier` 里，用 `ref.invalidateSelf()` 清空；如果是 **Bloc**，在 `SwitchDirectoryEvent` handler 里 `emit(ModelsLoading())` 后再 `emit(ModelsLoaded(newList))`。

---

## 📋 总结 Checklist

- [ ] `DebugProfile.entitlements` 和 `Release.entitlements` 都添加了 user-selected + bookmarks 权限
- [ ] 用 NSOpenPanel（而非硬编码路径）获取目录
- [ ] 创建 Security-Scoped Bookmark 并用 SharedPreferences 持久化
- [ ] llama.cpp 加载前调用 `startAccessingSecurityScopedResource`
- [ ] 模型 unload 后才调用 `stopAccessingSecurityScopedResource`
- [ ] 切换目录时：清空列表 → 停止旧 scope → 激活新 scope → 加载新列表
- [ ] 使用 session id 或 CancelableOperation 防止异步竞态

按这个方案实现后，15GB+ 的 GGUF 模型就能正常加载，目录切换也会干净利落。如果还有具体报错，把 llama.cpp 那边的 native log 贴出来，我可以继续帮你定位。