// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import '../providers/inventory_provider.dart';
// // import '../providers/rfid_provider.dart';
// // import '../widgets/inventory_card.dart';

// // class InventoryPage extends StatefulWidget {
// //   const InventoryPage({super.key});

// //   @override
// //   State<InventoryPage> createState() => _InventoryPageState();
// // }

// // class _InventoryPageState extends State<InventoryPage> {
// //   String _searchQuery = '';

// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       final inventoryProvider = Provider.of<InventoryProvider>(
// //         context,
// //         listen: false,
// //       );
// //       inventoryProvider.initialize();

// //       // بدء القراءة التلقائية إذا كان القارئ متصلاً
// //       final rfidProvider = Provider.of<RfidProvider>(context, listen: false);
// //       if (rfidProvider.isConnected && !rfidProvider.isReading) {
// //         rfidProvider.startReading();
// //       }
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFF0D0B08),
// //       appBar: _buildAppBar(),
// //       body: Column(
// //         children: [
// //           _buildConnectionStatus(),
// //           Consumer<InventoryProvider>(
// //             builder: (context, provider, child) {
// //               if (provider.isLoading) {
// //                 return const Expanded(
// //                   child: Center(
// //                     child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
// //                   ),
// //                 );
// //               }

// //               if (provider.error != null) {
// //                 return Expanded(child: _buildErrorView(provider.error!));
// //               }

// //               return Expanded(
// //                 child: Column(
// //                   children: [
// //                     _buildStatusBar(provider),
// //                     _buildSearchBar(),
// //                     Expanded(
// //                       child: provider.filteredItems.isEmpty
// //                           ? _buildEmptyView()
// //                           : _buildItemList(provider),
// //                     ),
// //                   ],
// //                 ),
// //               );
// //             },
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   PreferredSizeWidget _buildAppBar() {
// //     return AppBar(
// //       title: const Text('المخزون'),
// //       backgroundColor: const Color(0xFF1A1510),
// //       elevation: 0,
// //       actions: [
// //         IconButton(
// //           icon: const Icon(Icons.refresh),
// //           onPressed: () {
// //             Provider.of<InventoryProvider>(
// //               context,
// //               listen: false,
// //             ).refreshItems();
// //           },
// //         ),
// //         IconButton(
// //           icon: const Icon(Icons.warning_amber),
// //           onPressed: () {
// //             Navigator.pushNamed(context, '/missing');
// //           },
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildConnectionStatus() {
// //     return Consumer<RfidProvider>(
// //       builder: (context, provider, child) {
// //         Color statusColor;
// //         String statusText;
// //         IconData statusIcon;

// //         if (provider.isConnected) {
// //           statusColor = Colors.green;
// //           statusText = '✅ القارئ متصل';
// //           statusIcon = Icons.usb;
// //         } else if (provider.isAutoConnecting || provider.isConnecting) {
// //           statusColor = Colors.orange;
// //           statusText = '⏳ جاري الاتصال...';
// //           statusIcon = Icons.hourglass_top;
// //         } else {
// //           statusColor = Colors.red;
// //           statusText = '❌ القارئ غير متصل';
// //           statusIcon = Icons.usb_off;
// //         }

// //         return Container(
// //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //           color: statusColor.withOpacity(0.1),
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(statusIcon, color: statusColor, size: 16),
// //               const SizedBox(width: 8),
// //               Text(
// //                 statusText,
// //                 style: TextStyle(
// //                   color: statusColor,
// //                   fontSize: 13,
// //                   fontWeight: FontWeight.w500,
// //                 ),
// //               ),
// //               if (!provider.isConnected && !provider.isAutoConnecting) ...[
// //                 const SizedBox(width: 16),
// //                 GestureDetector(
// //                   onTap: () {
// //                     provider.retryAutoConnect();
// //                   },
// //                   child: const Text(
// //                     'إعادة المحاولة',
// //                     style: TextStyle(
// //                       color: Color(0xFFD4AF37),
// //                       fontSize: 12,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildStatusBar(InventoryProvider provider) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //       color: const Color(0xFF1A1510),
// //       child: Row(
// //         children: [
// //           _buildStatusItem(
// //             icon: Icons.inventory,
// //             label: 'الإجمالي',
// //             value: '${provider.totalItems}',
// //           ),
// //           _buildStatusItem(
// //             icon: Icons.check_circle,
// //             label: 'الموجود',
// //             value: '${provider.presentItems}',
// //             color: Colors.green,
// //           ),
// //           _buildStatusItem(
// //             icon: Icons.warning,
// //             label: 'المفقود',
// //             value: '${provider.missingCount}',
// //             color: provider.missingCount > 0 ? Colors.red : Colors.green,
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildStatusItem({
// //     required IconData icon,
// //     required String label,
// //     required String value,
// //     Color? color,
// //   }) {
// //     return Expanded(
// //       child: Column(
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(icon, color: const Color(0xFFD4AF37), size: 14),
// //               const SizedBox(width: 4),
// //               Text(
// //                 label,
// //                 style: const TextStyle(color: Color(0xFFA09582), fontSize: 11),
// //               ),
// //             ],
// //           ),
// //           Text(
// //             value,
// //             style: TextStyle(
// //               color: color ?? const Color(0xFFF8F5F0),
// //               fontSize: 18,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildSearchBar() {
// //     return Padding(
// //       padding: const EdgeInsets.all(12),
// //       child: Container(
// //         decoration: BoxDecoration(
// //           color: const Color(0xFF2A2520),
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //         child: TextField(
// //           onChanged: (value) {
// //             setState(() => _searchQuery = value.toLowerCase());
// //           },
// //           style: const TextStyle(color: Color(0xFFF8F5F0)),
// //           decoration: InputDecoration(
// //             hintText: 'بحث عن عنصر...',
// //             hintStyle: const TextStyle(color: Color(0xFFA09582)),
// //             prefixIcon: const Icon(Icons.search, color: Color(0xFFA09582)),
// //             suffixIcon: _searchQuery.isNotEmpty
// //                 ? IconButton(
// //                     icon: const Icon(Icons.clear, color: Color(0xFFA09582)),
// //                     onPressed: () {
// //                       setState(() => _searchQuery = '');
// //                     },
// //                   )
// //                 : null,
// //             border: InputBorder.none,
// //             contentPadding: const EdgeInsets.all(12),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildItemList(InventoryProvider provider) {
// //     final items = provider.filteredItems.where((item) {
// //       if (_searchQuery.isEmpty) return true;
// //       return item.name.toLowerCase().contains(_searchQuery) ||
// //           item.epc.toLowerCase().contains(_searchQuery) ||
// //           item.code.toLowerCase().contains(_searchQuery);
// //     }).toList();

// //     return ListView.builder(
// //       padding: const EdgeInsets.only(bottom: 80),
// //       itemCount: items.length,
// //       itemBuilder: (context, index) {
// //         return InventoryCard(item: items[index]);
// //       },
// //     );
// //   }

// //   Widget _buildErrorView(String error) {
// //     return Center(
// //       child: Padding(
// //         padding: const EdgeInsets.all(24),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             const Icon(Icons.error_outline, color: Colors.red, size: 64),
// //             const SizedBox(height: 16),
// //             Text(
// //               error,
// //               textAlign: TextAlign.center,
// //               style: const TextStyle(color: Color(0xFFF8F5F0)),
// //             ),
// //             const SizedBox(height: 16),
// //             ElevatedButton(
// //               onPressed: () {
// //                 Provider.of<InventoryProvider>(
// //                   context,
// //                   listen: false,
// //                 ).initialize();
// //               },
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: const Color(0xFFD4AF37),
// //                 foregroundColor: Colors.black,
// //               ),
// //               child: const Text('إعادة المحاولة'),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildEmptyView() {
// //     return const Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(Icons.inventory_2_outlined, color: Color(0xFFA09582), size: 64),
// //           SizedBox(height: 16),
// //           Text(
// //             'لا توجد عناصر في المخزون',
// //             style: TextStyle(color: Color(0xFFA09582)),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/inventory_provider.dart';
// import '../providers/rfid_provider.dart';
// import '../widgets/inventory_card.dart';
// import '../models/inventory_item.dart';
// import 'package:uuid/uuid.dart';

// class InventoryPage extends StatefulWidget {
//   const InventoryPage({super.key});

//   @override
//   State<InventoryPage> createState() => _InventoryPageState();
// }

// class _InventoryPageState extends State<InventoryPage> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final inventoryProvider = Provider.of<InventoryProvider>(
//         context,
//         listen: false,
//       );
//       inventoryProvider.initialize();

//       // بدء القراءة التلقائية إذا كان القارئ متصلاً
//       final rfidProvider = Provider.of<RfidProvider>(context, listen: false);
//       if (rfidProvider.isConnected && !rfidProvider.isReading) {
//         rfidProvider.startReading();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D0B08),
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           _buildConnectionStatus(),
//           Consumer<InventoryProvider>(
//             builder: (context, provider, child) {
//               if (provider.isLoading) {
//                 return const Expanded(
//                   child: Center(
//                     child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
//                   ),
//                 );
//               }

//               if (provider.error != null) {
//                 return Expanded(child: _buildErrorView(provider.error!));
//               }

//               return Expanded(
//                 child: Column(
//                   children: [
//                     _buildStatusBar(provider),
//                     Expanded(
//                       child: provider.items.isEmpty
//                           ? _buildEmptyView()
//                           : _buildItemList(provider),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       floatingActionButton: _buildFloatingActionButton(),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       title: const Text('TRAC-GOLD RFID INVENTORY'),
//       backgroundColor: const Color(0xFF1A1510),
//       elevation: 0,
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.refresh),
//           onPressed: () {
//             Provider.of<InventoryProvider>(
//               context,
//               listen: false,
//             ).refreshItems();
//           },
//         ),
//         // ✅ زر إضافة يدوي في الـ AppBar
//         IconButton(
//           icon: const Icon(Icons.add_box, color: Color(0xFFD4AF37)),
//           onPressed: () {
//             _showAddItemDialog();
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildConnectionStatus() {
//     return Consumer<RfidProvider>(
//       builder: (context, provider, child) {
//         Color statusColor;
//         String statusText;
//         IconData statusIcon;

//         if (provider.isConnected) {
//           statusColor = Colors.green;
//           statusText = '✅ القارئ متصل';
//           statusIcon = Icons.usb;
//         } else if (provider.isAutoConnecting || provider.isConnecting) {
//           statusColor = Colors.orange;
//           statusText = '⏳ جاري الاتصال...';
//           statusIcon = Icons.hourglass_top;
//         } else {
//           statusColor = Colors.red;
//           statusText = '❌ القارئ غير متصل';
//           statusIcon = Icons.usb_off;
//         }

//         return Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           color: statusColor.withOpacity(0.1),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(statusIcon, color: statusColor, size: 16),
//               const SizedBox(width: 8),
//               Text(
//                 statusText,
//                 style: TextStyle(
//                   color: statusColor,
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               if (!provider.isConnected && !provider.isAutoConnecting) ...[
//                 const SizedBox(width: 16),
//                 GestureDetector(
//                   onTap: () {
//                     provider.retryAutoConnect();
//                   },
//                   child: const Text(
//                     'إعادة المحاولة',
//                     style: TextStyle(
//                       color: Color(0xFFD4AF37),
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildStatusBar(InventoryProvider provider) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       color: const Color(0xFF1A1510),
//       child: Row(
//         children: [
//           _buildStatusItem(
//             icon: Icons.inventory,
//             label: 'الإجمالي',
//             value: '${provider.totalItems}',
//           ),
//           _buildStatusItem(
//             icon: Icons.check_circle,
//             label: 'الموجود',
//             value: '${provider.presentItems}',
//             color: Colors.green,
//           ),
//           _buildStatusItem(
//             icon: Icons.warning,
//             label: 'المفقود',
//             value: '${provider.missingCount}',
//             color: provider.missingCount > 0 ? Colors.red : Colors.green,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusItem({
//     required IconData icon,
//     required String label,
//     required String value,
//     Color? color,
//   }) {
//     return Expanded(
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, color: const Color(0xFFD4AF37), size: 14),
//               const SizedBox(width: 4),
//               Text(
//                 label,
//                 style: const TextStyle(color: Color(0xFFA09582), fontSize: 11),
//               ),
//             ],
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               color: color ?? const Color(0xFFF8F5F0),
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildItemList(InventoryProvider provider) {
//     // ✅ عرض كل العناصر (الموجود والمفقود معاً)
//     // المفقود هيظهر باللون الأحمر
//     return ListView.builder(
//       padding: const EdgeInsets.only(bottom: 80),
//       itemCount: provider.items.length,
//       itemBuilder: (context, index) {
//         return InventoryCard(item: provider.items[index]);
//       },
//     );
//   }

//   Widget _buildEmptyView() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.inventory_2_outlined, color: Color(0xFFA09582), size: 64),
//           SizedBox(height: 16),
//           Text(
//             'لا توجد عناصر في المخزون\n اضغط زر + لإضافة عنصر',
//             textAlign: TextAlign.center,
//             style: TextStyle(color: Color(0xFFA09582)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorView(String error) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, color: Colors.red, size: 64),
//             const SizedBox(height: 16),
//             Text(
//               error,
//               textAlign: TextAlign.center,
//               style: const TextStyle(color: Color(0xFFF8F5F0)),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 Provider.of<InventoryProvider>(
//                   context,
//                   listen: false,
//                 ).initialize();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFD4AF37),
//                 foregroundColor: Colors.black,
//               ),
//               child: const Text('إعادة المحاولة'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ✅ زر الإضافة في أسفل الشاشة
//   Widget _buildFloatingActionButton() {
//     return FloatingActionButton(
//       onPressed: _showAddItemDialog,
//       backgroundColor: const Color(0xFFD4AF37),
//       foregroundColor: Colors.black,
//       child: const Icon(Icons.add, size: 32),
//     );
//   }

//   // ✅ نافذة إضافة عنصر يدوي
//   void _showAddItemDialog() {
//     final formKey = GlobalKey<FormState>();
//     final nameController = TextEditingController();
//     final epcController = TextEditingController();
//     final codeController = TextEditingController();
//     String selectedCategory = 'RING';

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF1A1510),
//         title: const Text(
//           'إضافة عنصر جديد',
//           style: TextStyle(color: Color(0xFFF8F5F0)),
//         ),
//         content: SingleChildScrollView(
//           child: Form(
//             key: formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // اسم العنصر
//                 TextFormField(
//                   controller: nameController,
//                   style: const TextStyle(color: Color(0xFFF8F5F0)),
//                   decoration: InputDecoration(
//                     labelText: 'اسم العنصر',
//                     labelStyle: const TextStyle(color: Color(0xFFA09582)),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Color(0x25FFFFFF)),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Color(0xFFD4AF37)),
//                     ),
//                     filled: true,
//                     fillColor: const Color(0xFF2A2520),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'الرجاء إدخال اسم العنصر';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 12),

//                 // EPC
//                 TextFormField(
//                   controller: epcController,
//                   style: const TextStyle(color: Color(0xFFF8F5F0)),
//                   decoration: InputDecoration(
//                     labelText: 'EPC (اختياري)',
//                     labelStyle: const TextStyle(color: Color(0xFFA09582)),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Color(0x25FFFFFF)),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Color(0xFFD4AF37)),
//                     ),
//                     filled: true,
//                     fillColor: const Color(0xFF2A2520),
//                   ),
//                 ),
//                 const SizedBox(height: 12),

//                 // الكود
//                 TextFormField(
//                   controller: codeController,
//                   style: const TextStyle(color: Color(0xFFF8F5F0)),
//                   decoration: InputDecoration(
//                     labelText: 'الكود (اختياري)',
//                     labelStyle: const TextStyle(color: Color(0xFFA09582)),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Color(0x25FFFFFF)),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Color(0xFFD4AF37)),
//                     ),
//                     filled: true,
//                     fillColor: const Color(0xFF2A2520),
//                   ),
//                 ),
//                 const SizedBox(height: 12),

//                 // الفئة
//                 DropdownButtonFormField<String>(
//                   value: selectedCategory,
//                   dropdownColor: const Color(0xFF1A1510),
//                   style: const TextStyle(color: Color(0xFFF8F5F0)),
//                   decoration: InputDecoration(
//                     labelText: 'الفئة',
//                     labelStyle: const TextStyle(color: Color(0xFFA09582)),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Color(0x25FFFFFF)),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Color(0xFFD4AF37)),
//                     ),
//                     filled: true,
//                     fillColor: const Color(0xFF2A2520),
//                   ),
//                   items: const [
//                     DropdownMenuItem(value: 'RING', child: Text('خاتم')),
//                     DropdownMenuItem(value: 'BRACELET', child: Text('سوار')),
//                     DropdownMenuItem(value: 'CHAIN', child: Text('سلسلة')),
//                     DropdownMenuItem(value: 'OTHER', child: Text('أخرى')),
//                   ],
//                   onChanged: (value) {
//                     if (value != null) {
//                       selectedCategory = value;
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text(
//               'إلغاء',
//               style: TextStyle(color: Color(0xFFA09582)),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (formKey.currentState?.validate() ?? false) {
//                 _addItem(
//                   name: nameController.text,
//                   epc: epcController.text.isNotEmpty
//                       ? epcController.text
//                       : 'EPC${DateTime.now().millisecondsSinceEpoch}',
//                   code: codeController.text.isNotEmpty
//                       ? codeController.text
//                       : 'C${DateTime.now().millisecondsSinceEpoch}',
//                   category: selectedCategory,
//                 );
//                 Navigator.pop(context);
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFD4AF37),
//               foregroundColor: Colors.black,
//             ),
//             child: const Text('إضافة'),
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ دالة إضافة العنصر
//   Future<void> _addItem({
//     required String name,
//     required String epc,
//     required String code,
//     required String category,
//   }) async {
//     final provider = Provider.of<InventoryProvider>(context, listen: false);

//     final newItem = InventoryItem(
//       id: const Uuid().v4(),
//       epc: epc,
//       name: name,
//       category: category,
//       code: code,
//       isPresent: true,
//       lastScanned: DateTime.now(),
//     );

//     try {
//       await provider.addItem(newItem);

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('✅ تم إضافة العنصر بنجاح'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('❌ فشل إضافة العنصر: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/inventory_provider.dart';
import '../providers/rfid_provider.dart';
import '../widgets/inventory_card.dart';
import '../models/inventory_item.dart';
import '../firestore_service.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  // 🔹 قائمة الـ EPCs المضافة يدوياً
  List<String> manualEpcs = [];

  // 🔹 بيانات كل قطعة من Firebase
  Map<String, Map<String, dynamic>> itemsData = {};

  // 🔹 حالة التحميل
  bool isLoading = false;
  String? msg;

  // 🔹 للتحقق من وجود القطعة في القائمة
  bool _isItemExists(String epc) {
    return manualEpcs.contains(epc);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final inventoryProvider = Provider.of<InventoryProvider>(
        context,
        listen: false,
      );
      inventoryProvider.initialize();

      // بدء القراءة التلقائية إذا كان القارئ متصلاً
      final rfidProvider = Provider.of<RfidProvider>(context, listen: false);
      if (rfidProvider.isConnected && !rfidProvider.isReading) {
        rfidProvider.startReading();
      }
    });
  }

  // ===================== دوال جلب البيانات من Firebase =====================

  /// 🔹 جلب بيانات قطعة من Firebase باستخدام EPC
  Future<void> _loadItemData(String epc) async {
    try {
      setState(() {
        isLoading = true;
        itemsData[epc] = {'loading': true};
        msg = null;
      });

      print('🔍 جاري البحث عن EPC: $epc');

      final data = await FS.findItemByEpc(epc);

      setState(() {
        isLoading = false;
        if (data != null) {
          itemsData[epc] = data;
          print('✅ تم جلب البيانات بنجاح');
          msg = '✅ تم جلب البيانات';
        } else {
          itemsData[epc] = {
            'error': 'القطعة غير موجودة في قاعدة البيانات',
            'epc': epc,
          };
          print('❌ القطعة غير موجودة: $epc');
          msg = '❌ القطعة غير موجودة';
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        itemsData[epc] = {
          'error': 'خطأ في الاتصال: ${e.toString()}',
          'epc': epc,
        };
        msg = '❌ خطأ في الاتصال';
      });
      print('❌ خطأ في _loadItemData: $e');
    }
  }

  /// 🔹 جلب الصورة الأولى من Firebase Storage
  Future<String?> _getFirstImage(String epcHex) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('images')
          .child('users')
          .child(user.uid)
          .child(epcHex.toUpperCase());

      final result = await storageRef.listAll();

      if (result.items.isNotEmpty) {
        return await result.items.first.getDownloadURL();
      }
      return null;
    } catch (e) {
      print('❌ خطأ في جلب الصورة: $e');
      return null;
    }
  }

  /// 🔹 إضافة EPC يدوياً
  void _addEpcManually(String epc) {
    if (epc.isEmpty) {
      _showMessage('الرجاء إدخال رقم الشريحة', Colors.orange);
      return;
    }

    if (_isItemExists(epc)) {
      _showMessage('القطعة موجودة بالفعل', Colors.orange);
      return;
    }

    setState(() {
      manualEpcs.add(epc);
      itemsData[epc] = {'loading': true};
    });

    _loadItemData(epc);
  }

  /// 🔹 حذف قطعة من القائمة
  void _removeItem(String epc) {
    setState(() {
      manualEpcs.remove(epc);
      itemsData.remove(epc);
    });
    _showMessage('تم الحذف', Colors.green);
  }

  /// 🔹 عرض رسالة
  void _showMessage(String text, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ===================== واجهة المستخدم =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0B08),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildConnectionStatus(),
          Consumer<InventoryProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                  ),
                );
              }

              if (provider.error != null) {
                return Expanded(child: _buildErrorView(provider.error!));
              }

              return Expanded(
                child: Column(
                  children: [
                    _buildStatusBar(provider),
                    // 🔹 عرض القطع من Firebase + القطع المضافة يدوياً
                    Expanded(
                      child: provider.items.isEmpty && manualEpcs.isEmpty
                          ? _buildEmptyView()
                          : _buildCombinedList(provider),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: const Color(0xFFD4AF37),
      //   onPressed: _showManualEpcDialog,
      //   child: const Icon(Icons.add, color: Colors.black),
      // ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('TRAC-GOLD RFID INVENTORY'),
      backgroundColor: const Color(0xFF1A1510),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            Provider.of<InventoryProvider>(
              context,
              listen: false,
            ).refreshItems();
          },
        ),
        // 🔹 زر إضافة يدوي في الـ AppBar
        // IconButton(
        //   icon: const Icon(Icons.add_box, color: Color(0xFFD4AF37)),
        //   onPressed: _showManualEpcDialog,
        // ),
      ],
    );
  }

  Widget _buildConnectionStatus() {
    return Consumer<RfidProvider>(
      builder: (context, provider, child) {
        Color statusColor;
        String statusText;
        IconData statusIcon;

        if (provider.isConnected) {
          statusColor = Colors.green;
          statusText = '✅ القارئ متصل';
          statusIcon = Icons.usb;
        } else if (provider.isAutoConnecting || provider.isConnecting) {
          statusColor = Colors.orange;
          statusText = '⏳ جاري الاتصال...';
          statusIcon = Icons.hourglass_top;
        } else {
          statusColor = Colors.red;
          statusText = '❌ القارئ غير متصل';
          statusIcon = Icons.usb_off;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: statusColor.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(statusIcon, color: statusColor, size: 16),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (!provider.isConnected && !provider.isAutoConnecting) ...[
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    provider.retryAutoConnect();
                  },
                  child: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBar(InventoryProvider provider) {
    // 🔹 المجموع الكلي = القطع من Firebase + القطع المضافة يدوياً
    final totalItems = provider.totalItems + manualEpcs.length;
    final presentItems = provider.presentItems + manualEpcs.length;
    final missingCount = totalItems - presentItems;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF1A1510),
      child: Row(
        children: [
          _buildStatusItem(
            icon: Icons.inventory,
            label: 'الإجمالي',
            value: '$totalItems',
          ),
          _buildStatusItem(
            icon: Icons.check_circle,
            label: 'الموجود',
            value: '$presentItems',
            color: Colors.green,
          ),
          _buildStatusItem(
            icon: Icons.warning,
            label: 'المفقود',
            value: '$missingCount',
            color: missingCount > 0 ? Colors.red : Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFFD4AF37), size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(color: Color(0xFFA09582), fontSize: 11),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? const Color(0xFFF8F5F0),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 عرض القائمة المدمجة (من Firebase + يدوي)
  Widget _buildCombinedList(InventoryProvider provider) {
    // 🔹 قائمة القطع من Firebase
    final firebaseItems = provider.items.map((item) {
      return _buildFirebaseItemCard(item);
    }).toList();

    // 🔹 قائمة القطع المضافة يدوياً
    final manualItems = manualEpcs.map((epc) {
      return _buildManualItemCard(epc);
    }).toList();

    // 🔹 دمج القائمتين
    final allItems = [...firebaseItems, ...manualItems];

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: allItems,
    );
  }

  /// 🔹 بطاقة القطعة من Firebase (InventoryCard)
  Widget _buildFirebaseItemCard(InventoryItem item) {
    return InventoryCard(item: item);
  }

  /// 🔹 بطاقة القطعة المضافة يدوياً
  Widget _buildManualItemCard(String epc) {
    final itemData = itemsData[epc];

    // 🔹 إذا كان جاري التحميل
    if (itemData == null || itemData['loading'] == true) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: const Color(0xFF1A1510),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0x25FFFFFF)),
        ),
        child: const SizedBox(
          height: 80,
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFD4AF37),
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    // 🔹 إذا كان هناك خطأ
    if (itemData['error'] != null) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: Colors.red.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.red, width: 2),
        ),
        child: ListTile(
          leading: const Icon(Icons.error_outline, color: Colors.red),
          title: Text(
            'خطأ في جلب البيانات',
            style: const TextStyle(color: Colors.red),
          ),
          subtitle: Text(
            itemData['error'] ?? 'EPC: $epc',
            style: const TextStyle(color: Colors.red),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => _removeItem(epc),
          ),
        ),
      );
    }

    // 🔹 عرض البيانات
    final payload = itemData['payload'] ?? {};
    final epcHex = itemData['epcHex']?.toString() ?? epc;
    final name = payload['name'] ?? payload['kind'] ?? 'قطعة جديدة';
    final category = payload['kind'] ?? payload['type'] ?? 'OTHER';
    final code = payload['code'] ?? '';

    // 🔹 إنشاء InventoryItem مؤقت للعرض
    final tempItem = InventoryItem(
      id: epc,
      epc: epcHex,
      name: name,
      category: category.toUpperCase(),
      code: code,
      isPresent: true,
      lastScanned: DateTime.now(),
      metadata: payload,
    );

    return InventoryCard(item: tempItem);
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, color: Color(0xFFA09582), size: 64),
          SizedBox(height: 16),
          // Text(
          //   'لا توجد عناصر في المخزون\n اضغط زر + لإضافة عنصر',
          //   textAlign: TextAlign.center,
          //   style: TextStyle(color: Color(0xFFA09582)),
          // ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFF8F5F0)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Provider.of<InventoryProvider>(
                  context,
                  listen: false,
                ).initialize();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== حوار الإضافة اليدوية =====================

  void _showManualEpcDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1510),
        title: const Text(
          'إضافة قطعة يدوياً',
          style: TextStyle(color: Color(0xFFF8F5F0)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أدخل رقم الشريحة (EPC)',
              style: TextStyle(color: Color(0xFFA09582)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              style: const TextStyle(color: Color(0xFFF8F5F0)),
              decoration: InputDecoration(
                hintText: 'مثال: E2001234567890',
                hintStyle: const TextStyle(color: Color(0xFFA09582)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0x25FFFFFF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                ),
                filled: true,
                fillColor: const Color(0xFF2A2520),
                prefixIcon: const Icon(Icons.qr_code, color: Color(0xFFD4AF37)),
              ),
              textCapitalization: TextCapitalization.characters,
              onSubmitted: (value) {
                Navigator.pop(ctx);
                if (value.trim().isNotEmpty) {
                  _addEpcManually(value.trim());
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: Color(0xFFA09582)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final epc = controller.text.trim();
              Navigator.pop(ctx);
              if (epc.isNotEmpty) {
                _addEpcManually(epc);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
