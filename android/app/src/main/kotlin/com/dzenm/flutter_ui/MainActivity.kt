package com.dzenm.flutter_ui

import android.content.Intent
import android.os.Build
import android.os.Bundle
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {

    companion object {
        private val TAG = MainActivity::class.java.simpleName
    }

    private var serviceIntent: Intent? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        Log.d(TAG, "configureFlutterEngine")
        registerWith(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        loadMethodChannel(messenger)
    }

    private fun registerWith(flutterEngine: FlutterEngine) {
        // flutter sdk >= v1.17.0 时使用下面方法注册自定义plugin
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }

    private fun loadMethodChannel(messenger: BinaryMessenger) {
        // 点击返回键对应的
        val backChannel = "android/back/desktop" // 通讯名称, 返回按钮对应的事件
        MethodChannel(messenger, backChannel).setMethodCallHandler { methodCall, result ->
            if (methodCall.method == "moveTaskToBack") {
                result.success(true)
                moveTaskToBack(false)
            }
        }
        serviceIntent = Intent(this, MediaService::class.java)
        val mediaServiceChannel = "android/media/service"
        MethodChannel(messenger, mediaServiceChannel).setMethodCallHandler { methodCall, result ->
            if (methodCall.method == "startService") {
                startService()
                result.success("服务已启动")
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "onCreate")

        // ATTENTION: This was auto-generated to handle app links.
        val appLinkIntent = intent
        val appLinkAction = appLinkIntent.action
        val appLinkData = appLinkIntent.data
    }

    override fun onDestroy() {
        super.onDestroy()
        stopService(serviceIntent)
    }

    private fun startService() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }
    }
}
