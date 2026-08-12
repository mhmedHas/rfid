// import 'package:flutter/material.dart';
// import '../models/inventory_item.dart';

// class InventoryCard extends StatelessWidget {
//   final InventoryItem item;

//   const InventoryCard({super.key, required this.item});

//   @override
//   Widget build(BuildContext context) {
//     final isPresent = item.isPresent;

//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       color: isPresent ? const Color(0xFF1A1510) : Colors.red.withOpacity(0.15),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(
//           color: isPresent ? Colors.transparent : Colors.red,
//           width: 2,
//         ),
//       ),
//       child: ListTile(
//         leading: _buildIcon(),
//         title: Text(
//           item.name,
//           style: TextStyle(
//             color: isPresent ? const Color(0xFFF8F5F0) : Colors.red,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         subtitle: Text(
//           'EPC: ${item.epc} | ${item.category}',
//           style: TextStyle(
//             color: isPresent ? const Color(0xFFA09582) : Colors.red[300],
//             fontSize: 12,
//           ),
//         ),
//         trailing: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//               decoration: BoxDecoration(
//                 color: isPresent ? Colors.green : Colors.red,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 isPresent ? 'موجود' : 'مفقود',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 10,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             if (item.rssi != null)
//               Text(
//                 'RSSI: ${item.rssi} dBm',
//                 style: TextStyle(color: const Color(0xFFA09582), fontSize: 10),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildIcon() {
//     IconData icon;
//     final isPresent = item.isPresent;
//     final color = isPresent ? const Color(0xFFD4AF37) : Colors.red;

//     switch (item.category.toLowerCase()) {
//       case 'ring':
//         icon = Icons.circle;
//         break;
//       case 'bracelet':
//         icon = Icons.fitness_center;
//         break;
//       case 'chain':
//         icon = Icons.link;
//         break;
//       default:
//         icon = Icons.inventory_2;
//     }

//     return Container(
//       width: 40,
//       height: 40,
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Icon(icon, color: color),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/inventory_item.dart';

class InventoryCard extends StatelessWidget {
  final InventoryItem item;

  const InventoryCard({super.key, required this.item});

  /// 🔹 جلب الصورة من Firebase Storage
  Future<String?> _getImage(String epcHex) async {
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
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPresent = item.isPresent;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: isPresent ? const Color(0xFF1A1510) : Colors.red.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isPresent ? Colors.transparent : Colors.red,
          width: 2,
        ),
      ),
      child: FutureBuilder<String?>(
        future: _getImage(item.epc),
        builder: (context, snapshot) {
          final imageUrl = snapshot.data;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔹 الصورة (يسار)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[800],
                  ),
                  child: snapshot.connectionState == ConnectionState.waiting
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFD4AF37),
                            strokeWidth: 2,
                          ),
                        )
                      : imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFD4AF37),
                                  strokeWidth: 2,
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 30,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'لا توجد صورة',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(width: 16),

                // 🔹 البيانات (نص)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 🔹 اسم القطعة
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isPresent
                              ? const Color(0xFFF8F5F0)
                              : Colors.red,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // 🔹 النوع + الوزن في سطر واحد
                      Row(
                        children: [
                          // 🔹 النوع
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isPresent
                                  ? Colors.grey[800]
                                  : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getCategoryLabel(item.category),
                              style: TextStyle(
                                fontSize: 12,
                                color: isPresent
                                    ? const Color(0xFFA09582)
                                    : Colors.red[300],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // 🔹 الوزن
                          if (item.metadata['weight'] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFD4AF37,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(
                                    0xFFD4AF37,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                '${item.metadata['weight']} جم',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFD4AF37),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // 🔹 حالة القطعة (موجود/مفقود)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isPresent ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isPresent ? 'موجود ✅' : 'مفقود ❌',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 🔹 ترجمة الفئة إلى العربية
  String _getCategoryLabel(String category) {
    switch (category.toLowerCase()) {
      case 'ring':
        return 'خاتم';
      case 'bracelet':
        return 'سوار';
      case 'chain':
        return 'سلسلة';
      case 'earring':
        return 'حلق';
      case 'necklace':
        return 'قلادة';
      default:
        return category;
    }
  }
}
