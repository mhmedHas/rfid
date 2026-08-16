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
 * Real Android USB permission/attach bridge used by the Flutter RFID app.
 *
 * The vendor demo relies on Android USB Host permission before the ModuleAPI_J
 * native reader is opened. This class handles the same permission lifecycle:
 * attached -> requestPermission() -> permission result -> Flutter -> SDK connect.
 */
class UsbBridge(private val context: Context, messenger: BinaryMessenger) {
    companion object {
        private const val TAG = "UsbBridge"
        private const val ACTION_USB_PERMISSION = "com.example.alarm.USB_PERMISSION"
        private const val REQUEST_CODE_USB_PERMISSION = 4127

        private val KNOWN_RFID_VENDOR_IDS = setOf(6790, 1027, 4292, 1155, 1062)
    }

    private val usbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
    private val channel = MethodChannel(messenger, "com.example.alarm/usb")
    private var pendingPermissionDeviceId: Int? = null

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                ACTION_USB_PERMISSION -> {
                    val device = getUsbDeviceExtra(intent)
                    val granted = intent.getBooleanExtra(
                        UsbManager.EXTRA_PERMISSION_GRANTED,
                        false
                    )
                    pendingPermissionDeviceId = null

                    Log.i(
                        TAG,
                        "USB permission result: granted=$granted device=${device?.deviceName}"
                    )

                    channel.invokeMethod(
                        "onUsbPermissionResult",
                        mapOf(
                            "deviceId" to device?.deviceId,
                            "vendorId" to device?.vendorId,
                            "productId" to device?.productId,
                            "deviceName" to device?.deviceName,
                            "granted" to granted
                        )
                    )

                    if (device != null) {
                        notifyDeviceStatus(
                            if (granted) "permission_granted" else "permission_denied",
                            device
                        )
                    }
                }

                UsbManager.ACTION_USB_DEVICE_ATTACHED -> {
                    val device = getUsbDeviceExtra(intent) ?: return
                    Log.i(TAG, "USB attached: ${describe(device)}")
                    notifyDeviceStatus("attached", device)

                    if (!usbManager.hasPermission(device)) {
                        requestPermission(device)
                    } else {
                        notifyDeviceStatus("permission_granted", device)
                    }
                }

                UsbManager.ACTION_USB_DEVICE_DETACHED -> {
                    val device = getUsbDeviceExtra(intent) ?: return
                    pendingPermissionDeviceId = null
                    Log.i(TAG, "USB detached: ${describe(device)}")
                    notifyDeviceStatus("detached", device)
                }
            }
        }
    }

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getUsbDevices" -> {
                    result.success(usbManager.deviceList.values.map { it.toMap() })
                }

                "requestPermission" -> {
                    val deviceId = call.argument<Int>("deviceId")
                    val device = usbManager.deviceList.values
                        .firstOrNull { it.deviceId == deviceId }

                    if (device == null) {
                        result.success(false)
                    } else if (usbManager.hasPermission(device)) {
                        pendingPermissionDeviceId = null
                        notifyDeviceStatus("permission_granted", device)
                        result.success(true)
                    } else {
                        requestPermission(device)
                        result.success(true)
                    }
                }

                "hasPermission" -> {
                    val deviceId = call.argument<Int>("deviceId")
                    val device = usbManager.deviceList.values
                        .firstOrNull { it.deviceId == deviceId }
                    result.success(device != null && usbManager.hasPermission(device))
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
            @Suppress("DEPRECATION")
            context.registerReceiver(receiver, filter)
        }
    }

    /**
     * Called by MainActivity when Android launches the app because the reader
     * was attached while the app was not running.
     */
    fun handleIntent(intent: Intent?) {
        if (intent?.action != UsbManager.ACTION_USB_DEVICE_ATTACHED) return

        val device = getUsbDeviceExtra(intent) ?: return
        Log.i(TAG, "USB attach intent received: ${describe(device)}")
        notifyDeviceStatus("attached", device)

        if (!usbManager.hasPermission(device)) {
            requestPermission(device)
        } else {
            notifyDeviceStatus("permission_granted", device)
        }
    }

    private fun requestPermission(device: UsbDevice) {
        if (usbManager.hasPermission(device)) {
            pendingPermissionDeviceId = null
            notifyDeviceStatus("permission_granted", device)
            return
        }

        // Prevent the attach broadcast and MainActivity's initial intent from
        // opening two permission dialogs for the same physical USB device.
        if (pendingPermissionDeviceId == device.deviceId) {
            Log.d(TAG, "USB permission request already pending for ${device.deviceId}")
            return
        }

        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val permissionIntent = PendingIntent.getBroadcast(
            context,
            REQUEST_CODE_USB_PERMISSION,
            Intent(ACTION_USB_PERMISSION).setPackage(context.packageName),
            flags
        )

        pendingPermissionDeviceId = device.deviceId
        Log.i(TAG, "Requesting USB permission for ${describe(device)}")
        usbManager.requestPermission(device, permissionIntent)
    }

    private fun notifyDeviceStatus(status: String, device: UsbDevice) {
        channel.invokeMethod(
            "onUsbDeviceStatus",
            mapOf(
                "status" to status,
                "deviceId" to device.deviceId,
                "vendorId" to device.vendorId,
                "productId" to device.productId,
                "deviceName" to device.deviceName,
                "manufacturer" to (device.manufacturerName ?: ""),
                "product" to (device.productName ?: ""),
                "interfaceCount" to device.interfaceCount,
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
        "serial" to (try { serialNumber } catch (_: SecurityException) { null } ?: ""),
        "interfaceCount" to interfaceCount,
        "hasPermission" to usbManager.hasPermission(this),
        "isKnownRfidVendor" to KNOWN_RFID_VENDOR_IDS.contains(vendorId)
    )

    private fun describe(device: UsbDevice): String =
        "${device.deviceName} vid=${device.vendorId} pid=${device.productId} interfaces=${device.interfaceCount}"

    fun dispose() {
        try {
            context.unregisterReceiver(receiver)
        } catch (e: Exception) {
            Log.e(TAG, "unregisterReceiver failed", e)
        }
    }
}
