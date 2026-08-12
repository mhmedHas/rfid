import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../rfid_service.dart';

class RfidInventoryPage extends StatefulWidget {
  const RfidInventoryPage({super.key});

  @override
  State<RfidInventoryPage> createState() => _RfidInventoryPageState();
}

class _RfidInventoryPageState extends State<RfidInventoryPage> {
  final Map<String, Map<String, dynamic>> _items = {};
  final Map<String, DateTime> _lastSeen = {};
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;
  Timer? _presenceTimer;
  bool _connected = false;
  bool _connecting = false;
  String? _error;
  DateTime? _lastUpdate;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _subscription = RfidService.tagStream.listen(_onTags, onError: (e) {
      if (mounted) setState(() => _error = 'خطأ في قراءة RFID: $e');
    });
    _presenceTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted && _connected) setState(() {});
    });
  }

  Future<void> _loadItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('items')
          .get();

      final loaded = <String, Map<String, dynamic>>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final payload = data['payload'] is Map
            ? Map<String, dynamic>.from(data['payload'])
            : <String, dynamic>{};
        final epc = _first([
          data['epcHex'], data['epc'], payload['epcHex'],
          payload['epc'], payload['qrCode'],
        ]);
        if (epc.isEmpty) continue;
        loaded[epc.toUpperCase()] = {
          'id': doc.id,
          'epc': epc.toUpperCase(),
          'name': _first([data['name'], payload['name'], payload['kind'], payload['type']], fallback: 'قطعة ذهب'),
          'type': _first([data['type'], payload['type'], payload['kind']], fallback: 'ذهب'),
          'weight': _first([data['weight'], payload['weight']], fallback: '-'),
          'color': _first([data['color'], payload['color']], fallback: 'ذهبي'),
          'image': _first([data['imageUrl'], data['image'], data['photoUrl'], payload['imageUrl'], payload['image'], payload['photoUrl']]),
        };
      }
      if (!mounted) return;
      setState(() { _items..clear()..addAll(loaded); _error = null; });
    } catch (e) {
      if (mounted) setState(() => _error = 'تعذر تحميل قطع الحساب: $e');
    }
  }

  String _first(List<dynamic> values, {String fallback = ''}) {
    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return fallback;
  }

  void _onTags(List<Map<String, dynamic>> tags) {
    final now = DateTime.now();
    var changed = false;
    for (final tag in tags) {
      final epc = tag['epc']?.toString().trim().toUpperCase() ?? '';
      if (epc.isEmpty || !_items.containsKey(epc)) continue;
      _lastSeen[epc] = now;
      changed = true;
    }
    if (changed && mounted) setState(() => _lastUpdate = now);
  }

  bool _present(String epc) {
    final seen = _lastSeen[epc];
    if (!_connected || seen == null) return false;
    return seen.isAfter(DateTime.now().subtract(const Duration(milliseconds: 1600)));
  }

  Future<void> _toggleConnection() async {
    if (_connecting) return;
    if (_connected) {
      try { await RfidService.stopReading(); } catch (_) {}
      try { await RfidService.disconnect(); } catch (_) {}
      if (mounted) setState(() => _connected = false);
      return;
    }

    setState(() { _connecting = true; _error = null; });
    try {
      final connected = await RfidService.connectUSB();
      if (!connected) throw Exception('لم يتم العثور على قارئ RFID عبر USB-C');
      final started = await RfidService.startReading();
      if (!started) throw Exception('تم الاتصال لكن فشل بدء القراءة');
      if (mounted) setState(() { _connected = true; _connecting = false; });
    } catch (e) {
      try { await RfidService.disconnect(); } catch (_) {}
      if (mounted) setState(() { _connecting = false; _connected = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  Future<void> _logout() async {
    try { await RfidService.stopReading(); } catch (_) {}
    try { await RfidService.disconnect(); } catch (_) {}
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _presenceTimer?.cancel();
    RfidService.stopReading();
    RfidService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = _items.values.toList();
    final present = entries.where((e) => _present(e['epc'] as String)).length;
    final missing = entries.length - present;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5F4),
        body: SafeArea(
          child: Column(
            children: [
              _header(),
              _summary(entries.length, present, missing),
              if (_error != null) _errorBar(),
              Expanded(
                child: entries.isEmpty
                    ? const Center(child: Text('لا توجد قطع مسجلة لهذا الحساب', style: TextStyle(color: Colors.grey, fontSize: 16)))
                    : GridView.builder(
                        padding: const EdgeInsets.all(18),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 310,
                          mainAxisExtent: 300,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: entries.length,
                        itemBuilder: (_, i) => _card(entries[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final status = _connected ? const Color(0xFF22A35A) : const Color(0xFF777777);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      color: const Color(0xFF202522),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(color: status.withOpacity(.16), borderRadius: BorderRadius.circular(20)),
          child: Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: status, shape: BoxShape.circle)), const SizedBox(width: 7), Text(_connected ? 'متصل' : 'غير متصل', style: TextStyle(color: status, fontWeight: FontWeight.bold))]),
        ),
        const Spacer(),
        const Text('TRAC-GOLD RFID', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const Spacer(),
        TextButton.icon(
          onPressed: _toggleConnection,
          icon: Icon(_connected ? Icons.usb_off : Icons.usb, color: Colors.white),
          label: Text(_connecting ? 'جاري الاتصال...' : (_connected ? 'فصل الجهاز' : 'اتصال بالجهاز'), style: const TextStyle(color: Colors.white)),
          style: TextButton.styleFrom(backgroundColor: _connected ? const Color(0xFFB83C3C) : const Color(0xFF238B50), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))),
        ),
        IconButton(onPressed: _logout, icon: const Icon(Icons.logout, color: Colors.white70)),
      ]),
    );
  }

  Widget _summary(int total, int present, int missing) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
      child: Row(children: [
        _stat('إجمالي القطع', total.toString(), const Color(0xFF263238)),
        _stat('الموجودة', present.toString(), const Color(0xFF159447)),
        _stat('المرفوعة', missing.toString(), missing > 0 ? const Color(0xFFC73737) : const Color(0xFF159447)),
        const Spacer(),
        if (_lastUpdate != null) Text('آخر قراءة ${_lastUpdate!.hour.toString().padLeft(2, '0')}:${_lastUpdate!.minute.toString().padLeft(2, '0')}:${_lastUpdate!.second.toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ]),
    );
  }

  Widget _stat(String label, String value, Color color) => Expanded(child: Column(children: [Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 4), Text(value, style: TextStyle(color: color, fontSize: 25, fontWeight: FontWeight.w800))]));

  Widget _card(Map<String, dynamic> item) {
    final epc = item['epc'] as String;
    final present = _present(epc);
    final color = present ? const Color(0xFF1D9A4D) : const Color(0xFFC93B3B);
    final image = item['image'] as String? ?? '';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: color, width: 2), boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 4))]),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(child: Stack(children: [
          Container(color: const Color(0xFFF5F5F3), width: double.infinity, child: image.isEmpty ? const Icon(Icons.diamond, size: 75, color: Color(0xFFB7B7B0)) : Image.network(image, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, size: 55, color: Colors.grey))),
          Positioned(top: 10, right: 10, child: Container(width: 29, height: 29, decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: Icon(present ? Icons.check : Icons.close, color: Colors.white, size: 18))),
        ])),
        Padding(padding: const EdgeInsets.fromLTRB(13, 10, 13, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item['name'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 5),
          Row(children: [Text('${item['type']}  •  ${item['weight']} جم', style: const TextStyle(color: Color(0xFF666666), fontSize: 12)), const Spacer(), Text(item['color'] as String, style: const TextStyle(color: Color(0xFF8A6A15), fontWeight: FontWeight.w600, fontSize: 12))]),
          const SizedBox(height: 5),
          Text(epc, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF999999), fontSize: 9, fontFamily: 'monospace')),
        ])),
      ]),
    );
  }

  Widget _errorBar() => Container(width: double.infinity, color: const Color(0xFFFFE6E6), padding: const EdgeInsets.all(10), child: Row(children: [const Icon(Icons.error_outline, color: Color(0xFFC73737)), const SizedBox(width: 8), Expanded(child: Text(_error!, style: const TextStyle(color: Color(0xFFC73737)))), IconButton(onPressed: () => setState(() => _error = null), icon: const Icon(Icons.close, size: 18, color: Color(0xFFC73737)))]));
}
