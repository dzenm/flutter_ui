package com.dzenm.nearby_services

import android.Manifest
import android.app.Activity
import android.content.BroadcastReceiver
import android.content.ContentValues.TAG
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.location.LocationManager
import android.net.NetworkInfo
import android.net.wifi.WifiManager
import android.net.wifi.WpsInfo
import android.net.wifi.p2p.*
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.RequiresApi
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

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "nearby_services")
    channel.setMethodCallHandler(this)
    cFoundPeers = EventChannel(flutterPluginBinding.binaryMessenger, "nearby_services_foundPeers")
    cFoundPeers.setStreamHandler(foundPeersHandler)
    cConnectedPeers = EventChannel(flutterPluginBinding.binaryMessenger, "nearby_services_connectedPeers")
    cConnectedPeers.setStreamHandler(connectedPeersHandler)
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

  @RequiresApi(Build.VERSION_CODES.M)
  private  fun checkLocationPermission(result: Result) {
    if (activity.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
      && activity.checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED
    ) {
      result.success(true)
    } else {
      result.success(false)
    }
  }

  private fun askLocationPermission(result: Result) {
    val perms: Array<String> = arrayOf(
      Manifest.permission.ACCESS_FINE_LOCATION,
      Manifest.permission.ACCESS_COARSE_LOCATION,
    )
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      activity.requestPermissions(perms, 2468)
    }
    result.success(true)
  }

  private fun checkLocationEnabled(result: Result) {
    val lm: LocationManager = activity.getSystemService(Context.LOCATION_SERVICE) as LocationManager
    val isOpenGPS = lm.isProviderEnabled(LocationManager.GPS_PROVIDER)
    val isOpenNetwork = lm.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
    result.success("$isOpenGPS:$isOpenNetwork")
  }

  private fun checkGpsEnabled(result: Result) {
    val lm: LocationManager = activity.getSystemService(Context.LOCATION_SERVICE) as LocationManager
    val isOpenGPS = lm.isProviderEnabled(LocationManager.GPS_PROVIDER)
    val isOpenNetwork = lm.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
    result.success(isOpenGPS && isOpenNetwork)
  }

  private fun enableLocationServices(result: Result) {
    activity.startActivity(Intent(android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS))
    result.success(true)
  }

  private fun checkWifiEnabled(result: Result) {
    val wm: WifiManager = activity.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
    result.success(wm.isWifiEnabled)
  }

  private fun enableWifiServices(result: Result) {
    activity.startActivity(Intent(android.provider.Settings.ACTION_WIFI_SETTINGS))
    result.success(true)
  }

  private fun resume(result: Result) {
    receiver = object : BroadcastReceiver() {
      override fun onReceive(context: Context, intent: Intent) {
        val action: String? = intent.action
        when (action) {
          WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION -> {
            // Check to see if Wi-Fi is enabled and notify appropriate activity
            when (val state: Int = intent.getIntExtra(WifiP2pManager.EXTRA_WIFI_STATE, -1)) {
              WifiP2pManager.WIFI_P2P_STATE_ENABLED -> {
                // Wifi P2P is enabled
                Log.d(TAG, "NearbyServices: Wi-Fi state enabled, Int=${state}")
              }

              else -> {
                // Wi-Fi P2P is not enabled
                Log.d(TAG, "NearbyServices: Wi-Fi state disabled, Int=${state}")
              }
            }
          }
          WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION -> {
            // Call WifiP2pManager.requestPeers() to get a list of current peers
            peersListener()
          }

          WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION -> {
            // Respond to new connection or disconnections
            wifiManager.requestGroupInfo(wifiChannel) { group: WifiP2pGroup? ->
              if (group != null) {
                groupClients = deviceConsolidateList(group)
                Log.d(TAG, "NearbyServices :  group clients $groupClients")
              }
            }
            val networkInfo: NetworkInfo? = intent.getParcelableExtra(WifiP2pManager.EXTRA_NETWORK_INFO)
            val wifiP2pInfo: WifiP2pInfo? = intent.getParcelableExtra(WifiP2pManager.EXTRA_WIFI_P2P_INFO)
            if (networkInfo != null && wifiP2pInfo != null) {
              eNetworkInfo = networkInfo
              eWifiP2pInfo = wifiP2pInfo
//                            object {
//                                // methods called on object before sending through channel
//                                val connected: Boolean = networkInfo.isConnected
//                                val isGroupOwner: Boolean = wifiP2pInfo.isGroupOwner
//                                val groupOwnerAddress: String = if (wifiP2pInfo.groupOwnerAddress == null) "" else wifiP2pInfo.groupOwnerAddress.toString()
//                                val groupFormed: Boolean = wifiP2pInfo.groupFormed
//                                val clients: List<Any> = groupClients
//                            }
              Log.d(TAG, "NearbyServices: connectionInfo={connected: ${networkInfo.isConnected}, " +
                      "isGroupOwner: ${wifiP2pInfo.isGroupOwner}, " +
                      "groupOwnerAddress: ${wifiP2pInfo.groupOwnerAddress}, " +
                      "groupFormed: ${wifiP2pInfo.groupFormed}, " +
                      "clients: ${groupClients}}")
            }
          }

          WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION -> {
            // Respond to this device's wifi state changing
          }
        }
      }
    }
    activity.registerReceiver(receiver, intentFilter)
    //Log.d(TAG, "NearbyServices: Initialized wifi p2p connection")
    result.success(true)
  }

  private fun pause(result: Result) {
    activity.unregisterReceiver(receiver)
    //Log.d(TAG, "NearbyServices: paused wifi p2p connection receiver")
    result.success(true)
  }

  private fun initializeWifiP2PConnections(result: Result) {
    intentFilter.addAction(WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION)
    intentFilter.addAction(WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION)
    intentFilter.addAction(WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION)
    intentFilter.addAction(WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION)
    wifiManager = activity.getSystemService(Context.WIFI_P2P_SERVICE) as WifiP2pManager
    wifiChannel = wifiManager.initialize(activity, Looper.getMainLooper()) {
      Log.d(TAG, "NearbyServices: ChannelListener -> onChannelDisconnected")
    }
    result.success(true)
  }

  private fun createGroup(result: Result) {
    wifiManager.createGroup(wifiChannel, object : WifiP2pManager.ActionListener {
      override fun onSuccess() {
        Log.d(TAG, "NearbyServices: Created wifi p2p group")
        result.success(true)
      }

      override fun onFailure(reasonCode: Int) {
        Log.d(TAG, "NearbyServices: failed to create group, reasonCode=${reasonCode}")
        result.success(false)
      }
    })
  }

  private fun removeGroup(result: Result) {
    wifiManager.removeGroup(wifiChannel, object : WifiP2pManager.ActionListener {
      override fun onSuccess() {
        Log.d(TAG, "NearbyServices: removed wifi p2p group")
        result.success(true)
      }

      override fun onFailure(reasonCode: Int) {
        Log.d(TAG, "NearbyServices: failed to remove group, reasonCode=${reasonCode}")
        result.success(false)
      }
    })
  }

  fun deviceConsolidateList(group: WifiP2pGroup): List<Any> {
    val list: MutableList<Any> = mutableListOf()
    for (device: WifiP2pDevice in group.clientList) {
      list.add(deviceConsolidated(device))
    }
    return list
  }

  private fun deviceConsolidated(device: WifiP2pDevice): Any {
    val dev = object {
      // from https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pDevice
      val deviceName: String = device.deviceName
      val deviceAddress: String = device.deviceAddress
      val primaryDeviceType: String? = device.primaryDeviceType
      val secondaryDeviceType: String? = device.secondaryDeviceType
      val status: Int = device.status

      // methods called on object before sending through channel
      val isGroupOwner: Boolean = device.isGroupOwner
      val isServiceDiscoveryCapable: Boolean = device.isServiceDiscoveryCapable
      val wpsDisplaySupported: Boolean = device.wpsDisplaySupported()
      val wpsKeypadSupported: Boolean = device.wpsKeypadSupported()
      val wpsPbcSupported: Boolean = device.wpsPbcSupported()
    }
    return dev
  }

  private fun requestGroupInfo(result: Result) {
    wifiManager.requestGroupInfo(wifiChannel) { group: WifiP2pGroup? ->
      if (group != null) {
        val obj = object {
          // https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pGroup
          val isGroupOwner: Boolean = group.isGroupOwner
          val passPhrase: String? = group.passphrase
          val groupNetworkName: String = group.networkName
          val clients: List<Any> = deviceConsolidateList(group)
        }
        val json = Gson().toJson(obj)
        Log.d(TAG, "NearbyServices:  group=$json")
        result.success(json)
      }
    }
  }

  private fun discoverPeers(result: Result) {
    wifiManager.discoverPeers(wifiChannel, object : WifiP2pManager.ActionListener {
      override fun onSuccess() {
        Log.d(TAG, "NearbyServices: discovering wifi p2p devices")
        result.success(true)
      }

      override fun onFailure(reasonCode: Int) {
        Log.d(TAG, "NearbyServices: discovering wifi p2p devices failed, reasonCode=${reasonCode}")
        result.success(false)
      }
    })
  }

  private fun stopPeerDiscovery(result: Result) {
    wifiManager.stopPeerDiscovery(wifiChannel, object : WifiP2pManager.ActionListener {
      override fun onSuccess() {
        Log.d(TAG, "NearbyServices: stopped discovering wifi p2p devices")
        result.success(true)
      }

      override fun onFailure(reasonCode: Int) {
        Log.e(TAG, "NearbyServices: failed to stop discovering wifi p2p devices, reasonCode=${reasonCode}")
        Log.e(TAG, "NearbyServices: see https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pManager.ActionListener#onFailure(int) for codes")
        result.success(false)
      }
    })
  }

  private fun connect(result: Result, address: String) {
    val config = WifiP2pConfig()
    config.deviceAddress = address
    config.wps.setup = WpsInfo.PBC
    wifiChannel.also { wifiChannel: WifiP2pManager.Channel ->
      wifiManager.connect(wifiChannel, config, object : WifiP2pManager.ActionListener {
        override fun onSuccess() {
          Log.d(TAG, "NearbyServices: connected to wifi p2p device, address=${address}")
          result.success(true)
        }

        override fun onFailure(reasonCode: Int) {
          Log.e(TAG, "NearbyServices: connection to wifi p2p device failed, reasonCode=${reasonCode}")
          result.success(false)
        }
      })
    }
  }

  private fun disconnect(result: Result) {
    wifiManager.cancelConnect(wifiChannel, object : WifiP2pManager.ActionListener {
      override fun onSuccess() {
        Log.d(TAG, "NearbyServices disconnect from wifi p2p connection: true")
        result.success(true)
      }

      override fun onFailure(reasonCode: Int) {
        Log.e(TAG, "NearbyServices disconnect from wifi p2p connection: false, $reasonCode")
        result.success(false)
      }
    })
  }

  private fun fetchPeers(result: Result) {
    result.success(Gson().toJson(eFoundPeers))
  }

  fun peersListener() {
    wifiManager.requestPeers(wifiChannel) { peers: WifiP2pDeviceList ->
      val list: MutableList<Any> = mutableListOf()
      for (device: WifiP2pDevice in peers.deviceList) {
        list.add(deviceConsolidated(device))
      }
      eFoundPeers = list
      Log.d(TAG, "NearbyServices : Peers  " + Gson().toJson(eFoundPeers))
    }
  }

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

  override fun onDetachedFromActivity() {}
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
  }
}
