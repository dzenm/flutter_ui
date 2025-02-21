package com.dzenm.flutter_ui.plugins;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiManager;
import android.net.wifi.WifiNetworkSpecifier;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;

import java.lang.reflect.Method;

public class WifiHotspot {

    private final Activity mActivity;
    private WifiConfiguration mWifiConfig;

    public WifiHotspot(Activity activity) {
        mActivity = activity;
    }

    private static final int REQUEST_PERMISSIONS = 100; // 请求权限的请求码

    /**
     * 检查权限并请求
     */
    public void open() {
        if (ActivityCompat.checkSelfPermission(mActivity,
                Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            // 请求权限
            ActivityCompat.requestPermissions(mActivity,
                    new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, REQUEST_PERMISSIONS);
        } else {
            // 如果权限已被授予，则可以继续打开热点
            setupHotspot();
        }
    }

    private void enableHotspot() {
        try {
            ConnectivityManager connectivityManager = (ConnectivityManager)
                    mActivity.getSystemService(Context.CONNECTIVITY_SERVICE);
            Method method = connectivityManager.getClass().getDeclaredMethod("setWifiApEnabled", WifiConfiguration.class, boolean.class);
            method.invoke(connectivityManager, mWifiConfig, true);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 请求权限的请求码回调处理
     *
     * @param requestCode  请求码
     * @param permissions  请求的权限
     * @param grantResults 请求权限的返回结果
     */
    public void onRequestPermissionsResult(
            int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (requestCode == REQUEST_PERMISSIONS) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                setupHotspot();
            }
        }
    }

    private void setupHotspot() {
        WifiManager manager = (WifiManager) mActivity
                .getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        WifiConfiguration wifiConfig = new WifiConfiguration();
        mWifiConfig = wifiConfig;
        wifiConfig.SSID = "Pixel"; // 设置热点名称
        wifiConfig.preSharedKey = "12345678"; // 设置密码
        // 打开wifi热点
        try {
            Method method = manager.getClass().getMethod(
                    "setWifiApEnabled", WifiConfiguration.class, boolean.class);
            method.invoke(manager, wifiConfig, true);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
