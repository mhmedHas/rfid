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
  // All account items are loaded only as a local EPC -> metadata cache.
  // They are NEVER displayed until the RFID reader actually sees their EPC.
  final Map<String, Map<String, dynamic>> _catalog = {};

  // EPCs discovered during the current reader session. These are the only
  // items that can appear on the main screen.
  final Set<String> _sessionEpCs = <String>{};
  final Map<String, DateTime> _lastSeen = {};

  StreamSubscription<List<Map<String, dynamic>>>? _subscription;
  Timer? _presenceTimer;
  bool _connected = false;
  bool _connecting = false;
  String? _error;
  DateTime? _lastUpdate;

  static const _green = Color(0xFF1D9A4D);
  static const _red = Color(0xFFC93B3B);

  @override
  void initState() {
    super.initState();
    _loadCatalog();

    _subscription = RfidService.tagStream.listen(
      _onTags,
      onError: (e) {
        if (mounted) setState(() => _error = 'خطأ في قراءة RFID: $e');
      },
    );

    // Refresh presence state frequently so a removed item changes to red
    // without requiring another RFID event.
    _presenceTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted && _connected && _sessionEpCs.isNotEmpty) {
        setState(() {});
      }
    });
  }

  /// Loads the logged-in user's items as a lookup cache only.
  /// Nothing from this catalog is rendered until its EPC is read by RFID.
  Future<void> _loadCatalog() async {
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
          data['epcHex'],
          data['epc'],
          payload['epcHex'],
          payload['epc'],
          payload['qrCode'],
        ]);

        if (epc.isEmpty) continue;

        final normalizedEpc = epc.toUpperCase();
        loaded[normalizedEpc] = {
          'id': doc.id,
          'epc': normalizedEpc,
          'name': _first(
            [data['name'], payload['name'], payload['kind'], payload['type']],
            fallback: 'قطعة ذهب',
          ),
          'type': _first(
            [data['type'], payload['type'], payload['kind']],
            fallback: 'ذهب',
          ),
          'weight': _first(
            [data['weight'], payload['weight']],
            fallback: '-',
          ),
          'color': _first(
            [data['color'], payload['color']],
            fallback: 'ذهبي',
          ),
          'image': _first([
            data['imageUrl'],
            data['image'],
            data['photoUrl'],
            payload['imageUrl'],
            payload['image'],
            payload['photoUrl'],
          ]),
        };
      }

      if (!mounted) return;
      setState(() {
        _catalog
          ..clear()
          ..addAll(loaded);
        _error = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'تعذر تحميل بيانات قطع الحساب: $e');
      }
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
      if (epc.isEmpty) continue;

      // Unknown EPCs are ignored. Only pieces belonging to the logged-in
      // Firebase account can appear on the screen.
      if (!_catalog.containsKey(epc)) continue;

      // First time we see an EPC in this session, it becomes visible.
      if (_sessionEpCs.add(epc)) changed = true;

      _lastSeen[epc] = now;
      changed = true;
    }

    if (changed && mounted) {
      setState(() => _lastUpdate = now);
    }
  }

  bool _present(String epc) {
    final seen = _lastSeen[epc];
    if (!_connected || seen == null) return false;

    // Require the tag to be absent from the reader for a short period before
    // turning it red. This prevents a single missed RFID read from causing a
    // false removal.
    return seen.isAfter(
      DateTime.now().subtract(const Duration(milliseconds: 1600)),
    );
  }

  Future<void> _toggleConnection() async {
    if (_connecting) return;

    if (_connected) {
      try {
        await RfidService.stopReading();
      } catch (_) {}
      try {
        await RfidService.disconnect();
      } catch (_) {}

      if (mounted) {
        setState(() {
          _connected = false;
          // A new connection starts a fresh physical inventory session.
          _sessionEpCs.clear();
          _lastSeen.clear();
          _lastUpdate = null;
        });
      }
      return;
    }

    setState(() {
      _connecting = true;
      _error = null;
      // Do not show stale pieces from a previous session.
      _sessionEpCs.clear();
      _lastSeen.clear();
      _lastUpdate = null;
    });

    try {
      final connected = await RfidService.connectUSB();
      if (!connected) {
        throw Exception('لم يتم العثور على قارئ RFID عبر USB-C');
      }

      final started = await RfidService.startReading();
      if (!started) {
        throw Exception('تم الاتصال لكن فشل بدء القراءة');
      }

      if (mounted) {
        setState(() {
          _connected = true;
          _connecting = false;
        });
      }
    } catch (e) {
      try {
        await RfidService.disconnect();
      } catch (_) {}

      if (mounted) {
        setState(() {
          _connecting = false;
          _connected = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      await RfidService.stopReading();
    } catch (_) {}
    try {
      await RfidService.disconnect();
    } catch (_) {}
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
    final entries = _sessionEpCs
        .map((epc) => _catalog[epc])
        .whereType<Map<String, dynamic>>()
        .toList();

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
              Expanded(child: _responsiveGrid(entries)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _responsiveGrid(List<Map<String, dynamic>> entries) {
    if (!_connected && entries.isEmpty) {
      return _emptyState(
        Icons.usb,
        'اضغط «اتصال بالجهاز» لبدء قراءة القطع',
      );
    }

    if (_connected && entries.isEmpty) {
      return _emptyState(
        Icons.radar,
        'ضع القطع فوق القارئ وانتظر القراءة...',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontalPadding = width < 600 ? 12.0 : 20.0;
        final spacing = width < 600 ? 10.0 : 14.0;

        // Responsive: phone 2 columns, tablet 3, large tablet/desktop 4+.
        final columns = width < 420
            ? 1
            : width < 700
                ? 2
                : width < 1050
                    ? 3
                    : 4;

        return GridView.builder(
          padding: EdgeInsets.all(horizontalPadding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            // Card height adapts to the available width so it remains usable
            // from small phones through tablets.
            childAspectRatio: width < 420 ? 1.05 : 0.86,
          ),
          itemCount: entries.length,
          itemBuilder: (_, i) => _card(entries[i]),
        );
      },
    );
  }

  Widget _emptyState(IconData icon, String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 58, color: const Color(0xFF9AA19D)),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF68716C),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    final status = _connected ? _green : const Color(0xFF777777);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      color: const Color(0xFF202522),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 600;

          final statusWidget = Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: status.withOpacity(.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: status,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  _connected ? 'متصل' : 'غير متصل',
                  style: TextStyle(color: status, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );

          final connectButton = TextButton.icon(
            onPressed: _toggleConnection,
            icon: Icon(
              _connected ? Icons.usb_off : Icons.usb,
              color: Colors.white,
              size: 19,
            ),
            label: Text(
              _connecting
                  ? 'جاري الاتصال...'
                  : (_connected ? 'فصل الجهاز' : 'اتصال بالجهاز'),
              style: const TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
              backgroundColor:
                  _connected ? const Color(0xFFB83C3C) : const Color(0xFF238B50),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          );

          final title = const Text(
            'TRAC-GOLD RFID',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          );

          if (compact) {
            return Column(
              children: [
                Row(
                  children: [
                    statusWidget,
                    const Spacer(),
                    IconButton(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: title),
                    const SizedBox(width: 8),
                    connectButton,
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              statusWidget,
              const Spacer(),
              title,
              const Spacer(),
              connectButton,
              IconButton(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.white70),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summary(int total, int present, int missing) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 520;

          final stats = [
            _stat('على القارئ', total.toString(), const Color(0xFF263238)),
            _stat('موجودة', present.toString(), _green),
            _stat(
              'مرفوعة',
              missing.toString(),
              missing > 0 ? _red : _green,
            ),
          ];

          if (compact) {
            return Row(children: stats);
          }

          return Row(
            children: [
              ...stats,
              const Spacer(),
              if (_lastUpdate != null)
                Text(
                  'آخر قراءة ${_lastUpdate!.hour.toString().padLeft(2, '0')}:${_lastUpdate!.minute.toString().padLeft(2, '0')}:${_lastUpdate!.second.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Map<String, dynamic> item) {
    final epc = item['epc'] as String;
    final present = _present(epc);
    final color = present ? _green : _red;
    final image = item['image'] as String? ?? '';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  color: const Color(0xFFF5F5F3),
                  width: double.infinity,
                  child: image.isEmpty
                      ? const Icon(
                          Icons.diamond,
                          size: 65,
                          color: Color(0xFFB7B7B0),
                        )
                      : Image.network(
                          image,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image_outlined,
                            size: 55,
                            color: Colors.grey,
                          ),
                        ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      present ? Icons.check : Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item['type']} • ${item['weight']} جم',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        item['color'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF8A6A15),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  epc,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 8,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBar() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFE6E6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: _red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(color: _red, fontSize: 12),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _error = null),
            icon: const Icon(Icons.close, size: 18, color: _red),
          ),
        ],
      ),
    );
  }
}
