package com.dzenm.nearby_services

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.location.LocationManager
import android.net.wifi.WifiManager
import android.net.wifi.p2p.WifiP2pConfig
import android.net.wifi.p2p.WifiP2pDevice
import android.net.wifi.p2p.WifiP2pInfo
import android.net.wifi.p2p.WifiP2pManager
import android.provider.Settings
import android.util.Log
import io.flutter.plugin.common.MethodChannel

class WifiDirectManager(private val context: Context) {

    private val tag = "WiFiDirect"

    private val wifiManager: WifiP2pManager? by lazy(LazyThreadSafetyMode.NONE) {
        context.getSystemService(Context.WIFI_P2P_SERVICE) as WifiP2pManager?
    }
    private var wifiChannel: WifiP2pManager.Channel? = null

    private var receiver: BroadcastReceiver? = null
    private var intentFilter: IntentFilter? = null

    private val peers = mutableListOf<WifiP2pDevice>()

    /**
     * GPS是否开启
     */
    fun isGPSEnabled(result: MethodChannel.Result): Boolean {
        val lm = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val isOpenGPS = lm.isProviderEnabled(LocationManager.GPS_PROVIDER)
        val isOpenNetwork = lm.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
        result.success(isOpenGPS && isOpenNetwork)
        return isOpenGPS && isOpenNetwork
    }

    /**
     * 进入位置设置页面
     */
    fun openLocationSettingsPage(result: MethodChannel.Result) {
        try {
            context.startActivity(Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS))
            result.success(true)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    /**
     * Wi-Fi是否开启
     */
    fun isWifiEnabled(result: MethodChannel.Result): Boolean {
        val context = context.applicationContext;
        val wm = context.getSystemService(Context.WIFI_SERVICE) as WifiManager
        result.success(wm.isWifiEnabled)
        return wm.isWifiEnabled
    }

    /**
     * 进入Wi-Fi设置页面
     */
    fun openWifiSettingsPage(result: MethodChannel.Result) {
        try {
            context.startActivity(Intent(Settings.ACTION_WIFI_SETTINGS))
            result.success(true)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    /**
     * 初始化Wi-Fi p2p
     */
    fun initialize(result: MethodChannel.Result) {
        // 1. 获取 WifiP2pManager 的实例，并通过调用 initialize() 将应用注册到 Wi-Fi P2P 框架
        wifiChannel = wifiManager?.initialize(context, context.mainLooper, null)
        receiver = WiFiDirectBroadcastReceiver(this)

        // 2. 创建 intent 过滤器，然后添加与广播接收器检查内容相同的 intent
        // 在搭载 Android 10 及更高版本的设备上，以下广播 intent 是非粘性 intent：
        // WIFI_P2P_CONNECTION_CHANGED_ACTION
        //
        intentFilter = IntentFilter().apply {
            addAction(WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION)
        }
        result.success(true)
        log("初始化Wi-Fi Manager并创建广播接收器和过滤器")
    }

    /**
     * 注册Wi-Fi广播监听器
     */
    fun register(result: MethodChannel.Result) {
        /* register the broadcast receiver with the intent values to be matched */
        // 3. 开始时，注册广播监听器
        receiver?.also { receiver ->
            context.registerReceiver(receiver, intentFilter)
            result.success(true)
        }
    }

    /**
     * 取消注册Wi-Fi广播监听器
     */
    fun unregister(result: MethodChannel.Result) {
        /* unregister the broadcast receiver */
        // 结束时，取消注册广播监听器
        receiver?.also { receiver ->
            context.unregisterReceiver(receiver)
            result.success(true)
        }
    }

    /**
     * 发现设备
     */
    fun discoverPeers() {
        // 成功检测到对等设备存在时，系统会广播 WIFI_P2P_PEERS_CHANGED_ACTION 意向
        wifiChannel?.also { channel ->
            wifiManager?.discoverPeers(channel, object : WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    // 仅通知发现进程已成功
                    log("已启动发现进程")
                }

                override fun onFailure(reasonCode: Int) {
                    // 仅通知发现进程启动失败
                    log("发现进程启动失败：$reasonCode")
                }
            })
        }
    }

    /**
     * 停止设备扫描
     */
    fun stopPeerDiscovery(result: MethodChannel.Result) {
        wifiChannel?.also { channel ->
            wifiManager?.stopPeerDiscovery(channel, object : WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    result.success(true)
                }

                override fun onFailure(reasonCode: Int) {
                    Log.e(tag, "see https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pManager.ActionListener#onFailure(int) for codes")
                    result.success(false)
                }
            })
        }
    }

    /**
     * 请求已发现设备的列表
     */
    fun requestPeers() {
        wifiChannel?.also { channel ->
            wifiManager?.requestPeers(channel) { peers ->
                // Handle peers list
                for (device: WifiP2pDevice in peers.deviceList) {
                    device.deviceName
                }
            }
        }
    }

    /**
     * 连接到设备
     */
    fun connect(deviceAddress: String, result: MethodChannel.Result) {
        val config = WifiP2pConfig()
        config.deviceAddress = deviceAddress
        wifiChannel?.also { channel ->
            // connect方法在随后将自动创建群组并选择群组所有者
            wifiManager?.connect(channel, config, object : WifiP2pManager.ConnectionInfoListener, WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    //success logic
                    result.success(true)
                }

                override fun onFailure(reason: Int) {
                    //failure logic
                    result.success(false)
                }

                override fun onConnectionInfoAvailable(info: WifiP2pInfo?) {
                }
            })
        }
    }

    /**
     * 断开设备连接
     */
    fun disconnect(result: MethodChannel.Result) {
        wifiChannel?.also { channel ->
            wifiManager?.cancelConnect(channel, object : WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    result.success(true)
                }

                override fun onFailure(reasonCode: Int) {
                    result.success(false)
                }
            })
        }
    }

    /**
     * 创建群组
     */
    fun createGroup(result: MethodChannel.Result) {
        wifiChannel?.also { channel ->
            wifiManager?.createGroup(channel, object : WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    result.success(true)
                }

                override fun onFailure(reasonCode: Int) {
                    result.success(false)
                }
            })
        }
    }

    /**
     * 移除群组
     */
    fun removeGroup(result: MethodChannel.Result) {
        wifiChannel?.also { channel ->
            wifiManager?.removeGroup(channel, object : WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    result.success(true)
                }

                override fun onFailure(reasonCode: Int) {
                    result.success(false)
                }
            })
        }

    }

    private fun log(msg: String) = Log.d(tag, msg)
}
