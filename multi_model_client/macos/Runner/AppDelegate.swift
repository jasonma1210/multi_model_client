import Cocoa
import FlutterMacOS
import Metal

@main
class AppDelegate: FlutterAppDelegate {
  private var hardwareChannel: FlutterMethodChannel?
  private var bookmarkChannel: FlutterMethodChannel?
  
  /// 当前正在访问的安全作用域资源路径 → 引用计数
  private var accessingRefCount: [String: Int] = [:]
  /// 已解析的安全作用域 URL（用于正确 stopAccessingSecurityScopedResource）
  private var resolvedUrls: [String: URL] = [:]

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ aNotification: Notification) {
    let controller : FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController

    // 注册硬件检测通道
    hardwareChannel = FlutterMethodChannel(
      name: "com.example.ai_assistant/hardware",
      binaryMessenger: controller.engine.binaryMessenger
    )

    hardwareChannel?.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "getDeviceEnv":
        result(self?.getDeviceEnv())
      case "checkMetalAvailability":
        result(self?.checkMetalAvailability() ?? false)
      case "getGpuInfo":
        result(self?.getGpuInfo())
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // 注册安全作用域书签通道（macOS 沙盒外部文件访问）
    bookmarkChannel = FlutterMethodChannel(
      name: "com.multimodel.client/security_bookmark",
      binaryMessenger: controller.engine.binaryMessenger
    )

    bookmarkChannel?.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "saveBookmark":
        if let args = call.arguments as? [String: Any],
           let path = args["path"] as? String {
          let bookmarkResult = self?.saveBookmark(path: path)
          result(bookmarkResult)
        } else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing path", details: nil))
        }
      case "resolveBookmark":
        if let args = call.arguments as? [String: Any],
           let bookmarkBase64 = args["bookmarkData"] as? String {
          let resolved = self?.resolveBookmark(bookmarkBase64: bookmarkBase64)
          result(resolved)
        } else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing bookmarkData", details: nil))
        }
      case "startAccessing":
        if let args = call.arguments as? [String: Any],
           let path = args["path"] as? String {
          result(self?.startAccessing(path: path) ?? false)
        } else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing path", details: nil))
        }
      case "stopAccessing":
        if let args = call.arguments as? [String: Any],
           let path = args["path"] as? String {
          self?.stopAccessing(path: path)
          result(true)
        } else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing path", details: nil))
        }
      case "stopAllAccessing":
        self?.stopAllAccessing()
        result(true)
      case "pickDirectory":
        self?.pickDirectoryWithBookmark(result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    super.applicationDidFinishLaunching(aNotification)
  }

  // ══════════════════════════════════════════════════════════════════
  //  Security-Scoped Bookmark 管理
  // ══════════════════════════════════════════════════════════════════

  /// 使用 NSOpenPanel 选择目录并一步创建安全作用域书签
  /// 这是推荐的方式：通过系统面板选择目录，自动获得沙盒授权
  private func pickDirectoryWithBookmark(result: @escaping FlutterResult) {
    let panel = NSOpenPanel()
    panel.canChooseDirectories = true
    panel.canChooseFiles = false
    panel.allowsMultipleSelection = false
    panel.message = "请选择包含 GGUF 模型的文件夹"
    panel.begin { [weak self] response in
      if response == .OK, let url = panel.url {
        do {
          // 创建安全作用域书签
          let bookmark = try url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
          )
          // 立即开始访问（首次授权）
          let accessed = url.startAccessingSecurityScopedResource()
          if accessed {
            self?.accessingRefCount[url.path] = 1
            self?.resolvedUrls[url.path] = url
          }
          debugPrint("[SecurityBookmark] ✅ NSOpenPanel 选择目录: \(url.path), 书签已创建, 访问: \(accessed)")
          result([
            "path": url.path,
            "bookmark": bookmark.base64EncodedString(),
            "accessGranted": accessed,
          ])
        } catch {
          debugPrint("[SecurityBookmark] ❌ 创建书签失败: \(error.localizedDescription)")
          result([
            "path": url.path,
            "bookmark": nil as String?,
            "accessGranted": false,
            "error": error.localizedDescription,
          ])
        }
      } else {
        result(nil)
      }
    }
  }

  /// 保存安全作用域书签
  /// 返回 Base64 编码的书签数据，失败返回 nil
  private func saveBookmark(path: String) -> [String: Any?]? {
    let url = URL(fileURLWithPath: path)
    
    do {
      // 创建安全作用域书签（包含文件属性，允许跨重启访问）
      let bookmarkData = try url.bookmarkData(
        options: [.withSecurityScope],
        includingResourceValuesForKeys: nil,
        relativeTo: nil
      )
      let base64 = bookmarkData.base64EncodedString()
      debugPrint("[SecurityBookmark] ✅ 保存书签成功: \(path)")
      return ["success": true, "bookmarkData": base64, "path": path]
    } catch {
      debugPrint("[SecurityBookmark] ❌ 保存书签失败: \(error.localizedDescription)")
      return ["success": false, "error": error.localizedDescription]
    }
  }

  /// 解析安全作用域书签
  /// 返回解析后的文件路径，失败返回 nil
  private func resolveBookmark(bookmarkBase64: String) -> [String: Any?]? {
    guard let bookmarkData = Data(base64Encoded: bookmarkBase64) else {
      debugPrint("[SecurityBookmark] ❌ 无效的书签数据")
      return ["success": false, "error": "Invalid bookmark data"]
    }
    
    do {
      var isStale = false
      let url = try URL(
        resolvingBookmarkData: bookmarkData,
        options: [.withSecurityScope],
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
      )
      
      if isStale {
        debugPrint("[SecurityBookmark] ⚠️ 书签已过期: \(url.path)")
      }
      
      let path = url.path
      
      // 安全作用域资源：已激活的路径无需再次 start（避免引用计数失衡）
      if let count = accessingRefCount[path], count > 0 {
        accessingRefCount[path] = count + 1
        debugPrint("[SecurityBookmark] ✅ 书签已激活（引用计数: \(count + 1)）: \(path)")
        return ["success": true, "path": path, "isStale": isStale, "accessGranted": true]
      }
      
      // 首次激活：开始访问安全作用域资源
      let accessed = url.startAccessingSecurityScopedResource()
      debugPrint("[SecurityBookmark] ✅ 解析书签成功: \(path), 访问: \(accessed)")
      
      if accessed {
        accessingRefCount[path] = 1
        resolvedUrls[path] = url
      }
      
      return ["success": true, "path": path, "isStale": isStale, "accessGranted": accessed]
    } catch {
      debugPrint("[SecurityBookmark] ❌ 解析书签失败: \(error.localizedDescription)")
      return ["success": false, "error": error.localizedDescription]
    }
  }

  /// 开始访问安全作用域资源（直接路径，非书签解析）
  private func startAccessing(path: String) -> Bool {
    if let count = accessingRefCount[path], count > 0 {
      accessingRefCount[path] = count + 1
      return true
    }
    
    let url = URL(fileURLWithPath: path)
    let accessed = url.startAccessingSecurityScopedResource()
    if accessed {
      accessingRefCount[path] = 1
      resolvedUrls[path] = url
      debugPrint("[SecurityBookmark] ✅ 开始访问: \(path)")
    } else {
      debugPrint("[SecurityBookmark] ⚠️ 无法开始访问: \(path)")
    }
    return accessed
  }

  /// 停止访问安全作用域资源（引用计数，仅在计数归零时真正释放）
  private func stopAccessing(path: String) {
    // 也检查父目录（模型子目录可能匹配到父目录的书签）
    let matchingPath = accessingRefCount.keys.first { key in
      path == key || path.hasPrefix(key + "/")
    } ?? path
    
    guard let count = accessingRefCount[matchingPath], count > 0 else {
      return
    }
    
    let newCount = count - 1
    if newCount <= 0 {
      // 引用计数归零，真正停止访问
      if let url = resolvedUrls[matchingPath] {
        url.stopAccessingSecurityScopedResource()
      } else {
        let url = URL(fileURLWithPath: matchingPath)
        url.stopAccessingSecurityScopedResource()
      }
      accessingRefCount.removeValue(forKey: matchingPath)
      resolvedUrls.removeValue(forKey: matchingPath)
      debugPrint("[SecurityBookmark] 🛑 停止访问: \(matchingPath)")
    } else {
      accessingRefCount[matchingPath] = newCount
      debugPrint("[SecurityBookmark] 🔒 引用计数减少: \(matchingPath) (\(newCount))")
    }
  }

  /// 停止所有安全作用域资源访问
  private func stopAllAccessing() {
    for (path, url) in resolvedUrls {
      url.stopAccessingSecurityScopedResource()
      debugPrint("[SecurityBookmark] 🛑 停止访问: \(path)")
    }
    // 对于没有保存 URL 的路径，用路径构造 URL 停止
    for path in accessingRefCount.keys where !resolvedUrls.keys.contains(path) {
      let url = URL(fileURLWithPath: path)
      url.stopAccessingSecurityScopedResource()
      debugPrint("[SecurityBookmark] 🛑 停止访问: \(path)")
    }
    accessingRefCount.removeAll()
    resolvedUrls.removeAll()
    debugPrint("[SecurityBookmark] 🛑 停止所有访问")
  }

  /// 获取设备环境信息
  private func getDeviceEnv() -> [String: Any?] {
    var env: [String: Any?] = [:]

    // CPU架构
    #if arch(arm64)
      env["cpuArch"] = "arm64"
    #elseif arch(x86_64)
      env["cpuArch"] = "x86_64"
    #else
      env["cpuArch"] = "unknown"
    #endif

    // CPU核心数
    env["cpuCores"] = ProcessInfo.processInfo.processorCount

    // 总内存（MB）
    let totalMemory = ProcessInfo.processInfo.physicalMemory
    env["totalMemoryMB"] = Int(totalMemory / 1024 / 1024)

    // Metal信息
    let metalDevice = MTLCreateSystemDefaultDevice()
    env["isMetalAvailable"] = metalDevice != nil

    if let device = metalDevice {
      env["gpuName"] = device.name

      // 获取推荐的最大工作集大小（统一内存）
      if #available(macOS 10.14, *) {
        env["gpuMemoryMB"] = Int(device.recommendedMaxWorkingSetSize / 1024 / 1024)
      }

      // Metal版本
      env["metalVersion"] = "Metal 2"
    }

    return env
  }

  /// 检查Metal可用性
  private func checkMetalAvailability() -> Bool {
    return MTLCreateSystemDefaultDevice() != nil
  }

  /// 获取GPU详细信息
  private func getGpuInfo() -> [String: Any?] {
    var gpuInfo: [String: Any?] = [:]

    guard let device = MTLCreateSystemDefaultDevice() else {
      gpuInfo["available"] = false
      return gpuInfo
    }

    gpuInfo["available"] = true
    gpuInfo["name"] = device.name
    gpuInfo["vendor"] = "Apple"

    // 设备特性
    if #available(macOS 11.0, *) {
      gpuInfo["supportsRayTracing"] = device.supportsRaytracing
    } else {
      gpuInfo["supportsRayTracing"] = false
    }

    if #available(macOS 10.15, *) {
      gpuInfo["maxThreadsPerThreadgroup"] = device.maxThreadsPerThreadgroup.width
      gpuInfo["maxBufferLength"] = device.maxBufferLength
    }

    // 统一内存架构标识
    gpuInfo["unifiedMemory"] = true

    if #available(macOS 10.14, *) {
      gpuInfo["recommendedMaxWorkingSetSize"] = device.recommendedMaxWorkingSetSize
    }

    return gpuInfo
  }
}
