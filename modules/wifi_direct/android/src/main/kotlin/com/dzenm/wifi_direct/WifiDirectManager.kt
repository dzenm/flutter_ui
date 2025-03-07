package com.dzenm.wifi_direct

import android.content.BroadcastReceiver
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
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Log
import com.google.gson.Gson
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference

class WifiDirectManager(private val context: Context, private val connection: WeakReference<ConnectionStream>) {

    private val tag = "WiFiDirect"

    private val wifiManager: WifiP2pManager by lazy(LazyThreadSafetyMode.NONE) {
        context.getSystemService(Context.WIFI_P2P_SERVICE) as WifiP2pManager
    }
    private var wifiChannel: WifiP2pManager.Channel? = null
    private var receiver: BroadcastReceiver? = null

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
        receiver = WiFiDirectBroadcastReceiver(this, connection)
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
                    Log.e(tag, "see https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pManager.ActionListener#onFailure(int) for codes")
                    result.success(false)
                    log("扫描设备进程关闭失败：reasonCode=$reasonCode")
                }
            })
        }
    }

    /**
     * 请求已扫描设备的列表
     */
    fun requestPeers(result: MethodChannel.Result? = null) {
        wifiChannel?.also { channel ->
            wifiManager.requestPeers(channel) { peers ->
                // Handle peers list
                val list: MutableList<Any> = mutableListOf()
                for (device: WifiP2pDevice in peers.deviceList) {
                    list.add(mergeDeviceInfo(device))
                }
                addDevices(peers = list)
                result?.success(toJson(list))
                log("请求已扫描设备的列表：list=${toJson(list)}")
            }
        }
    }

    /**
     * 将 [device] 转化为需要的信息
     */
    fun mergeDeviceInfo(device: WifiP2pDevice): Any {
        val result = object {
            // from https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pDevice
            val deviceName: String = if (device.deviceName == null) "" else device.deviceName
            val deviceAddress: String = if (device.deviceAddress == null) "" else device.deviceAddress
            val primaryDeviceType: String? = if (device.primaryDeviceType == null) "" else device.primaryDeviceType
            val secondaryDeviceType: String? = if (device.secondaryDeviceType == null) "" else device.secondaryDeviceType
            val status: Int = device.status

            // methods called on object before sending through channel
            val wpsPbcSupported: Boolean = if (device.deviceName == null) false else device.wpsPbcSupported()
            val wpsKeypadSupported: Boolean = if (device.deviceName == null) false else device.wpsKeypadSupported()
            val wpsDisplaySupported: Boolean = if (device.deviceName == null) false else device.wpsDisplaySupported()
            val isServiceDiscoveryCapable: Boolean = if (device.deviceName == null) false else device.isServiceDiscoveryCapable
            val isGroupOwner: Boolean = if (device.deviceName == null) false else device.isGroupOwner
        }
        return result
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
                var json: String? = null
                if (group != null) {
                    json = toJson(mergeGroup(group = group))
                }
                result?.success(json)
                log("请求群组信息：json=$json")
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

    fun mergeGroup(group: WifiP2pGroup): Any {
        val result = object {
            val networkName: String = if (group.networkName == null) "" else group.networkName
            val isGroupOwner: Boolean = group.isGroupOwner
            val owner: Any = mergeDeviceInfo(group.owner)
            val clients: Any = mergeDevices(group.clientList)
            val passphrase: String = if (group.passphrase == null) "" else group.passphrase
            val interfaceName: String = if (group.getInterface() == null) "" else group.getInterface()
            val networkId: Int = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                group.networkId
            } else {
                -1
            }
            val frequency: Int = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                group.frequency
            } else {
                -1
            }
        }
        return result
    }

    /**
     * 将 [devices] 转化为需要的信息
     */
    fun mergeDevices(devices: MutableCollection<WifiP2pDevice>): MutableList<Any> {
        val list: MutableList<Any> = mutableListOf()
        for (device: WifiP2pDevice in devices) {
            list.add(mergeDeviceInfo(device))
        }
        return list
    }

    /**
     * 找到的附近设备
     */
    private var foundDevices: MutableList<Any> = mutableListOf()

    /**
     * 添加找到的附近设备
     */
    private fun addDevices(peers: MutableList<Any>) {
        if (foundDevices.toString() == peers.toString()) return
        foundDevices = peers
        Log.d(tag, "requestPeers：Peers=" + getDevices())
    }

    /**
     * 获取设备
     */
    fun getDevices(): String = toJson(foundDevices)

    private var mNetworkInfo: NetworkInfo? = null
    private var mWifiP2pInfo: WifiP2pInfo? = null
    private var mGroup: Any = {}

    /**
     * 设置连接的信息
     */
    fun addConnection(network: NetworkInfo, wifiP2pInfo: WifiP2pInfo, group: WifiP2pGroup?) {
        if (network == mNetworkInfo || wifiP2pInfo == mWifiP2pInfo) return
        mNetworkInfo = network
        mWifiP2pInfo = wifiP2pInfo
        if (group == null) return
        addGroup(mergeGroup(group = group))
    }

    /**
     * 添加搜索到的群组内设备
     */
    private fun addGroup(group: Any) {
        if (mGroup.toString() == group.toString()) return
        mGroup = group
        Log.d(tag, "requestPeers：Peers=" + getGroup())
    }

    /**
     * 获取群组信息
     */
    private fun getGroup(): String = toJson(mGroup)

    /**
     * 获取Wi-Fi P2P信息
     */
    fun getWifiP2PInfo(): String {
        val ni = mNetworkInfo
        val wi = mWifiP2pInfo
        if (ni == null || wi == null) return ""

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
        return toJson(obj)
    }

    fun toJson(any: Any) = Gson().toJson(any)

    private fun log(msg: String) = Log.d(tag, msg)
}

class ConnectionStream : EventChannel.StreamHandler {

    private var mHandler: Handler = Handler(Looper.getMainLooper())
    var mEventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        mEventSink = events
    }

    override fun onCancel(arguments: Any?) {
        mEventSink = null
    }
}