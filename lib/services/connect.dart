import 'dart:async';

import 'package:flutter/services.dart';

class UsbService {
  static const MethodChannel _channel = MethodChannel('com.example.alarm/usb');

  static final StreamController<UsbDeviceEvent> _eventController =
      StreamController<UsbDeviceEvent>.broadcast();

  static bool _isListening = false;

  // Stream للأحداث
  static Stream<UsbDeviceEvent> get events => _eventController.stream;

  // بدء الاستماع لأحداث USB
  static void startListening() {
    if (_isListening) return;
    _isListening = true;

    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onUsbDeviceStatus':
          final args = call.arguments as Map<dynamic, dynamic>;
          final event = UsbDeviceEvent(
            status: args['status'] as String,
            deviceId: args['deviceId'] as int?,
            vendorId: args['vendorId'] as int?,
            productId: args['productId'] as int?,
            deviceName: args['deviceName'] as String?,
            hasPermission: args['hasPermission'] as bool? ?? false,
          );
          _eventController.add(event);
          break;

        case 'onUsbPermissionResult':
          final args = call.arguments as Map<dynamic, dynamic>;
          final event = UsbDeviceEvent(
            status: 'permission_result',
            deviceId: args['deviceId'] as int?,
            granted: args['granted'] as bool? ?? false,
          );
          _eventController.add(event);
          break;
      }
      return null;
    });
  }

  // جلب قائمة أجهزة USB المتصلة
  static Future<List<UsbDevice>> getConnectedDevices() async {
    try {
      final result = await _channel.invokeMethod('getUsbDevices');
      final List<dynamic> devices = result as List<dynamic>? ?? [];
      return devices
          .map((d) => UsbDevice.fromMap(d as Map<dynamic, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error getting USB devices: $e');
      return [];
    }
  }

  // طلب صلاحية الوصول لجهاز USB
  static Future<void> requestPermission(int deviceId) async {
    try {
      await _channel.invokeMethod('requestPermission', {'deviceId': deviceId});
    } catch (e) {
      print('❌ Error requesting USB permission: $e');
    }
  }

  // إيقاف الاستماع
  static void stopListening() {
    _isListening = false;
    _channel.setMethodCallHandler(null);
  }

  // تنظيف
  static void dispose() {
    stopListening();
    _eventController.close();
  }
}

// نموذج حدث USB
class UsbDeviceEvent {
  final String status;
  final int? deviceId;
  final int? vendorId;
  final int? productId;
  final String? deviceName;
  final bool hasPermission;
  final bool granted;

  UsbDeviceEvent({
    required this.status,
    this.deviceId,
    this.vendorId,
    this.productId,
    this.deviceName,
    this.hasPermission = false,
    this.granted = false,
  });
}

// نموذج جهاز USB
class UsbDevice {
  final int deviceId;
  final int vendorId;
  final int productId;
  final String deviceName;
  final String manufacturer;
  final String product;
  final String serial;
  final int interfaceCount;
  final bool hasPermission;

  UsbDevice({
    required this.deviceId,
    required this.vendorId,
    required this.productId,
    required this.deviceName,
    required this.manufacturer,
    required this.product,
    required this.serial,
    required this.interfaceCount,
    required this.hasPermission,
  });

  factory UsbDevice.fromMap(Map<dynamic, dynamic> map) {
    return UsbDevice(
      deviceId: map['deviceId'] as int? ?? 0,
      vendorId: map['vendorId'] as int? ?? 0,
      productId: map['productId'] as int? ?? 0,
      deviceName: map['deviceName'] as String? ?? '',
      manufacturer: map['manufacturer'] as String? ?? '',
      product: map['product'] as String? ?? '',
      serial: map['serial'] as String? ?? '',
      interfaceCount: map['interfaceCount'] as int? ?? 0,
      hasPermission: map['hasPermission'] as bool? ?? false,
    );
  }

  bool get isRfidReader {
    // قائمة Vendor IDs المعروفة لقارئات RFID
    const rfidVendors = [6790, 1027, 4292, 1155, 1062];
    return rfidVendors.contains(vendorId);
  }
}
