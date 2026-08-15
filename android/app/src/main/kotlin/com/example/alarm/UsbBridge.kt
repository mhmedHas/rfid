package com.example.alarm

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import android.os.Build
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Native implementation of the 'com.example.alarm/usb' channel.
 *
 * This channel previously had NO handler registered anywhere in the native
 * code — Dart's UsbService (services/connect.dart) called `getUsbDevices`
 * and `requestPermission` on it, but every call silently threw
 * MissingPluginException and was swallowed by its own try/catch, so
 * RfidProvider's "auto-connect when a reader is plugged in" flow never
 * actually ran. This class wires it up for real using Android's UsbManager.
 *
 * Known vendor IDs kept in sync with android/app/src/main/res/xml/device_filter.xml
 */
class UsbBridge(private val context: Context, messenger: BinaryMessenger) {
    companion object {
        private const val TAG = "UsbBridge"
        private const val ACTION_USB_PERMISSION = "com.example.alarm.USB_PERMISSION"
        private val KNOWN_RFID_VENDOR_IDS = setOf(6790, 1027, 4292, 1155, 1062)
    }

    private val usbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
    private val channel = MethodChannel(messenger, "com.example.alarm/usb")

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getUsbDevices" -> result.success(usbManager.deviceList.values.map { it.toMap() })
                "requestPermission" -> {
                    val deviceId = call.argument<Int>("deviceId")
                    val device = usbManager.deviceList.values.firstOrNull { it.deviceId == deviceId }
                    if (device == null) {
                        result.success(false)
                    } else {
                        requestPermission(device)
                        result.success(true)
                    }
                }
                else -> result.notImplemented()
            }
        }

        val filter = IntentFilter().apply {
            addAction(ACTION_USB_PERMISSION)
            addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED)
            addAction(UsbManager.ACTION_USB_DEVICE_DETACHED)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            context.registerReceiver(receiver, filter)
        }
    }

    /** Call from MainActivity.onCreate/onNewIntent so an attach that launched the app is reported too. */
    fun handleIntent(intent: Intent?) {
        if (intent?.action == UsbManager.ACTION_USB_DEVICE_ATTACHED) {
            val device = getUsbDeviceExtra(intent) ?: return
            // If the OS routed this intent to us via device_filter.xml, permission
            // is granted automatically — no need to call requestPermission again.
            notifyDeviceStatus("attached", device)
        }
    }

    private fun requestPermission(device: UsbDevice) {
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) PendingIntent.FLAG_MUTABLE else 0
        val permissionIntent = PendingIntent.getBroadcast(
            context, 0, Intent(ACTION_USB_PERMISSION), flags
        )
        usbManager.requestPermission(device, permissionIntent)
    }

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                ACTION_USB_PERMISSION -> {
                    val device = getUsbDeviceExtra(intent)
                    val granted = intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)
                    channel.invokeMethod(
                        "onUsbPermissionResult",
                        mapOf("deviceId" to device?.deviceId, "granted" to granted)
                    )
                }
                UsbManager.ACTION_USB_DEVICE_ATTACHED -> {
                    val device = getUsbDeviceExtra(intent) ?: return
                    notifyDeviceStatus("attached", device)
                }
                UsbManager.ACTION_USB_DEVICE_DETACHED -> {
                    val device = getUsbDeviceExtra(intent) ?: return
                    notifyDeviceStatus("detached", device)
                }
            }
        }
    }

    private fun notifyDeviceStatus(status: String, device: UsbDevice) {
        Log.d(TAG, "USB $status: ${device.deviceName} (vid=${device.vendorId}, pid=${device.productId})")
        channel.invokeMethod(
            "onUsbDeviceStatus",
            mapOf(
                "status" to status,
                "deviceId" to device.deviceId,
                "vendorId" to device.vendorId,
                "productId" to device.productId,
                "deviceName" to device.deviceName,
                "hasPermission" to usbManager.hasPermission(device)
            )
        )
    }

    @Suppress("DEPRECATION")
    private fun getUsbDeviceExtra(intent: Intent): UsbDevice? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(UsbManager.EXTRA_DEVICE, UsbDevice::class.java)
        } else {
            intent.getParcelableExtra(UsbManager.EXTRA_DEVICE)
        }
    }

    private fun UsbDevice.toMap(): Map<String, Any?> = mapOf(
        "deviceId" to deviceId,
        "vendorId" to vendorId,
        "productId" to productId,
        "deviceName" to deviceName,
        "manufacturer" to (manufacturerName ?: ""),
        "product" to (productName ?: ""),
        "serial" to (try { serialNumber } catch (e: SecurityException) { null } ?: ""),
        "interfaceCount" to interfaceCount,
        "hasPermission" to usbManager.hasPermission(this)
    )

    fun dispose() {
        try { context.unregisterReceiver(receiver) } catch (e: Exception) { Log.e(TAG, "unregisterReceiver failed", e) }
    }
}
