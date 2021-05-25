package com.dzenm.flutter_ui

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity

class NaughtyActivity : FlutterActivity() {

    companion object {
        private val TAG = NaughtyActivity::class.java.simpleName
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "====================onCreate")
        startActivity(withNewEngine().initialRoute("naughty/homePage").build(this))
    }

    override fun onStart() {
        super.onStart()
        Log.d(TAG, "====================onStart")
    }

    override fun onStop() {
        super.onStop()
        Log.d(TAG, "====================onStop")
    }


    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "====================onDestroy")
    }
}