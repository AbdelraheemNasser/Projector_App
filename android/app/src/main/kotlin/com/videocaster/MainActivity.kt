package com.videocaster

import android.app.Activity
import android.content.Context
import android.hardware.display.DisplayManager
import android.media.MediaRouter
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.videocaster/display"
    private var methodChannel: MethodChannel? = null
    private var mediaRouter: MediaRouter? = null

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
