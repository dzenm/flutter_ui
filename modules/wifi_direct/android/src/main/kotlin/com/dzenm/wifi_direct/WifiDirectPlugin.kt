package com.dzenm.wifi_direct

import android.os.Build
import android.os.Handler
import android.os.Looper
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

    private val tag = "WiFiDirect"

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var mManager: WifiDirectManager
    private lateinit var connectionChannel: EventChannel
    private val connection: WeakReference<ConnectionStream> by lazy(LazyThreadSafetyMode.NONE) {
        WeakReference<ConnectionStream>(ConnectionStream())
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wifi_direct")
        channel.setMethodCallHandler(this)
        connectionChannel = EventChannel(flutterPluginBinding.binaryMessenger, "wifi_direct_connection")
        connectionChannel.setStreamHandler(connection.get())
        mManager = WifiDirectManager(context, connection)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        try {
            when (call.method) {
                "getPlatformVersion" -> result.success("Android: ${Build.VERSION.RELEASE}")
                "getPlatformModel" -> result.success("model: ${Build.MODEL}")
                "initialize" -> mManager.initialize(result)
                "register" -> mManager.register(result)
                "unregister" -> mManager.unregister(result)
                "discover" -> mManager.discoverPeers()
                "stopDiscovery" -> mManager.stopPeerDiscovery(result)
                "connect" -> {
                    val address: String = call.argument("address") ?: ""
                    mManager.connect(address, result)
                }

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

    private val foundPeersHandler = object : EventChannel.StreamHandler {
        private var handler: Handler = Handler(Looper.getMainLooper())
        private var eventSink: EventChannel.EventSink? = null

        override fun onListen(p0: Any?, sink: EventChannel.EventSink) {
            eventSink = sink
            val runnable: Runnable = object : Runnable {
                override fun run() {
                    handler.post {
                        val json = mManager.getDevices()
                        eventSink?.success(json)
                    }
                    handler.postDelayed(this, 1000)
                }
            }
            handler.postDelayed(runnable, 1000)
        }

        override fun onCancel(p0: Any?) {
            eventSink = null
        }
    }

    private val connectedPeersHandler = object : EventChannel.StreamHandler {
        private var handler: Handler = Handler(Looper.getMainLooper())
        private var eventSink: EventChannel.EventSink? = null

        override fun onListen(p0: Any?, sink: EventChannel.EventSink) {
            eventSink = sink
            val runnable: Runnable = object : Runnable {
                override fun run() {
                    handler.post {
                        val json = mManager.getWifiP2PInfo()
                        eventSink?.success(json)
                    }
                    handler.postDelayed(this, 1000)
                }
            }
            handler.postDelayed(runnable, 1000)
        }

        override fun onCancel(p0: Any?) {
            eventSink = null
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }
}
