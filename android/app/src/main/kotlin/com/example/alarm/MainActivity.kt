package com.example.alarm

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.alarm/permissions"
    private var usbBridge: UsbBridge? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.dartExecutor.binaryMessenger

        // Vendor RFID SDK bridge: USB -> ModuleAPI_J -> Reader.
        RfidBridge(messenger)

        // USB attach/permission events are kept separate from the vendor SDK.
        // The actual RFID connection is performed by RfidBridge using the
        // vendor demo's exact InitReader_Notype("USB", 1) call.
        usbBridge = UsbBridge(applicationContext, messenger)
        usbBridge?.handleIntent(intent)

        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkPermissions" -> result.success(true)
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        usbBridge?.handleIntent(intent)
    }

    override fun onDestroy() {
        usbBridge?.dispose()
        super.onDestroy()
    }
}
