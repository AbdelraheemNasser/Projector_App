package com.videocaster.video_caster

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.hardware.display.DisplayManager
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.videocaster/display"
    private var methodChannel: MethodChannel? = null
    private val CAST_REQUEST_CODE = 100

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startCasting" -> {
                    startCasting()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        setupDisplayListener()
    }

    private fun startCasting() {
        try {
            // Open Cast settings to let user connect to display
            val intent = Intent(Settings.ACTION_CAST_SETTINGS)
            startActivity(intent)
            
            // Check if already connected
            checkDisplayConnection()
        } catch (e: Exception) {
            // Fallback: try to open wireless display settings
            try {
                val intent = Intent("android.settings.CAST_SETTINGS")
                startActivity(intent)
            } catch (ex: Exception) {
                // Last fallback: open general display settings
                val intent = Intent(Settings.ACTION_DISPLAY_SETTINGS)
                startActivity(intent)
            }
        }
    }

    private fun checkDisplayConnection() {
        val displayManager = getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
        displayManager.displays.forEach { display ->
            if (display.displayId != 0) {
                methodChannel?.invokeMethod("onDisplayConnected", null)
                return
            }
        }
    }

    private fun setupDisplayListener() {
        val displayManager = getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
        displayManager.registerDisplayListener(object : DisplayManager.DisplayListener {
            override fun onDisplayAdded(displayId: Int) {
                if (displayId != 0) {
                    methodChannel?.invokeMethod("onDisplayConnected", null)
                }
            }

            override fun onDisplayRemoved(displayId: Int) {
                methodChannel?.invokeMethod("onDisplayDisconnected", null)
            }

            override fun onDisplayChanged(displayId: Int) {}
        }, null)
    }
}
