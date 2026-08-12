// lib/services/firestore_service.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FS {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 الحصول على UID المستخدم الحالي
  static String get uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('المستخدم غير مسجل');
    }
    return user.uid;
  }

  /// 🔹 مرجع لمجموعة items الخاصة بالمستخدم
  static CollectionReference itemsCol() {
    return _firestore.collection('users').doc(uid).collection('items');
  }

  /// 🔹 مرجع لمجموعة balances الخاصة بالمستخدم
  static CollectionReference balancesCol() {
    return _firestore.collection('users').doc(uid).collection('balances');
  }

  /// 🔹 جلب بيانات قطعة بواسطة EPC (محسّن للبحث في هيكل المستخدم)
  static Future<Map<String, dynamic>?> findItemByEpc(String epcHex) async {
    try {
      if (epcHex.isEmpty) return null;

      final cleanEpc = epcHex.trim().toUpperCase();
      print('🔍 البحث عن: $cleanEpc');

      // 🔹 البحث في items الخاصة بالمستخدم
      var q = await itemsCol()
          .where('epcHex', isEqualTo: cleanEpc)
          .limit(1)
          .get();

      print('📄 عدد النتائج في items: ${q.docs.length}');

      // 🔹 لو مفيش نتيجة، جرب البحث في balances
      if (q.docs.isEmpty) {
        q = await balancesCol()
            .where('epcHex', isEqualTo: cleanEpc)
            .limit(1)
            .get();
        print('📄 عدد النتائج في balances: ${q.docs.length}');
      }

      // 🔹 لو مفيش نتيجة، جرب البحث في payload.qrCode
      if (q.docs.isEmpty) {
        q = await itemsCol()
            .where('payload.qrCode', isEqualTo: epcHex.trim())
            .limit(1)
            .get();
        print('📄 عدد النتائج في payload.qrCode: ${q.docs.length}');
      }

      if (q.docs.isEmpty) {
        print('❌ لم يتم العثور على القطعة');
        return null;
      }

      final doc = q.docs.first;
      final data = doc.data() as Map<String, dynamic>;

      print('✅ تم العثور على القطعة');
      return {'id': doc.id, ...data};
    } catch (e) {
      print('❌ خطأ في findItemByEpc: $e');
      return null;
    }
  }

  /// 🔹 دالة مساعدة لعرض كل القطع في قاعدة البيانات
  static Future<void> printAllItems() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ المستخدم غير مسجل');
        return;
      }

      print('👤 المستخدم: ${user.email}');
      print('🆔 UID: ${user.uid}');

      final snapshot = await itemsCol().limit(20).get();

      print('📦 عدد القطع في قاعدة البيانات: ${snapshot.docs.length}');

      if (snapshot.docs.isEmpty) {
        print('⚠️ لا توجد قطع في قاعدة البيانات!');
        print('💡 تحقق من:');
        print('   1. هناك بيانات مضافة في users/{uid}/items');
        print('   2. قواعد الأمان تسمح بالقراءة');
        print('   3. المستخدم مسجل دخول');
        return;
      }

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final payload = data['payload'] ?? {};
        final name = payload['name'] ?? payload['kind'] ?? 'غير معروف';
        final weight = payload['weight'] ?? 'غير محدد';
        print('  📍 epcHex: ${data['epcHex']}');
        print('     الاسم: $name');
        print('     الوزن: $weight');
        print(
          '     النوع: ${payload['kind'] ?? payload['type'] ?? 'غير محدد'}',
        );
        print('  ──────────────────────────────');
      }
    } catch (e) {
      print('❌ خطأ في printAllItems: $e');
    }
  }

  /// 🔹 دالة مساعدة للبحث عن قطعة معينة (للتجربة)
  static Future<void> debugFindItem(String epc) async {
    print('🔍 جاري البحث عن: $epc');
    final result = await findItemByEpc(epc);
    if (result != null) {
      final payload = result['payload'] ?? {};
      print('✅ تم العثور على القطعة:');
      print('  - epcHex: ${result['epcHex']}');
      print('  - category: ${result['category']}');
      print('  - الاسم: ${payload['name'] ?? payload['kind'] ?? 'غير معروف'}');
      print('  - الوزن: ${payload['weight'] ?? 'غير محدد'}');
      print('  - النوع: ${payload['kind'] ?? payload['type'] ?? 'غير محدد'}');
    } else {
      print('❌ لم يتم العثور على القطعة');
      print('💡 تأكد من:');
      print('   1. رقم EPC صحيح');
      print('   2. القطعة مسجلة في users/{uid}/items');
      print('   3. المستخدم مسجل دخول');
    }
  }

  /// 🔹 دوال إضافية للتوافق مع كود صفحة البيع
  static Future<Map<String, dynamic>?> epcandcode(String epc) async {
    return await findItemByEpc(epc);
  }

  static Future<void> sellItem(
    String epc, {
    required String saleGroupId,
    bool partialSale = false,
    List<String> soldComponents = const [],
    double weightSold = 0,
    double wageSold = 0,
    required Map<String, dynamic> paymentData,
  }) async {
    print('💰 تم بيع القطعة: $epc');
    // هذه الدالة تستخدم في صفحة البيع فقط
  }
}
