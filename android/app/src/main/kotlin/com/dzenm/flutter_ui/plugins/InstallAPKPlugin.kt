package com.dzenm.flutter_ui.plugins

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.core.content.FileProvider
import java.io.File

class InstallAPKPlugin {
    fun openFile(context: Context, file: File) {
        try {
            val intent = Intent()
            intent.action = Intent.ACTION_VIEW
            val uri = FileProvider.getUriForFile(context, "com.flutter_ui.main.provider", file)
            if (Build.VERSION.SDK_INT > Build.VERSION_CODES.M) {
                intent.addCategory("android.intent.category.DEFAULT")
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_GRANT_READ_URI_PERMISSION
                intent.setDataAndType(uri, "application/vnd.android.package-archive")
                Log.d("InstallAPKPlugin", "download success：path=" + file.path + "，provider=" + uri.path)
            } else {
                intent.setDataAndType(Uri.fromFile(file), "application/vnd.android.package-archive")
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}