// // lib/pages/simple_inventory_page.dart

// import 'dart:async';
// import 'dart:ui' as ui;
// import 'package:alarm/firestore_service.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SimpleInventoryPage extends StatefulWidget {
//   const SimpleInventoryPage({super.key});

//   @override
//   State<SimpleInventoryPage> createState() => _SimpleInventoryPageState();
// }

// class _SimpleInventoryPageState extends State<SimpleInventoryPage> {
//   // 🔹 قائمة الـ EPCs المضافة يدوياً
//   List<String> epcs = [];

//   // 🔹 بيانات كل قطعة
//   Map<String, Map<String, dynamic>> itemsData = {};

//   // 🔹 حالة التحميل
//   bool isLoading = false;
//   String? msg;
//   String _lang = 'ar';

//   // 🔹 أسماء المستخدمين
//   List<String> userNames = [];
//   String? selectedUser;

//   @override
//   void initState() {
//     super.initState();
//     _loadLanguage();
//     _loadUserNames();

//     // 🔹 للتجربة: اطبع كل القطع في قاعدة البيانات
//     _debugPrintAllItems();
//   }

//   // ===================== دوال المساعدة =====================

//   Future<void> _loadLanguage() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _lang = prefs.getString('languageCode') ?? 'ar';
//     });
//   }

//   Future<void> _loadUserNames() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       userNames = prefs.getStringList('userNames') ?? [];
//       if (userNames.isNotEmpty) selectedUser = userNames.first;
//     });
//   }

//   /// 🔹 ترجمة سريعة
//   String _t(String ar, String en) => _lang == 'ar' ? ar : en;

//   /// 🔹 عرض رسالة
//   void showAppMessage(BuildContext context, String msg) {
//     final isSuccess = msg.contains('تم') || msg.contains('✅');
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Directionality(
//           textDirection: ui.TextDirection.rtl,
//           child: Text(msg),
//         ),
//         backgroundColor: isSuccess ? Colors.green : Colors.red,
//         duration: const Duration(seconds: 3),
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     );
//   }

//   /// 🔹 للتجربة: طباعة كل القطع في قاعدة البيانات
//   void _debugPrintAllItems() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         print('❌ المستخدم غير مسجل');
//         return;
//       }

//       final snapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('items')
//           .limit(20)
//           .get();

//       print('📦 عدد القطع في قاعدة البيانات: ${snapshot.docs.length}');

//       if (snapshot.docs.isEmpty) {
//         print('⚠️ لا توجد قطع في قاعدة البيانات!');
//         return;
//       }

//       for (var doc in snapshot.docs) {
//         final data = doc.data() as Map<String, dynamic>;
//         final payload = data['payload'] ?? {};
//         print('  📍 epcHex: ${data['epcHex']}');
//         print(
//           '     الاسم: ${payload['name'] ?? payload['kind'] ?? 'غير معروف'}',
//         );
//         print('     الوزن: ${payload['weight'] ?? 'غير محدد'}');
//       }
//     } catch (e) {
//       print('❌ خطأ في طباعة القطع: $e');
//     }
//   }

//   /// 🔹 جلب بيانات قطعة من Firebase
//   Future<void> _loadItemData(String epc) async {
//     try {
//       setState(() {
//         isLoading = true;
//         itemsData[epc] = {'loading': true};
//         msg = null;
//       });

//       print('🔍 جاري البحث عن EPC: $epc');

//       final data = await FS.findItemByEpc(epc);

//       setState(() {
//         isLoading = false;
//         if (data != null) {
//           itemsData[epc] = data;
//           print('✅ تم جلب البيانات بنجاح');
//           msg = _t('✅ تم جلب البيانات', '✅ Data loaded');
//         } else {
//           itemsData[epc] = {
//             'error': 'القطعة غير موجودة في قاعدة البيانات',
//             'epc': epc,
//           };
//           print('❌ القطعة غير موجودة: $epc');
//           msg = _t('❌ القطعة غير موجودة', '❌ Item not found');
//         }
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         itemsData[epc] = {
//           'error': 'خطأ في الاتصال: ${e.toString()}',
//           'epc': epc,
//         };
//         msg = _t('❌ خطأ في الاتصال', '❌ Connection error');
//       });
//       print('❌ خطأ في _loadItemData: $e');
//     }
//   }

//   /// 🔹 إضافة EPC يدوياً
//   void _addEpcManually(String epc) {
//     if (epc.isEmpty) {
//       showAppMessage(
//         context,
//         _t('الرجاء إدخال رقم الشريحة', 'Please enter tag EPC'),
//       );
//       return;
//     }

//     if (epcs.contains(epc)) {
//       showAppMessage(
//         context,
//         _t('القطعة موجودة بالفعل', 'Item already exists'),
//       );
//       return;
//     }

//     setState(() {
//       epcs.add(epc);
//       itemsData[epc] = {'loading': true};
//     });

//     _loadItemData(epc);
//   }

//   /// 🔹 حذف قطعة من القائمة
//   void _removeItem(String epc) {
//     setState(() {
//       epcs.remove(epc);
//       itemsData.remove(epc);
//     });
//     showAppMessage(context, _t('تم الحذف', 'Removed'));
//   }

//   /// 🔹 مسح القائمة بالكامل
//   void _clearAll() {
//     if (epcs.isEmpty) {
//       showAppMessage(context, _t('القائمة فارغة', 'List is empty'));
//       return;
//     }
//     setState(() {
//       epcs.clear();
//       itemsData.clear();
//       msg = null;
//     });
//     showAppMessage(context, _t('✅ تم مسح القائمة', '✅ List cleared'));
//   }

//   /// 🔹 عرض الصورة بشكل مكبر
//   void _showFullImage(BuildContext context, String imageUrl) {
//     showDialog(
//       context: context,
//       barrierColor: Colors.black.withOpacity(0.9),
//       builder: (_) => GestureDetector(
//         onTap: () => Navigator.pop(context),
//         child: Dialog(
//           backgroundColor: Colors.transparent,
//           insetPadding: const EdgeInsets.all(10),
//           child: InteractiveViewer(
//             minScale: 0.8,
//             maxScale: 4,
//             child: Image.network(imageUrl, fit: BoxFit.contain),
//           ),
//         ),
//       ),
//     );
//   }

//   // ===================== واجهة المستخدم =====================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Text(
//           _t('جرد بسيط', 'Simple Inventory'),
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 1,
//         centerTitle: true,
//         actions: [
//           // 🔹 زر مسح الكل
//           IconButton(
//             icon: const Icon(Icons.delete_sweep, color: Colors.red),
//             tooltip: _t('مسح الكل', 'Clear all'),
//             onPressed: _clearAll,
//           ),
//           // 🔹 زر Debug
//           IconButton(
//             icon: const Icon(Icons.abc, color: Colors.orange),
//             tooltip: 'Debug',
//             onPressed: _debugPrintAllItems,
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: const Color(0xFFD4AF37),
//         onPressed: _showManualEpcDialog,
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 🔹 اختيار المستخدم
//             if (userNames.isNotEmpty) ...[
//               Row(
//                 children: [
//                   Text(
//                     _t('المستخدم:', 'User:'),
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: DropdownButton<String>(
//                       value: selectedUser,
//                       isExpanded: true,
//                       hint: Text(_t('اختر المستخدم', 'Select User')),
//                       items: userNames.map((name) {
//                         return DropdownMenuItem(value: name, child: Text(name));
//                       }).toList(),
//                       onChanged: (val) => setState(() => selectedUser = val),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//             ],

//             // 🔹 شريط الإحصائيات (مثل الصورة المطلوبة)
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.grey[200]!),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.05),
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // 🔹 حالة الجلسة
//                   Row(
//                     children: [
//                       Container(
//                         width: 10,
//                         height: 10,
//                         decoration: const BoxDecoration(
//                           color: Colors.green,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         _t('مؤمن', 'SECURE'),
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green[700],
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                   // 🔹 عدد القطع
//                   Row(
//                     children: [
//                       Icon(Icons.inventory, color: Colors.blue[700], size: 20),
//                       const SizedBox(width: 8),
//                       Text(
//                         _t('القطع:', 'Items:'),
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.grey[700],
//                           fontSize: 14,
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         '${epcs.length}',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue[700],
//                         ),
//                       ),
//                     ],
//                   ),
//                   // 🔹 رسالة الحالة المختصرة
//                   if (msg != null)
//                     Text(
//                       msg!.contains('✅') ? '🟢' : '🔴',
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 16),

//             // 🔹 رسالة الخطأ الكاملة (إذا وجدت)
//             if (msg != null && !msg!.contains('✅'))
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.red[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.red.shade200),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.error, color: Colors.red[400], size: 18),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         msg!,
//                         style: TextStyle(color: Colors.red[800], fontSize: 13),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//             const SizedBox(height: 12),

//             // 🔹 القائمة الرئيسية (List - مثل الصورة المطلوبة)
//             Expanded(
//               child: epcs.isEmpty
//                   ? Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.inventory_2_outlined,
//                             size: 80,
//                             color: Colors.grey[400],
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             _t('لا توجد قطع', 'No items'),
//                             style: TextStyle(
//                               fontSize: 18,
//                               color: Colors.grey[600],
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             _t('اضغط على زر + للإضافة', 'Tap + button to add'),
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[500],
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           ElevatedButton.icon(
//                             onPressed: _debugPrintAllItems,
//                             icon: const Icon(Icons.abc),
//                             label: const Text('عرض البيانات في Console'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.grey[200],
//                               foregroundColor: Colors.black87,
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   : ListView.builder(
//                       itemCount: epcs.length,
//                       itemBuilder: (context, index) {
//                         final epc = epcs[index];
//                         return _buildItemCard(epc);
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ===================== بطاقة القطعة (تصميم قائمة مثل الصورة) =====================

//   Widget _buildItemCard(String epc) {
//     final itemData = itemsData[epc];

//     // 🔹 إذا كان جاري التحميل
//     if (itemData == null || itemData['loading'] == true) {
//       return Card(
//         margin: const EdgeInsets.only(bottom: 12),
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: const SizedBox(
//           height: 120,
//           child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
//         ),
//       );
//     }

//     // 🔹 إذا كان هناك خطأ
//     if (itemData['error'] != null) {
//       return Card(
//         margin: const EdgeInsets.only(bottom: 12),
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//           side: BorderSide(color: Colors.red[300]!, width: 1.5),
//         ),
//         child: SizedBox(
//           height: 100,
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               children: [
//                 Icon(Icons.error_outline, color: Colors.red[400], size: 40),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         _t('خطأ', 'Error'),
//                         style: TextStyle(
//                           color: Colors.red[400],
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         itemData['error'] ??
//                             _t('بيانات غير متاحة', 'Data not available'),
//                         style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//                       ),
//                       Text(
//                         'EPC: ${itemData['epc'] ?? epc}',
//                         style: TextStyle(fontSize: 11, color: Colors.grey[500]),
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.close, color: Colors.red[300], size: 28),
//                   onPressed: () => _removeItem(epc),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     // 🔹 عرض البيانات العادي
//     final payload = itemData['payload'] ?? {};
//     final epcHex = itemData['epcHex']?.toString() ?? epc;

//     // 🔹 استخراج البيانات
//     String itemName =
//         payload['name'] ?? payload['kind'] ?? payload['type'] ?? 'غير معروف';

//     String itemType =
//         payload['kind'] ?? payload['type'] ?? payload['category'] ?? '';

//     String weight = payload['weight'] != null ? '${payload['weight']} جم' : '';

//     // 🔹 جلب الصورة
//     return FutureBuilder<String?>(
//       future: _getFirstImage(epcHex),
//       builder: (context, snapshot) {
//         final imageUrl = snapshot.data;

//         return Card(
//           margin: const EdgeInsets.only(bottom: 12),
//           elevation: 3,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//             side: BorderSide(color: Colors.grey[200]!, width: 1),
//           ),
//           child: InkWell(
//             onTap: () {
//               if (imageUrl != null) {
//                 _showFullImage(context, imageUrl);
//               }
//             },
//             borderRadius: BorderRadius.circular(12),
//             child: SizedBox(
//               height: 130, // ارتفاع ثابت مناسب للتابلت
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // 🔹 الصورة (يسار أو يمين حسب اللغة)
//                   Container(
//                     width: 130,
//                     height: 130,
//                     decoration: BoxDecoration(
//                       borderRadius: const BorderRadius.horizontal(
//                         left: Radius.circular(12),
//                       ),
//                       color: Colors.grey[100],
//                     ),
//                     child: snapshot.connectionState == ConnectionState.waiting
//                         ? const Center(
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : imageUrl != null
//                         ? ClipRRect(
//                             borderRadius: const BorderRadius.horizontal(
//                               left: Radius.circular(12),
//                             ),
//                             child: Image.network(
//                               imageUrl,
//                               fit: BoxFit.cover,
//                               width: 130,
//                               height: 130,
//                               loadingBuilder:
//                                   (context, child, loadingProgress) {
//                                     if (loadingProgress == null) return child;
//                                     return const Center(
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                       ),
//                                     );
//                                   },
//                               errorBuilder: (_, __, ___) => const Center(
//                                 child: Icon(
//                                   Icons.broken_image,
//                                   size: 50,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                             ),
//                           )
//                         : Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   Icons.image_not_supported,
//                                   size: 40,
//                                   color: Colors.grey[400],
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   _t('لا توجد صورة', 'No image'),
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     color: Colors.grey[500],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                   ),

//                   // 🔹 البيانات (نص)
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.all(14),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           // 🔹 اسم القطعة (كبير وواضح)
//                           Text(
//                             itemName,
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 6),

//                           // 🔹 النوع والوزن في سطر واحد (مثل الصورة)
//                           Row(
//                             children: [
//                               if (itemType.isNotEmpty) ...[
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 10,
//                                     vertical: 4,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey[200],
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Text(
//                                     itemType,
//                                     style: TextStyle(
//                                       fontSize: 13,
//                                       color: Colors.grey[700],
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                               ],
//                               if (weight.isNotEmpty) ...[
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 10,
//                                     vertical: 4,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.blue[50],
//                                     borderRadius: BorderRadius.circular(12),
//                                     border: Border.all(
//                                       color: Colors.blue[200]!,
//                                     ),
//                                   ),
//                                   child: Text(
//                                     weight,
//                                     style: TextStyle(
//                                       fontSize: 13,
//                                       color: Colors.blue[700],
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ],
//                           ),

//                           const SizedBox(height: 8),

//                           // 🔹 EPC (صغير)
//                           Text(
//                             'EPC: ${epcHex.length > 16 ? '${epcHex.substring(0, 16)}...' : epcHex}',
//                             style: TextStyle(
//                               fontSize: 11,
//                               color: Colors.grey[500],
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   // 🔹 زر الحذف
//                   Padding(
//                     padding: const EdgeInsets.all(8),
//                     child: IconButton(
//                       icon: Icon(Icons.close, color: Colors.red[300], size: 28),
//                       onPressed: () => _removeItem(epc),
//                       padding: EdgeInsets.zero,
//                       constraints: const BoxConstraints(),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   /// 🔹 جلب الصورة الأولى من Firebase Storage
//   Future<String?> _getFirstImage(String epcHex) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return null;

//       final storageRef = FirebaseStorage.instance
//           .ref()
//           .child('images')
//           .child('users')
//           .child(user.uid)
//           .child(epcHex.toUpperCase());

//       final result = await storageRef.listAll();

//       if (result.items.isNotEmpty) {
//         return await result.items.first.getDownloadURL();
//       }
//       return null;
//     } catch (e) {
//       print('❌ خطأ في جلب الصورة: $e');
//       return null;
//     }
//   }

//   // ===================== حوار الإضافة اليدوية =====================

//   void _showManualEpcDialog() {
//     final controller = TextEditingController();

//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (ctx) => AlertDialog(
//         title: Text(_t('إضافة شريحة يدوياً', 'Add Tag Manually')),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               _t('أدخل رقم الشريحة (EPC)', 'Enter Tag EPC'),
//               style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: controller,
//               decoration: InputDecoration(
//                 hintText: _t('مثال: E2001234567890', 'Example: E2001234567890'),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.grey[300]!),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: Color(0xFFD4AF37)),
//                 ),
//                 prefixIcon: const Icon(Icons.qr_code),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 14,
//                 ),
//               ),
//               textDirection: ui.TextDirection.ltr,
//               textCapitalization: TextCapitalization.characters,
//               onSubmitted: (value) {
//                 Navigator.pop(ctx);
//                 if (value.trim().isNotEmpty) {
//                   _addEpcManually(value.trim());
//                 }
//               },
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: Text(_t('إلغاء', 'Cancel')),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFD4AF37),
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             onPressed: () {
//               final epc = controller.text.trim();
//               Navigator.pop(ctx);
//               if (epc.isNotEmpty) {
//                 _addEpcManually(epc);
//               }
//             },
//             child: Text(_t('إضافة', 'Add')),
//           ),
//         ],
//       ),
//     );
//   }
// }
