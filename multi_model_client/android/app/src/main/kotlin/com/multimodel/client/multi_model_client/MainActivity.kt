package com.multimodel.client.multi_model_client

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.multimodel.client/share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 注册硬件检查器插件
        flutterEngine.plugins.add(HardwareCheckerPlugin())

        // 注册分享通道
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSharedText" -> {
                    result.success(intent.getStringExtra(Intent.EXTRA_TEXT))
                }
                "getSharedUrl" -> {
                    result.success(intent.data?.toString())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // 处理分享 Intent
        handleShareIntent(intent)
    }

    override fun onResume() {
        super.onResume()
        // 处理启动时的分享 Intent
        handleShareIntent(intent)
    }

    private fun handleShareIntent(intent: Intent?) {
        if (intent == null) return

        when (intent.action) {
            Intent.ACTION_SEND -> {
                if (intent.type?.startsWith("text/") == true) {
                    val sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
                    val sharedUrl = intent.data?.toString()
                    // 通过 MethodChannel 通知 Flutter
                    MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger ?: return, CHANNEL).invokeMethod(
                        "onShareReceived",
                        mapOf("text" to sharedText, "url" to sharedUrl)
                    )
                }
            }
            Intent.ACTION_SEND_MULTIPLE -> {
                // 处理多文件分享
            }
        }
    }
}