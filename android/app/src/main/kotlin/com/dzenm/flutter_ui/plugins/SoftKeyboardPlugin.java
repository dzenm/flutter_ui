package com.dzenm.flutter_ui.plugins;

import android.app.Activity;
import android.content.Context;
import android.content.res.Resources;
import android.os.Build;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.view.WindowInsets;

import androidx.annotation.NonNull;
import androidx.core.view.OnApplyWindowInsetsListener;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;

public class SoftKeyboardPlugin implements FlutterPlugin, EventChannel.StreamHandler, ActivityAware, OnApplyWindowInsetsListener {
    public static final String FLUTTER_STREAM_KEYBOARD = "flutter_ui/stream/keyboard"; // 软键盘监听

    private EventChannel mChannel = null;
    private Activity mActivity = null;
    private EventChannel.EventSink mEventSink = null;
    private View mRootView = null;

    @NonNull
    @Override
    public WindowInsetsCompat onApplyWindowInsets(@NonNull View v, @NonNull WindowInsetsCompat insets) {
        Activity activity = mActivity;
        if (activity == null) {
            return insets;
        }

        boolean isSoftKeyboardVisible = insets.isVisible(WindowInsetsCompat.Type.ime());
        int softKeyboardHeight = insets.getInsets(WindowInsetsCompat.Type.ime()).bottom;
        boolean isNavigationBarVisible = insets.isVisible(WindowInsetsCompat.Type.navigationBars());
        int navigationBarHeight = insets.getInsets(WindowInsetsCompat.Type.navigationBars()).bottom;
        if (navigationBarHeight == 0.0) {
            navigationBarHeight = getNavigationBarHeight();
        }
        double density = getScreenDensity(activity);
        Map<String, Object> json = new HashMap<>();
        json.put("isSoftKeyboardVisible", isSoftKeyboardVisible);
        json.put("softKeyboardHeight", softKeyboardHeight / density);
        json.put("isNavigationBarVisible", isNavigationBarVisible);
        json.put("navigationBarHeight", navigationBarHeight / density);
        send(json);
        return insets;
    }

    /// 获取导航栏高度
    private int getNavigationBarHeight() {
        Activity activity = mActivity;
        if (activity == null) {
            return 0;
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // Android 11 推荐方式
            WindowInsets insets = activity.getWindowManager().getCurrentWindowMetrics().getWindowInsets();
            return insets.getInsets(WindowInsets.Type.navigationBars()).bottom;
        } else {
            // 旧版本兼容
            Resources resources = activity.getResources();
            int resourceId = resources.getIdentifier("navigation_bar_height", "dimen", "android");
            return resourceId > 0 ? resources.getDimensionPixelSize(resourceId) : 0;
        }
    }

    /// 获取屏幕像素比
    private double getScreenDensity(Context context) {
        DisplayMetrics metrics = context.getResources().getDisplayMetrics();
        return metrics.density; // 获取屏幕密度，单位是dpi
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        EventChannel channel = new EventChannel(binding.getBinaryMessenger(), FLUTTER_STREAM_KEYBOARD);
        channel.setStreamHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        mChannel.setStreamHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        mActivity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        mActivity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        mActivity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
        mActivity = null;
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        mEventSink = events;
        startListenKeyboard();
    }

    private void startListenKeyboard() {
        Activity activity = mActivity;
        if (activity == null) return;
        mRootView = activity.getWindow().getDecorView();
        ViewCompat.setOnApplyWindowInsetsListener(mRootView, this);
    }

    @Override
    public void onCancel(Object arguments) {
        mEventSink = null;
        stopListenKeyboard();
    }

    private void stopListenKeyboard() {
        View rootView = mRootView;
        if (rootView == null) return;
        mRootView = null;

    }

    public void send(@NonNull Map<String, Object> json) {
        EventChannel.EventSink sink = mEventSink;
        if (sink == null) return;
        sink.success(json);
    }

}

