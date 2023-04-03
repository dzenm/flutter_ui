package com.dzenm.flutter_ui

import android.os.Bundle
import com.dzenm.flutter_ui.study.JavaStudy
import com.dzenm.flutter_ui.study.KotlinStudy
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

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        Log.d(TAG, "════════════════════════════════════════ configureFlutterEngine: ${System.currentTimeMillis()}")
        flutterEngine.let {
            registerWith(it)
            val messenger = it.dartExecutor.binaryMessenger
            loadMethodChannel(messenger)
        }
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
        val channel = "flutter_ui/channel/" // 通讯名称, 返回按钮对应的事件

        // 监听flutter的指令调用
        MethodChannel(messenger, channel).setMethodCallHandler { methodCall, result ->
            when (methodCall.method) {
                "backToDesktop" -> {
                    Log.d(TAG, "返回到主页")
                    moveTaskToBack(false)
                    result.success(true)
                }
                "startVideoService" -> {
                    Log.d(TAG, "启动视频服务")
                    result.success("服务已启动")
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "════════════════════════════════════════ onCreate: ${System.currentTimeMillis()}")

        // ATTENTION: This was auto-generated to handle app links.
        val appLinkIntent = intent
        val appLinkAction = appLinkIntent.action
        val appLinkData = appLinkIntent.data

        JavaStudy.main()
        KotlinStudy.main()
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "════════════════════════════════════════ onDestroy")
    }
}
