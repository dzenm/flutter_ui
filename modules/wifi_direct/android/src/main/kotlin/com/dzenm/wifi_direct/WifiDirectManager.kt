package com.dzenm.wifi_direct

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.location.LocationManager
import android.net.NetworkInfo
import android.net.wifi.WifiManager
import android.net.wifi.p2p.WifiP2pConfig
import android.net.wifi.p2p.WifiP2pDevice
import android.net.wifi.p2p.WifiP2pGroup
import android.net.wifi.p2p.WifiP2pInfo
import android.net.wifi.p2p.WifiP2pManager
import android.os.Build
import android.os.Looper
import android.provider.Settings
import android.util.Log
import com.google.gson.Gson
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference

class WifiDirectManager(
    private val context: Context,
    connection: WeakReference<WifiDirectStream>,
) : P2pConnectionListener {

    private val wifiManager: WifiP2pManager by lazy(LazyThreadSafetyMode.NONE) {
        context.getSystemService(Context.WIFI_P2P_SERVICE) as WifiP2pManager
    }
    private var wifiChannel: WifiP2pManager.Channel? = null
    private var receiver: WiFiDirectBroadcastReceiver? = null

    private var conn = connection.get()

    ////////////////////////////////////////////////////////////////////////////

    /**
     * GPS是否开启
     */
    fun isGPSEnabled(result: MethodChannel.Result): Boolean {
        val lm = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val isOpenGPS = lm.isProviderEnabled(LocationManager.GPS_PROVIDER)
        val isOpenNetwork = lm.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
        result.success(isOpenGPS && isOpenNetwork)
        log("GPS是否开启：${isOpenGPS && isOpenNetwork}")
        return isOpenGPS && isOpenNetwork
    }

    /**
     * 进入位置设置页面
     */
    fun openLocationSettingsPage(result: MethodChannel.Result) {
        try {
            context.startActivity(Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS))
            log("进入位置设置页面")
            result.success(true)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    /**
     * Wi-Fi是否开启
     */
    fun isWifiEnabled(result: MethodChannel.Result): Boolean {
        val context = context.applicationContext
        val wm = context.getSystemService(Context.WIFI_SERVICE) as WifiManager
        result.success(wm.isWifiEnabled)
        log("Wi-Fi是否开启：${wm.isWifiEnabled}")
        return wm.isWifiEnabled
    }

    /**
     * 进入Wi-Fi设置页面
     */
    fun openWifiSettingsPage(result: MethodChannel.Result) {
        try {
            context.startActivity(Intent(Settings.ACTION_WIFI_SETTINGS))
            result.success(true)
            log("进入Wi-Fi设置页面")
        } catch (e: Exception) {
            result.success(false)
        }
    }

    /**
     * 初始化Wi-Fi p2p
     */
    fun initialize(result: MethodChannel.Result) {
        // 1. 获取 WifiP2pManager 的实例，并通过调用 initialize() 将应用注册到 Wi-Fi P2P 框架
        wifiChannel = wifiManager.initialize(context, Looper.getMainLooper(), null)
        receiver = WiFiDirectBroadcastReceiver(this, this)
        result.success(true)
        log("初始化Wi-Fi Manager并创建广播接收器和过滤器")
    }

    /**
     * 注册Wi-Fi广播监听器
     */
    fun register(result: MethodChannel.Result) {
        /* register the broadcast receiver with the intent values to be matched */

        // 2. 创建 intent 过滤器，然后添加与广播接收器检查内容相同的 intent
        // 在搭载 Android 10 及更高版本的设备上，以下广播 intent 是非粘性 intent：
        // WIFI_P2P_CONNECTION_CHANGED_ACTION
        //
        val intentFilter = IntentFilter().apply {
            addAction(WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION)
        }

        // 3. 开始时，注册广播监听器
        receiver?.also { receiver ->
            context.registerReceiver(receiver, intentFilter)
            result.success(true)
            log("注册Wi-Fi广播监听器")
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
            log("取消注册Wi-Fi广播监听器")
        }
    }

    /**
     * 启动扫描设备进程
     */
    fun discoverPeers() {
        // 成功检测到对等设备存在时，系统会广播 WIFI_P2P_PEERS_CHANGED_ACTION 意向
        wifiChannel?.also { channel ->
            wifiManager.discoverPeers(channel, object : WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    // 仅通知扫描进程已成功
                    log("已启动扫描设备进程")
                }

                override fun onFailure(reasonCode: Int) {
                    // 仅通知扫描进程启动失败
                    log("扫描设备进程启动失败：reasonCode=$reasonCode")
                }
            })
        }
    }

    /**
     * 关闭设备扫描
     */
    fun stopPeerDiscovery(result: MethodChannel.Result) {
        wifiChannel?.also { channel ->
            wifiManager.stopPeerDiscovery(channel, object : WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    result.success(true)
                    log("已关闭设备扫描进程")
                }

                override fun onFailure(reasonCode: Int) {
                    result.success(false)
                    log("扫描设备进程关闭失败：reasonCode=$reasonCode")
                }
            })
        }
    }

    /**
     * 请求已扫描设备的列表
     */
    fun requestPeers(result: MethodChannel.Result) {
        wifiChannel?.also { channel ->
            wifiManager.requestPeers(channel) { peers ->
                // Handle peers list
                val list: MutableList<Map<String, Any>> = mutableListOf()
                for (device: WifiP2pDevice in peers.deviceList) {
                    list.add(mergeDevice(device))
                }
                result.success(list)
                log("请求已扫描设备的列表：list=${toJson(list)}")
            }
        }
    }

    /**
     * 将 [device] 转化为需要的信息
     */
    private fun mergeDevice(device: WifiP2pDevice): Map<String, Any> {
        // from https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pDevice
        return mapOf(
            "deviceName" to if (device.deviceName == null) "" else device.deviceName,
            "deviceAddress" to if (device.deviceAddress == null) "" else device.deviceAddress,
            "primaryDeviceType" to if (device.primaryDeviceType == null) "" else device.primaryDeviceType,
            "secondaryDeviceType" to if (device.secondaryDeviceType == null) "" else device.secondaryDeviceType,
            "status" to device.status,

            // methods called on object before sending through channel
            "wpsPbcSupported" to if (device.deviceName == null) false else device.wpsPbcSupported(),
            "wpsKeypadSupported" to if (device.deviceName == null) false else device.wpsKeypadSupported(),
            "wpsDisplaySupported" to if (device.deviceName == null) false else device.wpsDisplaySupported(),
            "isServiceDiscoveryCapable" to if (device.deviceName == null) false else device.isServiceDiscoveryCapable,
            "isGroupOwner" to if (device.deviceName == null) false else device.isGroupOwner,
        )
    }

    /**
     * 连接到设备
     */
    fun connect(deviceAddress: String, result: MethodChannel.Result) {
        val config = WifiP2pConfig()
        config.deviceAddress = deviceAddress
        wifiChannel?.also { channel ->
            // connect方法在随后将自动创建群组并选择群组所有者
            wifiManager.connect(channel, config, object : WifiP2pManager.ConnectionInfoListener, WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    //success logic
                    result.success(true)
                    log("已连接到设备 `$deviceAddress`")
                }

                override fun onFailure(reason: Int) {
                    //failure logic
                    result.success(false)
                    log("连接到设备 `$deviceAddress` 失败：reason=$reason")
                }

                override fun onConnectionInfoAvailable(info: WifiP2pInfo?) {
                    info?.also {
                        // String from WifiP2pInfo struct
                        val groupOwnerAddress: String = info.groupOwnerAddress.hostAddress ?: ""

                        // After the group negotiation, we can determine the group owner
                        // (server).
                        if (info.groupFormed && info.isGroupOwner) {
                            // Do whatever tasks are specific to the group owner.
                            // One common case is creating a group owner thread and accepting
                            // incoming connections.
                        } else if (info.groupFormed) {
                            // The other device acts as the peer (client). In this case,
                            // you'll want to create a peer thread that connects
                            // to the group owner.
                            info.groupFormed
                        }
                    }
                    log("连接信息可用监听：${info.toString()}")
                }
            })
        }
    }

    /**
     * 断开设备连接
     */
    fun disconnect(result: MethodChannel.Result) {
        wifiChannel?.also { channel ->
            wifiManager.cancelConnect(channel, object : WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    result.success(true)
                    log("已断开设备连接")
                }

                override fun onFailure(reasonCode: Int) {
                    result.success(false)
                    log("断开设备连接失败")
                }
            })
        }
    }

    /**
     * 请求群组信息
     */
    fun requestGroup(result: MethodChannel.Result? = null) {
        wifiChannel?.also { channel ->
            wifiManager.requestGroupInfo(channel) { group ->
                var json: Map<String, Any> = emptyMap()
                if (group != null) {
                    json = mergeGroup(group = group)
                }
                result?.success(json)
                log("请求群组信息：json=${toJson(json)}")
            }
        }
    }

    /**
     * 创建群组
     */
    fun createGroup(result: MethodChannel.Result) {
        wifiChannel?.also { channel ->
            wifiManager.createGroup(channel, object : WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    result.success(true)
                    log("已创建群组")
                }

                override fun onFailure(reasonCode: Int) {
                    result.success(false)
                    log("创建群组失败: reasonCode=$reasonCode")
                }
            })
        }
    }

    /**
     * 移除群组
     */
    fun removeGroup(result: MethodChannel.Result) {
        wifiChannel?.also { channel ->
            wifiManager.removeGroup(channel, object : WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    result.success(true)
                    log("已移除群组")
                }

                override fun onFailure(reasonCode: Int) {
                    result.success(false)
                    log("移除群组失败")
                }
            })
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    private fun mergeGroup(group: WifiP2pGroup): Map<String, Any> {
        return mapOf(
            "networkName" to if (group.networkName == null) "" else group.networkName,
            "isGroupOwner" to group.isGroupOwner,
            "owner" to mergeDevice(group.owner),
            "clients" to mergeDevices(group.clientList),
            "passphrase" to if (group.passphrase == null) "" else group.passphrase,
            "interfaceName" to if (group.getInterface() == null) "" else group.getInterface(),
            "networkId" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                group.networkId
            } else {
                -1
            },
            "frequency" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                group.frequency
            } else {
                -1
            },
        )
    }

    /**
     * 将 [devices] 转化为需要的信息
     */
    private fun mergeDevices(devices: MutableCollection<WifiP2pDevice>): MutableList<Map<String, Any>> {
        val list: MutableList<Map<String, Any>> = mutableListOf()
        for (device: WifiP2pDevice in devices) {
            list.add(mergeDevice(device))
        }
        return list
    }

    private var mNetworkInfo: NetworkInfo? = null
    private var mWifiP2pInfo: WifiP2pInfo? = null
    private var mGroup: Any = {}

    /**
     * 获取Wi-Fi P2P信息
     */
    fun getWifiP2PInfo(): Map<String, Any> {
        val ni = mNetworkInfo
        val wi = mWifiP2pInfo
        if (ni == null || wi == null) return emptyMap()

        val obj = object {
            // https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pGroup
            val isConnected: Boolean = ni.isConnected
            val isAvailable: Boolean = ni.isAvailable
            val reason: String = if (ni.reason == null) "" else ni.reason
            val extraInfo: String = if (ni.extraInfo == null) "" else ni.extraInfo

            val groupFormed: Boolean = wi.groupFormed
            val isGroupOwner: Boolean = wi.isGroupOwner
            val groupOwnerAddress: String = if (wi.groupOwnerAddress == null) "" else wi.groupOwnerAddress.toString()

            val group: Any = mGroup
        }
        return emptyMap()
    }

    private fun toJson(any: Any) = Gson().toJson(any)

    fun requestPeers(listener: WifiP2pManager.PeerListListener) {
        wifiChannel?.also { channel ->
            wifiManager.requestPeers(channel, listener)
        }
    }

    fun requestConnection(listener: WifiP2pManager.ConnectionInfoListener) {
        wifiChannel?.also { channel ->
            wifiManager.requestConnectionInfo(channel, listener)
        }
    }

    override fun onP2pState(enabled: Boolean) {
        conn?.send(
            mapOf(
                "p2pState" to enabled
            )
        )
    }

    override fun onPeersAvailable(peers: List<WifiP2pDevice>) {
        conn?.send(mapOf("peersAvailable" to mergeDevices(peers.toMutableList())))
    }

    override fun onConnectionInfoAvailable(info: WifiP2pInfo) {
        conn?.send(
            mapOf(
                "connectionAvailable" to mapOf(
                    "groupFormed" to info.groupFormed,
                    "isGroupOwner" to info.isGroupOwner,
                    "groupOwnerAddress" to if (info.groupOwnerAddress == null) "" else info.groupOwnerAddress.toString(),
                )
            )
        )

    }

    override fun onDisconnected() {
        conn?.send(
            mapOf(
                "p2pConnection" to false
            )
        )
    }

    override fun onSelfP2pChanged(device: WifiP2pDevice) {
        conn?.send(
            mapOf(
                "selfP2pChanged" to mergeDevice(device)
            )
        )
    }
}

class WifiDirectStream : EventChannel.StreamHandler {
    private var mEventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        mEventSink = events
        log("监听 [WifiDirectStream] 开启：arguments=$arguments")
    }

    override fun onCancel(arguments: Any?) {
        mEventSink = null
        log("监听 [WifiDirectStream] 取消：arguments=$arguments")
    }

    fun send(params: Any) {
        mEventSink?.also { sink ->
            sink.success(params)
        }
    }

    fun error(str1: String, str2: String, params: Any) {
        mEventSink?.also { sink ->
            sink.error(str1, str2, params)
        }
    }

    fun cancel() {
        mEventSink?.also { sink ->
            sink.endOfStream()
        }
    }

}

fun log(msg: String) = if (false) null else Log.d("WifiDirect", msg)
