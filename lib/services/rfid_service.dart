import 'package:flutter/services.dart';

class RfidService {
  static const MethodChannel _methods = MethodChannel('rfid/methods');
  static const EventChannel _tags = EventChannel('rfid/tags');

  static bool _isConnected = false;
  static bool _isReading = false;

  // ============ طرق الاتصال ============

  // الاتصال عبر الشبكة (Ethernet/WiFi)
  static Future<bool> connect(String address, int ports) async {
    try {
      final result = await _methods.invokeMethod('connect', {
        'address': address,
        'ports': ports,
      });
      _isConnected = result == true;
      return _isConnected;
    } catch (e) {
      print('❌ فشل الاتصال: $e');
      return false;
    }
  }

  // الاتصال عبر USB
  static Future<bool> connectUSB() async {
    try {
      final result = await _methods.invokeMethod('connectUSB');
      _isConnected = result == true;
      return _isConnected;
    } catch (e) {
      print('❌ فشل الاتصال عبر USB: $e');
      return false;
    }
  }

  // الاتصال عبر البلوتوث
  static Future<bool> connectBluetooth(String address) async {
    try {
      final result = await _methods.invokeMethod('connectBluetooth', {
        'address': address,
      });
      _isConnected = result == true;
      return _isConnected;
    } catch (e) {
      print('❌ فشل الاتصال عبر البلوتوث: $e');
      return false;
    }
  }

  // فصل الاتصال
  static Future<void> disconnect() async {
    try {
      await _methods.invokeMethod('disconnect');
      _isConnected = false;
      _isReading = false;
    } catch (e) {
      print('❌ فشل قطع الاتصال: $e');
    }
  }

  // ============ عمليات القراءة ============

  // بدء القراءة
  static Future<void> startReading() async {
    try {
      await _methods.invokeMethod('startReading');
      _isReading = true;
    } catch (e) {
      print('❌ فشل بدء القراءة: $e');
    }
  }

  // إيقاف القراءة
  static Future<void> stopReading() async {
    try {
      await _methods.invokeMethod('stopReading');
      _isReading = false;
    } catch (e) {
      print('❌ فشل إيقاف القراءة: $e');
    }
  }

  // جولة مخزون كاملة
  static Future<List<Map<String, dynamic>>> inventory() async {
    try {
      final result = await _methods.invokeMethod('inventory');
      return List<Map<String, dynamic>>.from(result ?? []);
    } catch (e) {
      print('❌ فشل جولة المخزون: $e');
      return [];
    }
  }

  // ============ الإعدادات ============

  // ضبط قوة القراءة
  static Future<bool> setPower(int power) async {
    try {
      final result = await _methods.invokeMethod('setPower', {'power': power});
      return result == true;
    } catch (e) {
      print('❌ فشل ضبط القوة: $e');
      return false;
    }
  }

  // جلب حالة الجهاز
  static Future<Map<String, dynamic>> getStatus() async {
    try {
      final result = await _methods.invokeMethod('getStatus');
      return Map<String, dynamic>.from(result ?? {});
    } catch (e) {
      print('❌ فشل جلب الحالة: $e');
      return {};
    }
  }

  // جلب معلومات القارئ
  static Future<Map<String, dynamic>> getReaderInfo() async {
    try {
      final result = await _methods.invokeMethod('getReaderInfo');
      return Map<String, dynamic>.from(result ?? {});
    } catch (e) {
      print('❌ فشل جلب المعلومات: $e');
      return {};
    }
  }

  // ============ Stream للعلامات ============

  static Stream<List<dynamic>> get tagStream {
    return _tags.receiveBroadcastStream().cast<List<dynamic>>();
  }

  // ============ Getters ============

  static bool get isConnected => _isConnected;
  static bool get isReading => _isReading;
}
