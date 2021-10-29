package com.example.channel_monitor_example

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.random.Random

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "siyehua")
        channel.setMethodCallHandler { call, result ->
            if (call.method == "login") {
                Thread.sleep(Random.nextLong(100))
                result.success("")
            }
        }
    }
}
