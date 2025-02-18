package com.dzenm.nearby_services

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.location.LocationManager
import android.net.wifi.WifiManager
import android.net.wifi.p2p.WifiP2pManager
import android.provider.Settings
import android.util.Log

class WifiDirectManager(private val activity: Activity) {

    private val tag = "WiFiDirect"

    private val wifiManager: WifiP2pManager? by lazy(LazyThreadSafetyMode.NONE) {
        activity.getSystemService(Context.WIFI_P2P_SERVICE) as WifiP2pManager?
    }

    private var channel: WifiP2pManager.Channel? = null
    private var receiver: BroadcastReceiver? = null
    private var intentFilter: IntentFilter? = null

    /**
     * GPD是否开启
     */
    fun isGPSEnabled(): Boolean {
        val lm = activity.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val isOpenGPS = lm.isProviderEnabled(LocationManager.GPS_PROVIDER)
        val isOpenNetwork = lm.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
        return isOpenGPS && isOpenNetwork
    }

    /**
     * 进入位置设置页面
     */
    fun openLocationSettingsPage() {
        activity.startActivity(Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS))
    }

    /**
     * Wi-Fi是否开启
     */
    fun isWifiEnabled(): Boolean {
        val context = activity.applicationContext;
        val wm = context.getSystemService(Context.WIFI_SERVICE) as WifiManager
        return wm.isWifiEnabled
    }

    /**
     * 进入Wi-Fi设置页面
     */
    fun openWifiSettingsPage() {
        activity.startActivity(Intent(Settings.ACTION_WIFI_SETTINGS))
    }

    /**
     * 初始化Wi-Fi p2p
     */
    fun initialize() {
        // 1. 获取 WifiP2pManager 的实例，并通过调用 initialize() 将应用注册到 Wi-Fi P2P 框架
        channel = wifiManager?.initialize(activity, activity.mainLooper, null)
        channel?.also { channel ->
            receiver = WiFiDirectBroadcastReceiver(wifiManager!!, channel, activity)
        }

        // 2. 创建 intent 过滤器，然后添加与广播接收器检查内容相同的 intent
        intentFilter = IntentFilter().apply {
            addAction(WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION)
        }

        log("初始化Wi-Fi Manager并创建广播接收器和过滤器")
    }

    fun discoverPeers() {
        wifiManager?.discoverPeers(channel, object : WifiP2pManager.ActionListener {
            override fun onSuccess() {
                log("已发现设备")
            }

            override fun onFailure(reasonCode: Int) {
            }
        })
    }

    /**
     * 注册Wi-Fi广播监听器
     */
    fun register() {
        /* register the broadcast receiver with the intent values to be matched */
        // 3. 开始时，注册广播监听器
        receiver?.also { receiver ->
            activity.registerReceiver(receiver, intentFilter)
        }
    }

    /**
     * 取消注册Wi-Fi广播监听器
     */
    fun unregister() {
        /* unregister the broadcast receiver */
        // 结束时，取消注册广播监听器
        receiver?.also { receiver ->
            activity.unregisterReceiver(receiver)
        }
    }


    private fun log(msg: String) = Log.d(tag, msg)
}