package com.dzenm.nearby_services

import android.net.NetworkInfo
import android.net.wifi.p2p.WifiP2pInfo
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * NearbyServicesPlugin
 * @see [https://developer.android.google.cn/develop/connectivity/wifi/wifip2p?hl=sl]
 * */
class NearbyServicesPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private val tag = "WiFiDirect"

    private lateinit var mManager: WifiDirectManager
    private lateinit var channel: MethodChannel
    private lateinit var discoverPeersChannel: EventChannel
    private lateinit var connectionChannel: EventChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "nearby_services")
        channel.setMethodCallHandler(this)
        discoverPeersChannel = EventChannel(flutterPluginBinding.binaryMessenger, "nearby_services_discover_peers")
        discoverPeersChannel.setStreamHandler(foundPeersHandler)
        connectionChannel = EventChannel(flutterPluginBinding.binaryMessenger, "nearby_services_connection")
        connectionChannel.setStreamHandler(connectedPeersHandler)
        mManager = WifiDirectManager(context)
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
                "createGroup" -> mManager.createGroup(result)
                "removeGroup" -> mManager.removeGroup(result)
//                "groupInfo" -> mManager.requestGroupInfo(result)
//                "fetchPeers" -> mManager.fetchPeers(result)
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
        discoverPeersChannel.setStreamHandler(null)
        connectionChannel.setStreamHandler(null)
    }

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity

    private val foundPeersHandler = object : EventChannel.StreamHandler {
        private var handler: Handler = Handler(Looper.getMainLooper())
        private var eventSink: EventChannel.EventSink? = null

        override fun onListen(p0: Any?, sink: EventChannel.EventSink) {
            eventSink = sink
            var peers: String = ""
            val r: Runnable = object : Runnable {
                override fun run() {
                    handler.post {
                        if (peers != discoverPeersChannel.toString()) {
                            peers = discoverPeersChannel.toString()
                            Log.d(tag, "NearbyServices Peers are " + Gson().toJson(discoverPeersChannel))
                            eventSink?.success(Gson().toJson(discoverPeersChannel))
                        }
                    }
                    handler.postDelayed(this, 1000)
                }
            }
            handler.postDelayed(r, 1000)
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
            var networkInfo: NetworkInfo? = null
            var wifiP2pInfo: WifiP2pInfo? = null
            val r: Runnable = object : Runnable {
                override fun run() {
                    handler.post {
                        val ni: NetworkInfo? = eNetworkInfo
                        val wi: WifiP2pInfo? = eWifiP2pInfo
                        if (ni != null && wi != null) {
                            if (networkInfo != ni && wifiP2pInfo != wi) {
                                networkInfo = ni
                                wifiP2pInfo = wi

                                val obj = object {
                                    // https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pGroup
                                    // methods
                                    val isConnected: Boolean = ni.isConnected
                                    val isGroupOwner: Boolean = wi.isGroupOwner
                                    val groupFormed: Boolean = wi.groupFormed
                                    val groupOwnerAddress: String = if (wi.groupOwnerAddress == null) "null" else wi.groupOwnerAddress.toString()
                                    val clients: List<Any> = groupClients
                                }
                                val json = Gson().toJson(obj)
                                Log.d(tag, "NearbyServices : connected peers=$json")
                                eventSink?.success(json)
                            }
                        }
                    }
                    handler.postDelayed(this, 1000)
                }
            }
            handler.postDelayed(r, 1000)
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
