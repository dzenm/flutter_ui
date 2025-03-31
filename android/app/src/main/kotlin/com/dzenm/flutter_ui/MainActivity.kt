package com.dzenm.flutter_ui

import android.os.Bundle
import com.dzenm.flutter_ui.plugins.FlutterPluginManager
import com.dzenm.flutter_ui.study.JavaStudy
import com.dzenm.flutter_ui.study.KotlinStudy
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {

    companion object {
        private val TAG = MainActivity::class.java.simpleName
    }

    private val manager = FlutterPluginManager()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        Log.d(TAG, "════════════════════════════════════════ configureFlutterEngine: ${System.currentTimeMillis()}")
        flutterEngine.let {
            // 注册flutter第三方依赖初始化
            GeneratedPluginRegistrant.registerWith(flutterEngine)
            val messenger = it.dartExecutor.binaryMessenger
            manager.register(messenger, this)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "════════════════════════════════════════ onCreate: ${System.currentTimeMillis()}")

        JavaStudy.main()
        KotlinStudy.main()
    }

    override fun onResume() {
        super.onResume()
        Log.d(TAG, "════════════════════════════════════════ onResume")
    }

    override fun onPause() {
        super.onPause()
        Log.d(TAG, "════════════════════════════════════════ onPause")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "════════════════════════════════════════ onDestroy")
    }

    override fun onRequestPermissionsResult(
        requestCode: Int, permissions: Array<out String>, grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        manager.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }
}
