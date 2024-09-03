package com.dzenm.flutter_ui

import io.flutter.Log
import io.flutter.app.FlutterApplication

class MyApplication : FlutterApplication() {

    override fun onCreate() {
        Log.d("MyApplication", "════════════════════════════════════════ onCreate: ${System.currentTimeMillis()}")
        super.onCreate()
    }
}