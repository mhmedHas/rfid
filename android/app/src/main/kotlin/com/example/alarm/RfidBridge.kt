package com.example.alarm

import android.util.Log
import com.uhf.api.cls.ReadListener
import com.uhf.api.cls.Reader
import com.uhf.api.cls.Reader.READER_ERR
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class RfidBridge(messenger: BinaryMessenger) {
    companion object { private const val TAG = "RfidBridge" }

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
                    val address = call.argument<String>("address") ?: ""
                    val ports = call.argument<Int>("ports") ?: 1
                    result.success(connectReader(address, ports))
                }
                "connectUSB" -> result.success(connectUsbReader())
                "connectBluetooth" -> {
                    val address = call.argument<String>("address") ?: ""
                    result.success(connectReader(address, 1))
                }
                "startReading" -> startReading(result)
                "stopReading" -> { stopReadingInternal(); result.success(true) }
                "disconnect" -> {
                    stopReadingInternal()
                    try { reader.CloseReader() } catch (e: Exception) { Log.e(TAG, "CloseReader failed", e) }
                    isConnected = false
                    connectedAddress = ""
                    result.success(true)
                }
                "setPower" -> result.success(setReaderPower(call.argument<Int>("power") ?: 3000))
                "getStatus" -> result.success(mapOf("isConnected" to isConnected, "isReading" to isReading, "address" to connectedAddress, "module" to "UHF RFID Reader"))
                "getReaderInfo" -> result.success(mapOf("model" to "UHF RFID Reader", "address" to connectedAddress))
                else -> result.notImplemented()
            }
        }

        EventChannel(messenger, "rfid/tags").setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(args: Any?, sink: EventChannel.EventSink) { eventSink = sink }
            override fun onCancel(args: Any?) { eventSink = null }
        })
    }

    private fun startReading(result: MethodChannel.Result) {
        if (!isConnected) {
            result.error("NOT_CONNECTED", "الجهاز غير متصل", null)
            return
        }
        if (isReading) { result.success(true); return }

        readListener = ReadListener { _, tags ->
            if (tags == null || tags.isEmpty()) return@ReadListener
            val list = tags.mapNotNull { tag ->
                try {
                    val epc = Reader.bytes_Hexstr(tag.EpcId).uppercase()
                    if (epc.isEmpty()) return@mapNotNull null
                    mapOf(
                        "epc" to epc,
                        "rssi" to tag.RSSI,
                        "antenna" to tag.AntennaID,
                        "frequency" to tag.Frequency,
                        "timestamp" to tag.TimeStamp,
                        "readCount" to tag.ReadCnt,
                        "protocol" to tag.protocol.toString()
                    )
                } catch (e: Exception) {
                    Log.e(TAG, "RFID tag conversion failed", e)
                    null
                }
            }
            if (list.isNotEmpty()) eventSink?.success(list)
        }

        reader.addReadListener(readListener!!)

        // Official SDK general asynchronous inventory: StartReading + BackReadOption + ReadListener.
        val option = reader.BackReadOption()
        option.IsFastRead = false
        option.ReadDuration = 250
        option.ReadInterval = 0
        option.TMFlags.IsAntennaID = true
        option.TMFlags.IsRSSI = true
        option.TMFlags.IsFrequency = true

        val err = reader.StartReading(intArrayOf(1), 1, option)
        if (err != READER_ERR.MT_OK_ERR) {
            reader.removeReadListener(readListener!!)
            readListener = null
            result.error("START_READING_FAILED", err.toString(), null)
            return
        }
        isReading = true
        result.success(true)
    }

    private fun connectReader(address: String, ports: Int): Boolean {
        return try {
            if (isConnected) return true
            val err = reader.InitReader_Notype(address, ports)
            isConnected = err == READER_ERR.MT_OK_ERR
            if (isConnected) connectedAddress = address
            isConnected
        } catch (e: Exception) {
            Log.e(TAG, "Reader connection failed: $address", e)
            false
        }
    }

    private fun connectUsbReader(): Boolean {
        if (isConnected) return true
        val candidates = listOf("", "/dev/ttyUSB0", "/dev/ttyACM0", "/dev/ttyMT1", "/dev/ttyS1")
        for (address in candidates) if (connectReader(address, 1)) return true
        return false
    }

    private fun stopReadingInternal() {
        if (isReading) {
            try { reader.StopReading() } catch (e: Exception) { Log.e(TAG, "StopReading failed", e) }
        }
        isReading = false
        readListener?.let { listener ->
            try { reader.removeReadListener(listener) } catch (_: Exception) {}
        }
        readListener = null
    }

    private fun setReaderPower(power: Int): Boolean {
        return try {
            val safePower = power.coerceIn(500, 3000)
            val conf = reader.AntPowerConf()
            conf.antcnt = 1
            val antPower = reader.AntPower()
            antPower.antid = 1
            antPower.readPower = safePower.toShort()
            antPower.writePower = safePower.toShort()
            conf.Powers[0] = antPower
            reader.ParamSet(Reader.Mtr_Param.MTR_PARAM_RF_ANTPOWER, conf) == READER_ERR.MT_OK_ERR
        } catch (e: Exception) {
            Log.e(TAG, "setPower failed", e)
            false
        }
    }
}
