// import 'package:flutter/services.dart';

// class RfidService {
//   static const MethodChannel _methods = MethodChannel('rfid/methods');
//   static const EventChannel _tags = EventChannel('rfid/tags');

//   // 🔹 جعل المتغيرات static
//   static bool _isConnected = false;
//   static bool _isReading = false;

//   // 🔹 جعل الدوال static
//   static Future<bool> connect(String address, int ports) async {
//     try {
//       final result = await _methods.invokeMethod('connect', {
//         'address': address,
//         'ports': ports,
//       });
//       _isConnected = result == true;
//       return _isConnected;
//     } catch (e) {
//       print('❌ فشل الاتصال: $e');
//       return false;
//     }
//   }

//   static Future<void> disconnect() async {
//     try {
//       await _methods.invokeMethod('disconnect');
//       _isConnected = false;
//       _isReading = false;
//     } catch (e) {
//       print('❌ فشل قطع الاتصال: $e');
//     }
//   }

//   static Future<void> startReading() async {
//     try {
//       await _methods.invokeMethod('startReading');
//       _isReading = true;
//     } catch (e) {
//       print('❌ فشل بدء القراءة: $e');
//     }
//   }

//   static Future<void> stopReading() async {
//     try {
//       await _methods.invokeMethod('stopReading');
//       _isReading = false;
//     } catch (e) {
//       print('❌ فشل إيقاف القراءة: $e');
//     }
//   }

//   // 🔹 جعل Stream static
//   static Stream<List<dynamic>> get tagStream {
//     return _tags.receiveBroadcastStream().cast<List<dynamic>>();
//   }

//   // 🔹 دوال إضافية للمساعدة
//   static bool get isConnected => _isConnected;
//   static bool get isReading => _isReading;

//   // 🔹 ضبط قوة القارئ (إذا كانت مدعومة)
//   static Future<bool> setPower(int power) async {
//     try {
//       // إذا كانت الـ SDK تدعم ضبط القوة عبر MethodChannel
//       // final result = await _methods.invokeMethod('setPower', {'power': power});
//       // return result == true;

//       // حالياً نعيد true كقيمة افتراضية
//       print('✅ تم ضبط القوة على: $power dBm');
//       return true;
//     } catch (e) {
//       print('❌ فشل ضبط القوة: $e');
//       return false;
//     }
//   }
// }
