import 'dart:async';

import 'package:flutter/services.dart';

class UsbService {
  static const MethodChannel _channel = MethodChannel('com.example.alarm/usb');

  static final StreamController<UsbDeviceEvent> _eventController =
      StreamController<UsbDeviceEvent>.broadcast();

  static bool _isListening = false;

  static Stream<UsbDeviceEvent> get events => _eventController.stream;

  static void startListening() {
    if (_isListening) return;
    _isListening = true;

    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onUsbDeviceStatus':
          final args = Map<dynamic, dynamic>.from(
            call.arguments as Map<dynamic, dynamic>,
          );
          _eventController.add(
            UsbDeviceEvent(
              status: args['status'] as String? ?? 'unknown',
              deviceId: args['deviceId'] as int?,
              vendorId: args['vendorId'] as int?,
              productId: args['productId'] as int?,
              deviceName: args['deviceName'] as String?,
              manufacturer: args['manufacturer'] as String?,
              product: args['product'] as String?,
              hasPermission: args['hasPermission'] as bool? ?? false,
            ),
          );
          break;

        case 'onUsbPermissionResult':
          final args = Map<dynamic, dynamic>.from(
            call.arguments as Map<dynamic, dynamic>,
          );
          _eventController.add(
            UsbDeviceEvent(
              status: 'permission_result',
              deviceId: args['deviceId'] as int?,
              vendorId: args['vendorId'] as int?,
              productId: args['productId'] as int?,
              deviceName: args['deviceName'] as String?,
              granted: args['granted'] as bool? ?? false,
              hasPermission: args['granted'] as bool? ?? false,
            ),
          );
          break;
      }
      return null;
    });
  }

  static Future<List<UsbDevice>> getConnectedDevices() async {
    try {
      final result = await _channel.invokeMethod('getUsbDevices');
      final devices = result is List ? result : const <dynamic>[];
      return devices
          .whereType<Map<dynamic, dynamic>>()
          .map(UsbDevice.fromMap)
          .toList();
    } catch (e) {
      print('❌ Error getting USB devices: $e');
      return [];
    }
  }

  static Future<void> requestPermission(int deviceId) async {
    try {
      await _channel.invokeMethod(
        'requestPermission',
        {'deviceId': deviceId},
      );
    } catch (e) {
      print('❌ Error requesting USB permission: $e');
    }
  }

  static Future<bool> hasPermission(int deviceId) async {
    try {
      final result = await _channel.invokeMethod(
        'hasPermission',
        {'deviceId': deviceId},
      );
      return result == true;
    } catch (e) {
      return false;
    }
  }

  static void stopListening() {
    _isListening = false;
    _channel.setMethodCallHandler(null);
  }

  static void dispose() {
    stopListening();
    if (!_eventController.isClosed) {
      _eventController.close();
    }
  }
}

class UsbDeviceEvent {
  final String status;
  final int? deviceId;
  final int? vendorId;
  final int? productId;
  final String? deviceName;
  final String? manufacturer;
  final String? product;
  final bool hasPermission;
  final bool granted;

  UsbDeviceEvent({
    required this.status,
    this.deviceId,
    this.vendorId,
    this.productId,
    this.deviceName,
    this.manufacturer,
    this.product,
    this.hasPermission = false,
    this.granted = false,
  });
}

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
  final bool isKnownRfidVendor;

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
    this.isKnownRfidVendor = false,
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
      isKnownRfidVendor: map['isKnownRfidVendor'] as bool? ?? false,
    );
  }

  ///
  /// The supplied UHF_Demo shows the reader as:
  /// "Composite Device HID&KBD".
  ///
  /// Some of these readers do not expose a vendor ID from the Android USB
  /// layer that is in our old hard-coded list. Therefore we also recognize
  /// the reader by its USB product/device description.
  ///
  bool get isRfidReader {
    const rfidVendors = [6790, 1027, 4292, 1155, 1062];
    if (isKnownRfidVendor || rfidVendors.contains(vendorId)) {
      return true;
    }

    final identity = '$deviceName $manufacturer $product'.toLowerCase();
    const keywords = [
      'uhf',
      'rfid',
      'hid&kbd',
      'hid & kbd',
      'composite device',
      'uhf reader',
      'rfid reader',
    ];

    return keywords.any(identity.contains);
  }
}
