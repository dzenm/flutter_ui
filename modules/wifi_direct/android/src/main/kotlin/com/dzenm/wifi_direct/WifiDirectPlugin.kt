package com.dzenm.wifi_direct

import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.lang.ref.WeakReference

/**
 * WifiDirectPlugin
 * @see [https://developer.android.google.cn/develop/connectivity/wifi/wifip2p?hl=sl]
 */
class WifiDirectPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var mManager: WifiDirectManager
    private lateinit var connectionChannel: EventChannel
    private val connection: WeakReference<WifiDirectStream> by lazy(LazyThreadSafetyMode.NONE) {
        WeakReference<WifiDirectStream>(WifiDirectStream())
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wifi_direct")
        channel.setMethodCallHandler(this)
        connectionChannel = EventChannel(flutterPluginBinding.binaryMessenger, "wifi_direct_stream")
        connectionChannel.setStreamHandler(connection.get())
        mManager = WifiDirectManager(context, connection)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        try {
            when (call.method) {
                "getPlatformVersion" -> result.success(Build.VERSION.RELEASE)
                "getPlatformSDKVersion" -> result.success(Build.VERSION.SDK_INT)
                "getPlatformModel" -> result.success(Build.MODEL)
                "initialize" -> mManager.initialize(result)
                "register" -> mManager.register(result)
                "unregister" -> mManager.unregister(result)
                "addLocalService" -> mManager.addLocalService(
                    call.argument("instanceName") ?: "",
                    call.argument("serviceType") ?: "",
                    call.argument("json") ?: emptyMap(),
                    result,
                )
                "discoverPeers" -> mManager.discoverPeers(result)
                "stopPeerDiscovery" -> mManager.stopPeerDiscovery(result)
                "requestPeers" -> mManager.requestPeers(result)
                "connect" -> mManager.connect(call.argument("address") ?: "", result)
                "disconnect" -> mManager.disconnect(result)
                "requestGroup" -> mManager.requestGroup(result)
                "createGroup" -> mManager.createGroup(result)
                "removeGroup" -> mManager.removeGroup(result)
                "isGPSEnabled" -> mManager.isGPSEnabled(result)
                "openLocationSettingsPage" -> mManager.openLocationSettingsPage(result)
                "isWifiEnabled" -> mManager.isWifiEnabled(result)
                "openWifiSettingsPage" -> mManager.openWifiSettingsPage(result)
                else -> {
                    result.notImplemented()
                }
            }
        } catch (e: Exception) {
            result.error("Error：", " $e", e)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        connectionChannel.setStreamHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }
}
