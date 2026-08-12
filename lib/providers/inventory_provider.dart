import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_item.dart';
import '../services/firebase_service.dart';
import '../services/rfid_service.dart';

class InventoryProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final RfidService _rfidService = RfidService();

  List<InventoryItem> _items = [];
  List<InventoryItem> _missingItems = [];
  bool _isLoading = false;
  bool _isScanning = false;
  String? _error;
  int _totalItems = 0;
  int _presentItems = 0;
  String? _selectedCategory;

  // Getters
  List<InventoryItem> get items => _items;
  List<InventoryItem> get missingItems => _missingItems;
  bool get isLoading => _isLoading;
  bool get isScanning => _isScanning;
  String? get error => _error;
  int get totalItems => _totalItems;
  int get presentItems => _presentItems;
  int get missingCount => _totalItems - _presentItems;
  String? get selectedCategory => _selectedCategory;

  List<String> get categories {
    final cats = _items.map((item) => item.category).toSet().toList();
    return cats;
  }

  List<InventoryItem> get filteredItems {
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      return _items;
    }
    return _items.where((item) => item.category == _selectedCategory).toList();
  }

  // ============ تهيئة ============

  Future<void> initialize() async {
    _setLoading(true);
    _clearError();

    try {
      await _loadItemsFromFirebase();
      _listenToRfidTags();
    } catch (e) {
      _setError('فشل التهيئة: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ============ Firebase ============

  Future<void> _loadItemsFromFirebase() async {
    try {
      _items = await _firebaseService.getAllItems();
      _updateCounts();
      notifyListeners();
    } catch (e) {
      _setError('فشل تحميل البيانات: $e');
      rethrow;
    }
  }

  Future<void> refreshItems() async {
    await _loadItemsFromFirebase();
  }

  // ============ RFID ============

  void _listenToRfidTags() {
    RfidService.tagStream.listen(_handleRfidTags);
  }

  void _handleRfidTags(List<dynamic> tags) {
    for (var tag in tags) {
      final epc = tag['epc']?.toString();
      final rssi = tag['rssi']?.toString();

      if (epc != null && epc.isNotEmpty) {
        _updateItemStatus(epc, rssi);
      }
    }
  }

  void _updateItemStatus(String epc, String? rssi) {
    final index = _items.indexWhere((item) => item.epc == epc);

    if (index != -1) {
      final oldItem = _items[index];

      if (!oldItem.isPresent) {
        // العنصر موجود الآن - تغيير اللون للأخضر
        _items[index] = oldItem.copyWith(
          isPresent: true,
          lastScanned: DateTime.now(),
          rssi: rssi,
        );
        _updateCounts();
        notifyListeners();

        // تحديث في Firebase
        _firebaseService.updateItemStatus(_items[index].id, true);
      }
    }
  }

  // ============ تحديث الحالة ============

  void _updateCounts() {
    _totalItems = _items.length;
    _presentItems = _items.where((item) => item.isPresent).length;
    _missingItems = _items.where((item) => !item.isPresent).toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // ============ عمليات المخزون ============

  Future<void> resetInventory() async {
    _setLoading(true);

    try {
      for (var item in _items) {
        if (!item.isPresent) {
          final updated = item.copyWith(isPresent: true);
          await _firebaseService.updateItemStatus(item.id, true);

          final index = _items.indexOf(item);
          if (index != -1) {
            _items[index] = updated;
          }
        }
      }

      _updateCounts();
      notifyListeners();
    } catch (e) {
      _setError('فشل إعادة التعيين: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addItem(InventoryItem item) async {
    try {
      await _firebaseService.addItem(item);
      _items.add(item);
      _updateCounts();
      notifyListeners();
    } catch (e) {
      _setError('فشل إضافة العنصر: $e');
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _firebaseService.deleteItem(id);
      _items.removeWhere((item) => item.id == id);
      _updateCounts();
      notifyListeners();
    } catch (e) {
      _setError('فشل حذف العنصر: $e');
      rethrow;
    }
  }

  Future<void> updateItem(InventoryItem item) async {
    try {
      await _firebaseService.updateItem(item);
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = item;
        _updateCounts();
        notifyListeners();
      }
    } catch (e) {
      _setError('فشل تحديث العنصر: $e');
      rethrow;
    }
  }

  List<InventoryItem> searchItems(String query) {
    if (query.isEmpty) return _items;

    return _items
        .where(
          (item) =>
              item.name.toLowerCase().contains(query.toLowerCase()) ||
              item.epc.toLowerCase().contains(query.toLowerCase()) ||
              item.code.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
