package com.dzenm.wifi_direct

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.NetworkInfo
import android.net.wifi.p2p.WifiP2pDevice
import android.net.wifi.p2p.WifiP2pInfo
import android.net.wifi.p2p.WifiP2pManager

/**
 * A BroadcastReceiver that notifies of important Wi-Fi p2p events.
 */
class WiFiDirectBroadcastReceiver(
    private val manager: WifiDirectManager,
    private val listener: P2pConnectionListener,
) : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val action: String? = intent.action
        when (action) {
            WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION -> {
                // Check to see if Wi-Fi is enabled and notify appropriate activity
                val state: Int = intent.getIntExtra(WifiP2pManager.EXTRA_WIFI_STATE, -1)
                // Wifi P2P is enabled or not enabled
                val enabled = state == WifiP2pManager.WIFI_P2P_STATE_ENABLED

                listener.onP2pState(enabled)
                listener.onPeersAvailable(emptyList())
                log("WIFI_P2P_STATE_CHANGED_ACTION: enabled=$enabled")
            }

            WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION -> {
                // Call WifiP2pManager.requestPeers() to get a list of current peers
                manager.requestPeers { peers ->
                    val list = peers.deviceList.toList()
                    listener.onPeersAvailable(list)
                    log("WIFI_P2P_STATE_CHANGED_ACTION: peers=$list")
                }
            }

            WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION -> {
                // Respond to new connection or disconnections
                val networkInfo = intent.getParcelableExtra<NetworkInfo>(WifiP2pManager.EXTRA_NETWORK_INFO)
                manager.requestConnection { info ->
                    listener.onConnectionInfoAvailable(info)
                }
                log("WIFI_P2P_CONNECTION_CHANGED_ACTION")
                if (networkInfo?.isConnected == true) {
                    log("设备P2P 处于连接状态")
                } else {
                    listener.onDisconnected()
                    log("设备P2P 处于断开状态")
                }
            }

            WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION -> {
                // Respond to this device's wifi state changing
                val device = intent.getParcelableExtra<WifiP2pDevice>(WifiP2pManager.EXTRA_WIFI_P2P_DEVICE)
                if (device != null) {
                    listener.onSelfP2pChanged(device)
                }
                log("WIFI_P2P_THIS_DEVICE_CHANGED_ACTION：device=$device")
            }
        }
    }
}

interface P2pConnectionListener {
    fun onP2pState(enabled: Boolean)
    fun onPeersAvailable(peers: List<WifiP2pDevice>)
    fun onConnectionInfoAvailable(info: WifiP2pInfo)
    fun onDisconnected()
    fun onSelfP2pChanged(device: WifiP2pDevice)
}
