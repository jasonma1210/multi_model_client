这是一个非常经典的问题。`llama.cpp` 原生 `llama-server` 能达到满速，但通过 FFI (llamadart) 调用时速度减半甚至更慢，**瓶颈几乎从来不在模型推理本身，而在“数据搬运”和“调度策略”上**。

要实现与原生一致的速度，你需要从以下四个维度进行排查和优化：

### 1. 核心瓶颈：Token 传输开销 (FFI Overhead)
这是导致速度慢的最常见原因。`llama-server` 使用 HTTP SSE 流式传输，而 FFI 调用如果设计不当，会产生巨大的跨语言通信开销。

*   **❌ 错误做法**：每生成一个 token 就触发一次 Dart callback，或者在 C 层拼接完整字符串再传回 Dart。Dart FFI 的回调（尤其是涉及 String 转换、GC 触发）在高频调用下极慢。
*   **✅ 正确做法：Native 侧缓冲 + 批量回调**
    在 C/C++ 层维护一个 Token Buffer，攒够一定数量（如 8~16 个 token）或达到时间阈值（如 5ms）再一次性通过 FFI 传回 Dart。

```c
// C++ 侧伪代码示例
void on_token_generated(int token_id, const char* token_str) {
    buffer.append(token_str);
    token_count++;
    
    // 批量传输：减少 FFI 跨越次数
    if (token_count >= 8 || is_stop_token) {
        dart_batch_callback(buffer.c_str(), token_count);
        buffer.clear();
        token_count = 0;
    }
}
```

*   **⚡️ 进阶优化：SharedMemory / Pointer 直读**
    对于极致性能，避免 FFI Callback  altogether。让 C++ 将生成的 token 写入一块预分配的共享内存（或 malloc 的堆内存），Dart 端通过 `Pointer<Utf8>` 直接读取，仅在需要 UI 刷新时才去 poll 或由 C 端发一个轻量级的 "data ready" 信号。

### 2. 线程与调度冲突 (Threading & Scheduling)
Flutter 是单线程 UI 模型，如果 llama.cpp 的推理线程与 Flutter 的 Isolate/EventLoop 发生资源争抢，速度会断崖式下跌。

*   **检查 `n_threads` 配置**：确保传给 `llama_model_load` / `llama_context_new` 的线程数与 `llama-server` 完全一致。通常设为 `物理核心数 - 1`（给 Flutter UI 留一个核）。
*   **隔离推理 Isolate**：**绝对不要**在主 Isolate 中调用耗时的 FFI 推理函数。必须使用 `Isolate.run()` 或独立的 Native Port 进行异步调用。
*   **CPU 亲和性 (macOS/Linux)**：如果你的设备是 Apple Silicon (M系列)，确保 llama.cpp 绑定到 **Performance Cores (P-Core)**。`llama-server` 默认可能做了优化，但 FFI 调用可能被系统调度到了 Efficiency Cores (E-Core) 上。
    ```cpp
    // 在 C++ 初始化时强制绑定 P-Core (macOS)
    #include <mach/thread_policy.h>
    thread_affinity_policy_data_t policy = { THREAD_AFFINITY_TAG_P_CORE };
    thread_policy_set(pthread_mach_thread_np(pthread_self()),
                      THREAD_AFFINITY_POLICY,
                      (thread_policy_t)&policy, 1);
    ```

### 3. 后端加速未生效 (Backend Acceleration)
确认你的动态库编译时真正启用了硬件加速，且运行时没有 fallback 到 CPU。

*   **验证 Metal/CUDA 状态**：在加载模型后，打印 `llama.cpp` 的日志，确认看到 `Metal: enabled` 或 `CUDA: enabled`。如果只是 `CPU: enabled`，说明你加载的动态库编译选项不对。
*   **GPU Offload 层数**：检查 `n_gpu_layers` 参数。`llama-server` 可能默认 `-ngl 999`，但你的 Dart 代码中可能传了较小的值或未传。确保设置为足够大的值（如 999）以将所有层卸载到 GPU。
*   **Flash Attention**：确认编译动态库时开启了 `-DGGML_USE_FLASH_ATTN=ON`，并在创建 context 时设置 `flash_attn = true`。这对长上下文和生成速度提升巨大。

### 4. 采样与上下文参数对齐
`llama-server` 和你的 FFI 调用可能使用了不同的默认参数，导致实际计算量不同。

| 参数 | 说明 | 建议 |
| :--- | :--- | :--- |
| `batch_size` | 单次处理的最大 token 数 | 设为 512 或 1024，与 server 对齐 |
| `ubatch_size` | 物理 batch size | 设为 512+，影响 GPU 利用率 |
| `ctx_size` | 上下文窗口大小 | 过大但未用满不影响速度，但若超过 KV Cache 限制会触发重算 |
| `sampling` | 采样器链 | 确认没有启用不必要的复杂采样器（如 min_p + top_k + top_p + tfs_z 全开） |

---

### 🔧 诊断步骤（按优先级执行）

1.  **对比日志**：分别运行 `llama-server` 和你的 Flutter App，对比启动日志中的 `n_threads`, `n_gpu_layers`, `flash_attn`, `batch_size` 是否完全一致。
2.  **Profiling**：在 C++ 侧添加计时器，测量纯 `llama_decode` 的耗时。如果 C++ 侧解码速度与 server 一致，但 Dart 侧显示慢 → **问题 100% 在 FFI 传输/UI 渲染**。如果 C++ 侧本身就慢 → 问题在编译/线程/参数。
3.  **最小化测试**：写一个纯 Dart CLI 程序（无 Flutter UI），用同样的 llamadart 调用同一个 .so/.dylib。如果 CLI 速度快而 Flutter App 慢 → 问题在 Flutter 调度/UI 阻塞。
4.  **更新 llamadart**：llamadart 迭代很快，确保使用最新版本。旧版本可能存在已修复的 FFI 性能问题。

### 💡 最新实现思路推荐

如果你希望彻底解决性能问题并获得最佳体验，考虑以下架构升级：

> **方案 A：Embedded Server 模式（强烈推荐）**
> 不再直接用 FFI 调 `llama_decode`，而是将 `llama-server` 编译为动态库，在 App 启动时作为一个嵌入式 HTTP 服务运行。Flutter 通过 localhost HTTP/SSE 与之通信。
> *   **优点**：完全复用 `llama-server` 的所有优化（包括 KV Cache 管理、并发请求、SSE 流式输出），性能与独立 server 100% 一致。
> *   **缺点**：多了一个进程/线程的管理复杂度。
> *   **参考**：`llama.cpp` 官方的 `server` example 可以直接嵌入。

> **方案 B：NativePort + Async FFI**
> 如果坚持直接 FFI 调用，使用 Dart 的 `NativePort` + C 侧的 `Dart_PostCObject_DL` 实现真正的异步非阻塞通信，避免 FFI Callback 阻塞 Native 推理线程。这是目前高性能 FFI 通信的标准范式。

**总结**：先做第 4 步的诊断，大概率你会发现要么 `n_gpu_layers` 没设对，要么 FFI 每个 token 都在做 String 转换。修复这两点后，速度应该能追平原生 server。如果仍有差距，直接切换到 Embedded Server 架构是最省心的终极方案。