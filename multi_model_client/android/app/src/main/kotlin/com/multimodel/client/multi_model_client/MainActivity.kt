package com.multimodel.client.multi_model_client

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 注册硬件检查器插件
        flutterEngine.plugins.add(HardwareCheckerPlugin())
    }
}
