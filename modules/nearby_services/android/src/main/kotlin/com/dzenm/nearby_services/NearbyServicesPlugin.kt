package com.dzenm.nearby_services

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.ContentValues.TAG
import android.content.IntentFilter
import android.net.NetworkInfo
import android.net.wifi.p2p.*
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
import java.util.*

/**
 * NearbyServicesPlugin
 * @see [https://developer.android.google.cn/develop/connectivity/wifi/wifip2p?hl=sl]
 * */
class NearbyServicesPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    lateinit var mManager: WifiDirectManager

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "nearby_services")
        channel.setMethodCallHandler(this)
        cFoundPeers = EventChannel(flutterPluginBinding.binaryMessenger, "nearby_services_foundPeers")
        cFoundPeers.setStreamHandler(foundPeersHandler)
        cConnectedPeers = EventChannel(flutterPluginBinding.binaryMessenger, "nearby_services_connectedPeers")
        cConnectedPeers.setStreamHandler(connectedPeersHandler)
        mManager = WifiDirectManager(context)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        try {
            when (call.method) {
                "getPlatformVersion" -> result.success("Android: ${Build.VERSION.RELEASE}")
                "getPlatformModel" -> result.success("model: ${Build.MODEL}")
                "initialize" -> initializeWifiP2PConnections(result)
                "discover" -> discoverPeers(result)
                "stopDiscovery" -> stopPeerDiscovery(result)
                "connect" -> {
                    val address: String = call.argument("address") ?: ""
                    connect(result, address)
                }

                "disconnect" -> disconnect(result)
                "createGroup" -> createGroup(result)
                "removeGroup" -> removeGroup(result)
                "groupInfo" -> requestGroupInfo(result)
                "fetchPeers" -> fetchPeers(result)
                "resume" -> resume(result)
                "pause" -> pause(result)
                "checkLocationPermission" -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    checkLocationPermission(result)
                }

                "askLocationPermission" -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    askLocationPermission(result)
                }

                "checkLocationEnabled" -> checkLocationEnabled(result)
                "checkGpsEnabled" -> checkGpsEnabled(result)
                "enableLocationServices" -> enableLocationServices(result)
                "checkWifiEnabled" -> checkWifiEnabled(result)
                "enableWifiServices" -> enableWifiServices(result)
                else -> {
                    result.notImplemented()
                }
            }
        } catch (e: Exception) {
            result.error("Err>>:", " $e", e)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        cFoundPeers.setStreamHandler(null)
        cConnectedPeers.setStreamHandler(null)
    }

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var activity: Activity
    private val intentFilter = IntentFilter()
    lateinit var wifiManager: WifiP2pManager
    lateinit var wifiChannel: WifiP2pManager.Channel
    private var receiver: BroadcastReceiver? = null
    var eFoundPeers: MutableList<Any> = mutableListOf()
    private lateinit var cFoundPeers: EventChannel
    var eNetworkInfo: NetworkInfo? = null
    var eWifiP2pInfo: WifiP2pInfo? = null
    private lateinit var cConnectedPeers: EventChannel
    var groupClients: List<Any> = mutableListOf()

    private val foundPeersHandler = object : EventChannel.StreamHandler {
        private var handler: Handler = Handler(Looper.getMainLooper())
        private var eventSink: EventChannel.EventSink? = null

        override fun onListen(p0: Any?, sink: EventChannel.EventSink) {
            eventSink = sink
            var peers: String = ""
            val r: Runnable = object : Runnable {
                override fun run() {
                    handler.post {
                        if (peers != eFoundPeers.toString()) {
                            peers = eFoundPeers.toString()
                            Log.d(TAG, "NearbyServices Peers are " + Gson().toJson(eFoundPeers))
                            eventSink?.success(Gson().toJson(eFoundPeers))
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
                                Log.d(TAG, "NearbyServices : connected peers=$json")
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
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }
}
