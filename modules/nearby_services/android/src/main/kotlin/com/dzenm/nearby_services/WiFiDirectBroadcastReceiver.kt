package com.dzenm.nearby_services

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.NetworkInfo
import android.net.wifi.p2p.WifiP2pDevice
import android.net.wifi.p2p.WifiP2pManager
import android.util.Log

/**
 * A BroadcastReceiver that notifies of important Wi-Fi p2p events.
 */
class WiFiDirectBroadcastReceiver(
    private val manager: WifiDirectManager,
) : BroadcastReceiver() {

    private val tag = "WiFiDirect"
    override fun onReceive(context: Context, intent: Intent) {
        val action: String? = intent.action
        when (action) {
            WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION -> {
                // Check to see if Wi-Fi is enabled and notify appropriate activity
                // Check to see if Wi-Fi is enabled and notify appropriate activity
                when (val state: Int = intent.getIntExtra(WifiP2pManager.EXTRA_WIFI_STATE, -1)) {
                    WifiP2pManager.WIFI_P2P_STATE_ENABLED -> {
                        // Wifi P2P is enabled
                        log("NearbyServices: Wi-Fi state enabled, Int=${state}")
                    }

                    else -> {
                        // Wi-Fi P2P is not enabled
                        log("NearbyServices: Wi-Fi state disabled, Int=${state}")
                    }
                }
            }

            WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION -> {
                // Call WifiP2pManager.requestPeers() to get a list of current peers
                // 如果发现进程成功并检测到对等设备，可以获取对等设备列表。使用 requestPeers() 请求已发现对等设备的列表
                manager.requestPeers()
            }

            WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION -> {
                // Respond to new connection or disconnections
                // 应用可以使用 requestConnectionInfo()、requestNetworkInfo() 或 requestGroupInfo() 来检索当前连接信息
                val networkInfo = intent.getParcelableExtra<NetworkInfo>(WifiP2pManager.EXTRA_NETWORK_INFO)
                if (networkInfo != null && networkInfo.isConnected) {
                    log("已连接 P2P 设备")
                } else {
                    log("已断开与 P2P 设备连接")
                }
            }

            WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION -> {
                // Respond to this device's wifi state changing
                // 应用可以使用 requestDeviceInfo() 检索当前连接信息
                val device = intent.getParcelableExtra<WifiP2pDevice>(WifiP2pManager.EXTRA_WIFI_P2P_DEVICE)
                if (device != null) {
                    log("设备信息改变：$device")
                }
            }
        }
    }

    private fun log(msg: String) = Log.d(tag, msg)
}