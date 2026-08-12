package com.example.alarm

import android.util.Log
import com.uhf.api.cls.Reader
import com.uhf.api.cls.Reader.READER_ERR
import com.uhf.api.cls.ReadListener
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class RfidBridge(messenger: BinaryMessenger) {
    
    companion object {
        private const val TAG = "RfidBridge"
    }
    
    private val reader = Reader()
    private var eventSink: EventChannel.EventSink? = null
    private var isReading = false
    private var isConnected = false

    init {
        // القناة الأولى: أوامر
        MethodChannel(messenger, "rfid/methods").setMethodCallHandler { call, result ->
            when (call.method) {
                "connect" -> {
                    val address = call.argument<String>("address") ?: ""
                    val ports = call.argument<Int>("ports") ?: 1
                    val err = reader.InitReader_Notype(address, ports)
                    isConnected = err == READER_ERR.MT_OK_ERR
                    result.success(isConnected)
                }
                "connectUSB" -> {
                    val err = reader.InitReader_Notype("", 1)
                    isConnected = err == READER_ERR.MT_OK_ERR
                    result.success(isConnected)
                }
                "connectBluetooth" -> {
                    val address = call.argument<String>("address") ?: ""
                    val err = reader.InitReader_Notype(address, 1)
                    isConnected = err == READER_ERR.MT_OK_ERR
                    result.success(isConnected)
                }
                "startReading" -> {
                    if (!isConnected) {
                        result.error("NOT_CONNECTED", "الجهاز غير متصل", null)
                        return@setMethodCallHandler
                    }
                    reader.addReadListener(ReadListener { _, tags ->
                        tags?.let {
                            val tagList = it.map { tag ->
                                mapOf(
                                    "epc" to (tag.EpcId ?: ""),
                                    "rssi" to tag.RSSI,
                                    "timestamp" to System.currentTimeMillis()
                                )
                            }
                            eventSink?.success(tagList)
                        }
                    })
                    reader.AsyncStartReading(intArrayOf(1), 1, 0)
                    isReading = true
                    result.success(null)
                }
                "stopReading" -> {
                    reader.AsyncStopReading()
                    isReading = false
                    result.success(null)
                }
                "disconnect" -> {
                    reader.CloseReader()
                    isConnected = false
                    isReading = false
                    result.success(null)
                }
                "setPower" -> {
                    val power = call.argument<Int>("power") ?: 30
                    // reader.SetPower(power) // حسب SDK
                    result.success(true)
                }
                "getStatus" -> {
                    val status = mapOf(
                        "isConnected" to isConnected,
                        "isReading" to isReading,
                        "version" to "1.0.0"
                    )
                    result.success(status)
                }
                "getReaderInfo" -> {
                    val info = mapOf(
                        "model" to "UHF RFID Reader",
                        "firmware" to "1.0.0"
                    )
                    result.success(info)
                }
                "inventory" -> {
                    val tags = mutableListOf<Map<String, Any>>()
                    reader.addReadListener(ReadListener { _, tagList ->
                        tagList?.forEach { tag ->
                            tags.add(mapOf(
                                "epc" to (tag.EpcId ?: ""),
                                "rssi" to tag.RSSI
                            ))
                        }
                    })
                    reader.AsyncStartReading(intArrayOf(1), 1, 0)
                    Thread.sleep(3000)
                    reader.AsyncStopReading()
                    result.success(tags)
                }
                else -> result.notImplemented()
            }
        }

        // القناة الثانية: تدفق العلامات
        EventChannel(messenger, "rfid/tags").setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(args: Any?, sink: EventChannel.EventSink) {
                eventSink = sink
            }
            override fun onCancel(args: Any?) {
                eventSink = null
                if (isReading) {
                    reader.AsyncStopReading()
                    isReading = false
                }
            }
        })
    }
}