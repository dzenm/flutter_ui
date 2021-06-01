package com.dzenm.flutter_ui

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.PersistableBundle
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
        Log.d(TAG, "====================configureFlutterEngine")
        registerWith(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        loadMethodChannel(messenger)
    }

    /**
     * 注册flutter第三方依赖初始化
     */
    private fun registerWith(flutterEngine: FlutterEngine) {
        // flutter sdk >= v1.17.0 时使用下面方法注册自定义plugin
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }

    /**
     * Android和flutter通信的方法通道
     */
    private fun loadMethodChannel(messenger: BinaryMessenger) {
        serviceIntent = Intent(this, MediaService::class.java)

        // flutter点击返回键的操作
        val backChannel = "android/channel/backToDesktop" // 通讯名称, 返回按钮对应的事件
        MethodChannel(messenger, backChannel).setMethodCallHandler { methodCall, result ->
            if (methodCall.method == "backToDesktop") {
                Log.d(TAG, "返回到主页")
                moveTaskToBack(false)
                result.success(true)
            }
        }

        // flutter启动Android服务
        val mediaServiceChannel = "android/channel/startVideoService" // 通讯名称, 启动服务对应的事件
        MethodChannel(messenger, mediaServiceChannel).setMethodCallHandler { methodCall, result ->
            if (methodCall.method == "startVideoService") {
                Log.d(TAG, "启动视频服务")
                startService()
                result.success("服务已启动")
            }
        }

        // flutter启动Android新Activity
        val startActivityChannel = "android/channel/startNaughtyActivity" // 通讯名称, 跳转页面对应的事件
        MethodChannel(messenger, startActivityChannel).setMethodCallHandler { methodCall, result ->
            if (methodCall.method == "startNaughtyActivity") {
                Log.d(TAG, "启动NaughtyActivity")
                if (methodCall.arguments != null) {
                    val title = methodCall.argument<String>("title")
                }
                startActivity(Intent(this, NaughtyActivity::class.java))
                result.success("启动新的Activity, 回调Flutter的结果")
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "====================onCreate")

        // ATTENTION: This was auto-generated to handle app links.
        val appLinkIntent = intent
        val appLinkAction = appLinkIntent.action
        val appLinkData = appLinkIntent.data
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "====================onDestroy")
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
