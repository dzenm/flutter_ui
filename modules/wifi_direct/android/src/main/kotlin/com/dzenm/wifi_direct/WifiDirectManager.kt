package com.dzenm.wifi_direct

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.location.LocationManager
import android.net.NetworkInfo
import android.net.wifi.WifiManager
import android.net.wifi.WpsInfo
import android.net.wifi.p2p.WifiP2pConfig
import android.net.wifi.p2p.WifiP2pDevice
import android.net.wifi.p2p.WifiP2pGroup
import android.net.wifi.p2p.WifiP2pInfo
import android.net.wifi.p2p.WifiP2pManager
import android.net.wifi.p2p.nsd.WifiP2pDnsSdServiceInfo
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
    private var receiver: WiFiDirectBroadcastReceiver = WiFiDirectBroadcastReceiver(this)

    private var conn = connection.get()

    ////////////////////////////////////////////////////////////////////////////

    /**
     * GPS是否开启
     */
    fun isGPSEnabled(result: MethodChannel.Result): Boolean {
        val lm = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val isOpenGPS = lm.isProviderEnabled(LocationManager.GPS_PROVIDER)
        val isOpenNetwork = lm.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
        log("GPS是否开启：${isOpenGPS && isOpenNetwork}")
        result.success(isOpenGPS && isOpenNetwork)
        return isOpenGPS && isOpenNetwork
    }

    /**
     * 进入位置设置页面
     */
    fun openLocationSettingsPage(result: MethodChannel.Result) {
        try {
            log("进入位置设置页面")
            context.startActivity(Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS))
            result.success(true)
        } catch (_: Exception) {
            result.success(false)
        }
    }

    /**
     * Wi-Fi是否开启
     */
    fun isWifiEnabled(result: MethodChannel.Result): Boolean {
        val context = context.applicationContext
        val wm = context.getSystemService(Context.WIFI_SERVICE) as WifiManager
        log("Wi-Fi是否开启：${wm.isWifiEnabled}")
        result.success(wm.isWifiEnabled)
        return wm.isWifiEnabled
    }

    /**
     * 进入Wi-Fi设置页面
     */
    fun openWifiSettingsPage(result: MethodChannel.Result) {
        try {
            log("进入Wi-Fi设置页面")
            context.startActivity(Intent(Settings.ACTION_WIFI_SETTINGS))
            result.success(true)
        } catch (_: Exception) {
            result.success(false)
        }
    }

    /**
     * 初始化Wi-Fi p2p
     */
    fun initialize(result: MethodChannel.Result) {
        // 1. 获取 WifiP2pManager 的实例，并通过调用 initialize() 将应用注册到 Wi-Fi P2P 框架
        wifiChannel = wifiManager.initialize(context, Looper.getMainLooper(), object : WifiP2pManager.ChannelListener {
            override fun onChannelDisconnected() {
                log("Wifi Direct已断开连接")
                conn?.error("Wifi Direct已断开连接", "Wifi Direct已断开连接", false)
            }
        })
        log("初始化Wi-Fi Manager")
        result.success(true)
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
        context.registerReceiver(receiver, intentFilter)
        log("注册Wi-Fi广播监听器")
        result.success(true)
    }

    /**
     * 取消注册Wi-Fi广播监听器
     */
    fun unregister(result: MethodChannel.Result) {
        /* unregister the broadcast receiver */
        // 结束时，取消注册广播监听器
        context.unregisterReceiver(receiver)
        log("取消注册Wi-Fi广播监听器")
        result.success(true)
    }

    /**
     * 添加本地服务
     */
    fun addLocalService(
        instanceName: String,
        serviceType: String,
        json: Map<String, String>,
        result: MethodChannel.Result,
    ) {
        // Service information.  Pass it an instance name, service type
        // _protocol._transport layer , and the map containing
        // information other devices will want once they connect to this one.
        val serviceInfo = WifiP2pDnsSdServiceInfo.newInstance(instanceName, serviceType, json)

        // Add the local service, sending the service info, network channel,
        // and listener that will be used to indicate success or failure of
        // the request.
        wifiChannel?.also { channel ->
            wifiManager.addLocalService(channel, serviceInfo, object : WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    // Command successful! Code isn't necessarily needed here,
                    // Unless you want to update the UI or add logging statements.
                    log("已添加本地服务：json=$json")
                    result.success(true)
                }

                override fun onFailure(reasonCode: Int) {
                    // Command failed.  Check for P2P_UNSUPPORTED, ERROR, or BUSY
                    log("添加本地服务失败：reasonCode=$reasonCode")
                    result.success(false)
                }
            })
        }
    }

    /**
     * 启动扫描设备进程
     */
    fun discoverPeers(result: MethodChannel.Result) {
        // 成功检测到对等设备存在时，系统会广播 WIFI_P2P_PEERS_CHANGED_ACTION 意向
        wifiChannel?.also { channel ->
            wifiManager.discoverPeers(channel, object : WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    // 仅通知扫描进程已成功
                    log("已启动扫描设备进程")
                    result.success(true)
                }

                override fun onFailure(reasonCode: Int) {
                    // 仅通知扫描进程启动失败
                    log("扫描设备进程启动失败：reasonCode=$reasonCode")
                    result.success(false)
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
                    log("已关闭设备扫描进程")
                    result.success(true)
                }

                override fun onFailure(reasonCode: Int) {
                    log("扫描设备进程关闭失败：reasonCode=$reasonCode")
                    result.success(false)
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
                log("请求已扫描设备的列表：list=${toJson(list)}")
                result.success(list)
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
        config.wps.setup = WpsInfo.PBC
        wifiChannel?.also { channel ->
            // connect方法在随后将自动创建群组并选择群组所有者
            wifiManager.connect(channel, config, object : WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    //success logic
                    log("已连接到设备 `$deviceAddress`")
                    result.success(true)
                }

                override fun onFailure(reasonCode: Int) {
                    //failure logic
                    log("连接到设备 `$deviceAddress` 失败：reasonCode=$reasonCode")
                    result.success(false)
                }
            })
        }
    }

    /**
     * 取消正在的连接设备
     */
    fun cancelConnect(result: MethodChannel.Result) {
        wifiChannel?.also { channel ->
            wifiManager.cancelConnect(channel, object : WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    log("已取消正在的连接设备")
                    result.success(true)
                }

                override fun onFailure(reasonCode: Int) {
                    log("取消正在的连接设备失败: reasonCode=$reasonCode")
                    result.success(false)
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
                var json: Map<String, Any?> = emptyMap()
                if (group != null) {
                    json = mergeGroup(group = group)
                }
                log("请求群组信息：json=${toJson(json)}")
                result?.success(json)
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
                    log("已创建群组")
                    result.success(true)
                }

                override fun onFailure(reasonCode: Int) {
                    log("创建群组失败: reasonCode=$reasonCode")
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
            wifiManager.removeGroup(channel, object : WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    log("已移除群组")
                    result.success(true)
                }

                override fun onFailure(reasonCode: Int) {
                    log("移除群组失败: reasonCode=$reasonCode")
                    result.success(false)
                }
            })
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    private fun mergeGroup(group: WifiP2pGroup): Map<String, Any?> {
        return mapOf(
            "networkName" to if (group.networkName == null) "" else group.networkName,
            "isGroupOwner" to group.isGroupOwner,
            "owner" to if (group.owner == null) null else mergeDevice(group.owner),
            "clients" to mergeDevices(group.clientList.toList()),
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
    private fun mergeDevices(devices: List<WifiP2pDevice>): MutableList<Map<String, Any>> {
        val list: MutableList<Map<String, Any>> = mutableListOf()
        for (device: WifiP2pDevice in devices) {
            list.add(mergeDevice(device))
        }
        return list
    }

    private fun toJson(any: Any) = Gson().toJson(any)

    override fun onP2pState(enabled: Boolean) {
        conn?.send(
            mapOf(
                "p2pState" to enabled
            )
        )
    }

    override fun onPeersAvailable(peers: List<WifiP2pDevice>) {
//        conn?.send(mapOf("peersAvailable" to mergeDevices(peers.toMutableList())))
        wifiChannel?.also { channel ->
            wifiManager.requestPeers(channel) { peers ->
                // Handle peers list
                val list: MutableList<Map<String, Any>> = mutableListOf()
                for (device: WifiP2pDevice in peers.deviceList) {
                    list.add(mergeDevice(device))
                }
                conn?.send(mapOf("peersAvailable" to list))
            }
        }
    }

    override fun onConnectionInfoAvailable(network: NetworkInfo?, info: WifiP2pInfo?, group: WifiP2pGroup?) {
        // https://developer.android.com/reference/android/net/wifi/p2p/WifiP2pGroup
        conn?.send(
            mapOf(
                "connectionAvailable" to mapOf(
                    "isConnected" to network?.isConnected,
                    "isAvailable" to network?.isAvailable,
                    "reason" to if (network?.reason == null) "" else network.reason,
                    "extraInfo" to if (network?.extraInfo == null) "" else network.extraInfo,
                    "groupFormed" to info?.groupFormed,
                    "isGroupOwner" to info?.isGroupOwner,
                    "groupOwnerAddress" to if (info?.groupOwnerAddress == null) "" else info.groupOwnerAddress.toString(),
                    "group" to if (group == null) null else mergeGroup(group),
                )
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

    override fun onDiscoverChanged(isDiscover: Boolean) {
        conn?.send(
            mapOf(
                "discoverChanged" to isDiscover
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

fun log(msg: String) = if (true) null else Log.d("WifiDirect", msg)
