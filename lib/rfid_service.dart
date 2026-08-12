import 'package:flutter/services.dart';

class RfidService {
  static const MethodChannel _methods = MethodChannel('rfid/methods');
  static const EventChannel _tags = EventChannel('rfid/tags');

  static Stream<List<Map<String, dynamic>>> get tagStream =>
      _tags.receiveBroadcastStream().map((event) {
        final list = (event as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      });

  static Future<bool> connectUSB() async {
    final result = await _methods.invokeMethod<bool>('connectUSB');
    return result == true;
  }

  static Future<void> disconnect() async {
    await _methods.invokeMethod('disconnect');
  }

  static Future<bool> startReading() async {
    final result = await _methods.invokeMethod<bool>('startReading');
    return result == true;
  }

  static Future<void> stopReading() async {
    await _methods.invokeMethod('stopReading');
  }

  static Future<bool> setPower(int power) async {
    final result = await _methods.invokeMethod<bool>('setPower', {'power': power});
    return result == true;
  }

  static Future<Map<String, dynamic>> getStatus() async {
    final result = await _methods.invokeMethod('getStatus');
    return Map<String, dynamic>.from(result ?? const {});
  }
}
