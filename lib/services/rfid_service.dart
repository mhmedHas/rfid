import 'package:flutter/services.dart';

class RfidService {
  static const MethodChannel _methods = MethodChannel('rfid/methods');
  static const EventChannel _tags = EventChannel('rfid/tags');

  static bool _isConnected = false;
  static bool _isReading = false;

  // الاتصال العام عبر SDK (للاستخدام الداخلي/الشبكة عند الحاجة).
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
      _isConnected = false;
      return false;
    }
  }

  // الاتصال الفعلي المستخدم في التطبيق: USB + Antenna 1.
  // Android RfidBridge يرسل للـSDK القيمة "USB" كما في Demo الشركة.
  static Future<bool> connectUSB() async {
    try {
      final result = await _methods.invokeMethod('connectUSB');
      _isConnected = result == true;
      return _isConnected;
    } catch (e) {
      print('❌ فشل الاتصال عبر USB: $e');
      _isConnected = false;
      return false;
    }
  }

  // البلوتوث غير مستخدم في هذا التطبيق.
  static Future<bool> connectBluetooth(String address) async {
    try {
      final result = await _methods.invokeMethod('connectBluetooth', {
        'address': address,
      });
      _isConnected = result == true;
      return _isConnected;
    } catch (e) {
      print('❌ البلوتوث غير مستخدم: $e');
      _isConnected = false;
      return false;
    }
  }

  static Future<void> disconnect() async {
    try {
      await _methods.invokeMethod('disconnect');
    } catch (e) {
      print('❌ فشل قطع الاتصال: $e');
    } finally {
      _isConnected = false;
      _isReading = false;
    }
  }

  // يبدأ Inventory غير متزامن ويعيد نجاح العملية لكي تستطيع الشاشة
  // منع إظهار "متصل" إذا فشل StartReading.
  static Future<bool> startReading() async {
    try {
      final result = await _methods.invokeMethod('startReading');
      _isReading = result == true;
      return _isReading;
    } catch (e) {
      print('❌ فشل بدء القراءة: $e');
      _isReading = false;
      return false;
    }
  }

  static Future<bool> stopReading() async {
    try {
      final result = await _methods.invokeMethod('stopReading');
      _isReading = false;
      return result == true;
    } catch (e) {
      print('❌ فشل إيقاف القراءة: $e');
      _isReading = false;
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> inventory() async {
    try {
      final result = await _methods.invokeMethod('inventory');
      return List<Map<String, dynamic>>.from(result ?? []);
    } catch (e) {
      print('❌ فشل جولة المخزون: $e');
      return [];
    }
  }

  static Future<bool> setPower(int power) async {
    try {
      final result = await _methods.invokeMethod('setPower', {'power': power});
      return result == true;
    } catch (e) {
      print('❌ فشل ضبط القوة: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> getStatus() async {
    try {
      final result = await _methods.invokeMethod('getStatus');
      return Map<String, dynamic>.from(result ?? {});
    } catch (e) {
      print('❌ فشل جلب الحالة: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> getReaderInfo() async {
    try {
      final result = await _methods.invokeMethod('getReaderInfo');
      return Map<String, dynamic>.from(result ?? {});
    } catch (e) {
      print('❌ فشل جلب المعلومات: $e');
      return {};
    }
  }

  static Stream<List<dynamic>> get tagStream {
    return _tags.receiveBroadcastStream().cast<List<dynamic>>();
  }

  static bool get isConnected => _isConnected;
  static bool get isReading => _isReading;
}
