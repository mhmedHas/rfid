package com.example.alarm

import android.util.Log
import com.uhf.api.cls.Reader
import com.uhf.api.cls.Reader.*
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/** Flutter bridge for the vendor ModuleAPI_J SDK. */
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
                "connectUSB" -> result.success(connectUsbReader())
                "connectBluetooth" -> result.error("UNSUPPORTED_CONNECTION", "هذا التطبيق يستخدم قارئ RFID عبر USB فقط", null)
                "startReading" -> startReading(result)
                "stopReading" -> { stopReadingInternal(); result.success(true) }
                "disconnect" -> { disconnectInternal(); result.success(true) }
                "setPower" -> result.success(setReaderPower(call.argument<Int>("power") ?: 3000))
                "getStatus" -> result.success(mapOf(
                    "isConnected" to isConnected,
                    "isReading" to isReading,
                    "address" to connectedAddress,
                    "module" to "UHF RFID Reader"
                ))
                else -> result.notImplemented()
            }
        }

        EventChannel(messenger, "rfid/events").setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) { eventSink = events }
            override fun onCancel(arguments: Any?) { eventSink = null }
        })
    }

    private fun connectUsbReader(): Boolean = connectReader(USB_ADDRESS, ANTENNA_COUNT)

    private fun connectReader(address: String, ports: Int): Boolean {
        return try {
            if (isConnected) return true
            val err = reader.InitReader_Notype(address, ports)
            Log.i(TAG, "InitReader_Notype($address, $ports) => $err")
            if (err == READER_ERR.MT_OK_ERR) {
                connectedAddress = address
                isConnected = true
                true
            } else {
                isConnected = false
                connectedAddress = ""
                false
            }
        } catch (e: Throwable) {
            isConnected = false
            connectedAddress = ""
            Log.e(TAG, "RFID connect failed", e)
            false
        }
    }

    private fun startReading(result: MethodChannel.Result) {
        if (!isConnected) {
            result.error("NOT_CONNECTED", "RFID reader is not connected", null)
            return
        }
        if (isReading) { result.success(true); return }

        try {
            val listener = object : ReadListener {
                override fun tagRead(tags: Array<TAGINFO>?) {
                    if (tags == null) return
                    for (tag in tags) {
                        val epc = Reader.bytes_Hexstr(tag.EpcId ?: continue)
                        if (epc.isBlank()) continue
                        eventSink?.success(mapOf(
                            "type" to "tag",
                            "epc" to epc,
                            "rssi" to tag.RSSI,
                            "antenna" to tag.AntennaID,
                            "frequency" to tag.Frequency,
                            "timestamp" to tag.TimeStamp,
                            "readCount" to tag.ReadCnt
                        ))
                    }
                }

                override fun tagException(errorCode: READER_ERR?) {
                    eventSink?.error("RFID_READ_ERROR", errorCode?.toString() ?: "Unknown RFID read error", null)
                }
            }

            readListener = listener
            reader.addReadListener(listener)

            val option = BackReadOption()
            option.IsFastRead = false
            option.ReadDuration = 250
            option.ReadInterval = 0

            val antennas = intArrayOf(1)
            val err = reader.StartReading(antennas, antennas.size, option)
            Log.i(TAG, "StartReading => $err")

            if (err == READER_ERR.MT_OK_ERR) {
                isReading = true
                result.success(true)
            } else {
                try { reader.removeReadListener(listener) } catch (_: Throwable) { }
                readListener = null
                result.error("START_READING_FAILED", err.toString(), null)
            }
        } catch (e: Throwable) {
            readListener = null
            result.error("START_READING_EXCEPTION", e.message, null)
        }
    }

    private fun stopReadingInternal() {
        try {
            if (isReading) reader.StopReading()
        } catch (e: Throwable) {
            Log.e(TAG, "StopReading failed", e)
        }
        isReading = false

        val listener: ReadListener? = readListener
        if (listener != null) {
            try { reader.removeReadListener(listener) } catch (_: Throwable) { }
        }
        readListener = null
    }

    private fun disconnectInternal() {
        stopReadingInternal()
        try {
            if (isConnected) reader.CloseReader()
        } catch (e: Throwable) {
            Log.e(TAG, "CloseReader failed", e)
        }
        isConnected = false
        connectedAddress = ""
    }

    /** ModuleAPI_J power API: MTR_PARAM_RF_ANTPOWER / AntPowerConf. */
    private fun setReaderPower(power: Int): Boolean {
        return try {
            val powerConf = reader.new AntPowerConf()
            val getErr = reader.ParamGet(Mtr_Param.MTR_PARAM_RF_ANTPOWER, powerConf)
            if (getErr != READER_ERR.MT_OK_ERR) return false

            val antennaPower = reader.new AntPower()
            antennaPower.antid = 1
            antennaPower.readPower = power.toShort()
            antennaPower.writePower = power.toShort()
            powerConf.antcnt = 1
            powerConf.Powers[0] = antennaPower

            reader.ParamSet(Mtr_Param.MTR_PARAM_RF_ANTPOWER, powerConf) == READER_ERR.MT_OK_ERR
        } catch (e: Throwable) {
            Log.e(TAG, "Set power failed", e)
            false
        }
    }
}
