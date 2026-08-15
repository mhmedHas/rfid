package com.example.alarm

import android.util.Log
import com.uhf.api.cls.Reader
import com.uhf.api.cls.Reader.*
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Flutter bridge for the vendor ModuleAPI_J SDK.
 *
 * The vendor documentation explicitly puts the public SDK classes in
 * com.uhf.api.cls.Reader.*. BackReadOption and ReadListener are therefore
 * imported from Reader.*, not as top-level classes.
 *
 * USB connection follows the vendor demo configuration shown on the device:
 * address = "USB", antenna port = 1.
 */
class RfidBridge(messenger: BinaryMessenger) {
    companion object {
        private const val TAG = "RfidBridge"
        private const val USB_ADDRESS = "USB"
        private const val ANTENNA_COUNT = 1
    }

    private val reader = Reader()
    private var eventSink: EventChannel.EventSink? = null
    private var readListener: ReadListener? = null
    private var isReading = false
    private var isConnected = false
    private var connectedAddress = ""

    init {
        MethodChannel(messenger, "rfid/methods").setMethodCallHandler { call, result ->
            when (call.method) {
                "connect" -> {
                    val address = call.argument<String>("address") ?: USB_ADDRESS
                    val ports = call.argument<Int>("ports") ?: ANTENNA_COUNT
                    result.success(connectReader(address, ports))
                }

                "connectUSB" -> {
                    result.success(connectUsbReader())
                }

                "connectBluetooth" -> {
                    result.error(
                        "UNSUPPORTED_CONNECTION",
                        "هذا التطبيق يستخدم قارئ RFID عبر USB فقط",
                        null
                    )
                }

                "startReading" -> startReading(result)

                "stopReading" -> {
                    stopReadingInternal()
                    result.success(true)
                }

                "disconnect" -> {
                    disconnectInternal()
                    result.success(true)
                }

                "setPower" -> {
                    result.success(setReaderPower(call.argument<Int>("power") ?: 3000))
                }

                "getStatus" -> {
                    result.success(
                        mapOf(
                            "isConnected" to isConnected,
                            "isReading" to isReading,
                            "address" to connectedAddress,
                            "module" to "UHF RFID Reader"
                        )
                    )
                }

                "getReaderInfo" -> {
                    result.success(
                        mapOf(
                            "model" to "UHF RFID Reader",
                            "address" to connectedAddress,
                            "antennaPorts" to ANTENNA_COUNT
                        )
                    )
                }

                else -> result.notImplemented()
            }
        }

        EventChannel(messenger, "rfid/tags").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, sink: EventChannel.EventSink) {
                    eventSink = sink
                }

                override fun onCancel(args: Any?) {
                    eventSink = null
                }
            }
        )
    }

    /**
     * Exact connection requested by the vendor-demo configuration:
     * Address=USB, Antenna=1.
     *
     * Android USB permission is handled separately by UsbBridge before this
     * method is reached. The ModuleAPI_J SDK then owns the reader transport.
     */
    private fun connectUsbReader(): Boolean {
        if (isConnected) return true
        return connectReader(USB_ADDRESS, ANTENNA_COUNT)
    }

    private fun connectReader(address: String, ports: Int): Boolean {
        if (isConnected) return true

        return try {
            val safePorts = ports.coerceIn(1, 16)

            // ModuleAPI_J documented connection lifecycle.
            val err = reader.InitReader_Notype(address, safePorts)
            if (err == READER_ERR.MT_OK_ERR) {
                isConnected = true
                connectedAddress = address
                Log.i(TAG, "RFID connected: address=$address, antennaPorts=$safePorts")
                true
            } else {
                Log.e(TAG, "RFID connection failed: address=$address, error=$err")
                false
            }
        } catch (e: Throwable) {
            Log.e(TAG, "RFID connection exception: address=$address", e)
            false
        }
    }

    private fun startReading(result: MethodChannel.Result) {
        if (!isConnected) {
            result.error("NOT_CONNECTED", "الجهاز غير متصل", null)
            return
        }

        if (isReading) {
            result.success(true)
            return
        }

        try {
            readListener = ReadListener { _, tags ->
                if (tags == null || tags.isEmpty()) return@ReadListener

                val list = tags.mapNotNull { tag ->
                    try {
                        val epc = Reader.bytes_Hexstr(tag.EpcId).uppercase()
                        if (epc.isBlank()) return@mapNotNull null

                        mapOf<String, Any?>(
                            "epc" to epc,
                            "rssi" to tag.RSSI,
                            "antenna" to tag.AntennaID,
                            "frequency" to tag.Frequency,
                            "timestamp" to tag.TimeStamp,
                            "readCount" to tag.ReadCnt,
                            "protocol" to tag.protocol.toString()
                        )
                    } catch (e: Throwable) {
                        Log.e(TAG, "RFID tag conversion failed", e)
                        null
                    }
                }

                if (list.isNotEmpty()) {
                    eventSink?.success(list)
                }
            }

            reader.addReadListener(readListener!!)

            // This is the asynchronous inventory API documented by the SDK.
            // General mode, 250 ms duration, zero interval, one antenna.
            val option = BackReadOption()
            option.IsFastRead = false
            option.ReadDuration = 250.toShort()
            option.ReadInterval = 0
            option.TMFlags.IsAntennaID = true
            option.TMFlags.IsRSSI = true
            option.TMFlags.IsFrequency = true

            val err = reader.StartReading(
                intArrayOf(1),
                ANTENNA_COUNT,
                option
            )

            if (err != READER_ERR.MT_OK_ERR) {
                try {
                    reader.removeReadListener(readListener!!)
                } catch (_: Throwable) {
                }
                readListener = null
                result.error("START_READING_FAILED", err.toString(), null)
                return
            }

            isReading = true
            Log.i(TAG, "RFID inventory started")
            result.success(true)
        } catch (e: Throwable) {
            Log.e(TAG, "RFID inventory start exception", e)
            try {
                readListener?.let { reader.removeReadListener(it) }
            } catch (_: Throwable) {
            }
            readListener = null
            result.error("START_READING_EXCEPTION", e.message, null)
        }
    }

    private fun stopReadingInternal() {
        try {
            if (isReading) {
                reader.StopReading()
                Log.i(TAG, "RFID inventory stopped")
            }
        } catch (e: Throwable) {
            Log.e(TAG, "StopReading failed", e)
        }

        isReading = false

        readListener?.let { listener ->
            try {
                reader.removeReadListener(listener)
            } catch (_: Throwable) {
            }
        }
        readListener = null
    }

    private fun disconnectInternal() {
        stopReadingInternal()

        try {
            if (isConnected) {
                reader.CloseReader()
                Log.i(TAG, "RFID reader closed")
            }
        } catch (e: Throwable) {
            Log.e(TAG, "CloseReader failed", e)
        }

        isConnected = false
        connectedAddress = ""
    }

    private fun setReaderPower(power: Int): Boolean {
        if (!isConnected) return false

        return try {
            val safePower = power.coerceIn(500, 3000)
            val conf = reader.AntPowerConf()
            conf.antcnt = ANTENNA_COUNT

            val antPower = reader.AntPower()
            antPower.antid = 1
            antPower.readPower = safePower.toShort()
            antPower.writePower = safePower.toShort()

            conf.Powers[0] = antPower
            reader.ParamSet(
                Mtr_Param.MTR_PARAM_RF_ANTPOWER,
                conf
            ) == READER_ERR.MT_OK_ERR
        } catch (e: Throwable) {
            Log.e(TAG, "setPower failed", e)
            false
        }
    }
}
