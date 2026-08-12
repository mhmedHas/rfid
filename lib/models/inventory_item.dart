class InventoryItem {
  final String id;
  final String epc;
  final String name;
  final String category;
  final String code;
  final double price;
  final bool isPresent;
  final DateTime? lastScanned;
  final String? rssi;
  final Map<String, dynamic> metadata;

  InventoryItem({
    required this.id,
    required this.epc,
    required this.name,
    required this.category,
    required this.code,
    this.price = 0.0,
    this.isPresent = true,
    this.lastScanned,
    this.rssi,
    this.metadata = const {},
  });

  factory InventoryItem.fromFirebase(Map<String, dynamic> data, String id) {
    return InventoryItem(
      id: id,
      epc: data['epc'] ?? '',
      name: data['name'] ?? 'Unknown Item',
      category: data['category'] ?? 'OTHER',
      code: data['code'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      isPresent: data['isPresent'] ?? true,
      lastScanned: data['lastScanned']?.toDate(),
      rssi: data['rssi'],
      metadata: data['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      'epc': epc,
      'name': name,
      'category': category,
      'code': code,
      'price': price,
      'isPresent': isPresent,
      'lastScanned': lastScanned?.toIso8601String(),
      'rssi': rssi,
      'metadata': metadata,
    };
  }

  InventoryItem copyWith({
    String? id,
    String? epc,
    String? name,
    String? category,
    String? code,
    double? price,
    bool? isPresent,
    DateTime? lastScanned,
    String? rssi,
    Map<String, dynamic>? metadata,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      epc: epc ?? this.epc,
      name: name ?? this.name,
      category: category ?? this.category,
      code: code ?? this.code,
      price: price ?? this.price,
      isPresent: isPresent ?? this.isPresent,
      lastScanned: lastScanned ?? this.lastScanned,
      rssi: rssi ?? this.rssi,
      metadata: metadata ?? this.metadata,
    );
  }
}
