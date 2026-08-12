import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_item.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'inventory';

  // ============ قراءة البيانات ============

  Future<List<InventoryItem>> getAllItems() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) {
        return InventoryItem.fromFirebase(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('❌ Error getting items: $e');
      rethrow;
    }
  }

  Future<InventoryItem?> getItem(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return InventoryItem.fromFirebase(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('❌ Error getting item: $e');
      rethrow;
    }
  }

  Future<List<InventoryItem>> getItemsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .get();

      return snapshot.docs.map((doc) {
        return InventoryItem.fromFirebase(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('❌ Error getting items by category: $e');
      rethrow;
    }
  }

  Future<List<InventoryItem>> getMissingItems() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isPresent', isEqualTo: false)
          .get();

      return snapshot.docs.map((doc) {
        return InventoryItem.fromFirebase(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('❌ Error getting missing items: $e');
      rethrow;
    }
  }

  // ============ كتابة البيانات ============

  Future<void> addItem(InventoryItem item) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(item.id)
          .set(item.toFirebase());
    } catch (e) {
      print('❌ Error adding item: $e');
      rethrow;
    }
  }

  Future<void> updateItem(InventoryItem item) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(item.id)
          .update(item.toFirebase());
    } catch (e) {
      print('❌ Error updating item: $e');
      rethrow;
    }
  }

  Future<void> updateItemStatus(String id, bool isPresent) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'isPresent': isPresent,
        'lastScanned': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Error updating item status: $e');
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      print('❌ Error deleting item: $e');
      rethrow;
    }
  }

  Future<void> addMultipleItems(List<InventoryItem> items) async {
    try {
      final batch = _firestore.batch();

      for (var item in items) {
        final docRef = _firestore.collection(_collection).doc(item.id);
        batch.set(docRef, item.toFirebase());
      }

      await batch.commit();
    } catch (e) {
      print('❌ Error adding multiple items: $e');
      rethrow;
    }
  }

  // ============ استماع للتغييرات ============

  Stream<List<InventoryItem>> listenToItems() {
    return _firestore.collection(_collection).orderBy('name').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return InventoryItem.fromFirebase(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<List<InventoryItem>> listenToMissingItems() {
    return _firestore
        .collection(_collection)
        .where('isPresent', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return InventoryItem.fromFirebase(doc.data(), doc.id);
          }).toList();
        });
  }
}
