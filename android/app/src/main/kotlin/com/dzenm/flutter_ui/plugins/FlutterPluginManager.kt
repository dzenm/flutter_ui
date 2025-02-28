package com.dzenm.flutter_ui.plugins

import android.app.Activity
import android.widget.Toast
import io.flutter.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class FlutterPluginManager {

    companion object {
        const val FLUTTER_CHANNEL = "flutter_ui/channel/" // 通讯名称
        const val METHOD_BACK_TO_DESKTOP = "backToDesktop"
        const val METHOD_INSTALL_APK = "installAPK"
        const val METHOD_OPEN_WIFI_HOTSPOT = "openWifiHotspot"
    }

    private lateinit var wifiHotspot: WifiHotspot

    /**
     * Android和flutter通信的方法通道
     */
    fun register(messenger: BinaryMessenger, activity: Activity) {
        // 监听flutter的指令调用
        MethodChannel(messenger, FLUTTER_CHANNEL).setMethodCallHandler { methodCall, result ->
            queryChannelMethod(activity, methodCall, result)
        }
        wifiHotspot = WifiHotspot(activity)
    }

    private fun queryChannelMethod(activity: Activity, methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            METHOD_BACK_TO_DESKTOP -> {
                log("Flutter调用原生方法：返回到主页")
                val res = activity.moveTaskToBack(false)
                result.success(res)
            }

            METHOD_INSTALL_APK -> {
                log("Flutter调用原生方法：安装APK")
                val filePath = methodCall.argument<String>("filePath")
                if (filePath.isNullOrEmpty()) {
                    Toast.makeText(activity, "文件路径不能为空", Toast.LENGTH_SHORT).show();
                } else {
                    InstallAPKPlugin().openFile(activity, File(filePath))
                }
            }

            METHOD_OPEN_WIFI_HOTSPOT -> {
                log("Flutter调用原生方法：打开热点")
                wifiHotspot.open()
            }
        }
    }

    fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        wifiHotspot.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    /**
     * 日志打印
     */
    private fun log(msg: String) {
        Log.d("FlutterPluginManager", msg)
    }
}