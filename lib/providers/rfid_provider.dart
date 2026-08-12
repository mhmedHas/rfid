import 'package:alarm/services/connect.dart';
import 'package:flutter/material.dart';
import '../services/rfid_service.dart';

class RfidProvider extends ChangeNotifier {
  final RfidService _rfidService = RfidService();

  bool _isConnected = false;
  bool _isReading = false;
  bool _isConnecting = false;
  bool _isAutoConnecting = false;
  String? _error;
  String? _moduleInfo;
  String? _firmwareVersion;
  String? _temperature;
  List<Map<String, dynamic>> _scannedTags = [];
  UsbDevice? _connectedDevice;

  // Getters
  bool get isConnected => _isConnected;
  bool get isReading => _isReading;
  bool get isConnecting => _isConnecting;
  bool get isAutoConnecting => _isAutoConnecting;
  String? get error => _error;
  String? get moduleInfo => _moduleInfo;
  String? get firmwareVersion => _firmwareVersion;
  String? get temperature => _temperature;
  List<Map<String, dynamic>> get scannedTags => _scannedTags;
  UsbDevice? get connectedDevice => _connectedDevice;

  RfidProvider() {
    _init();
  }

  void _init() {
    // الاستماع للعلامات
    RfidService.tagStream.listen(_handleRfidTags);

    // بدء الاستماع لأحداث USB
    UsbService.startListening();
    UsbService.events.listen(_handleUsbEvent);

    // فحص الأجهزة المتصلة عند بدء التطبيق
    _checkConnectedDevices();
  }

  // ============ فحص الأجهزة المتصلة ============

  Future<void> _checkConnectedDevices() async {
    try {
      final devices = await UsbService.getConnectedDevices();

      // البحث عن قارئ RFID
      for (var device in devices) {
        if (device.isRfidReader) {
          _connectedDevice = device;

          // إذا كان لديه صلاحية، اتصل تلقائياً
          if (device.hasPermission) {
            await _autoConnectUsb();
          } else {
            // طلب صلاحية
            await UsbService.requestPermission(device.deviceId);
          }
          break;
        }
      }
    } catch (e) {
      print('⚠️ Error checking connected devices: $e');
    }
  }

  // ============ معالجة أحداث USB ============

  void _handleUsbEvent(UsbDeviceEvent event) {
    print('📱 USB Event: ${event.status}');

    switch (event.status) {
      case 'attached':
        // جهاز USB متصل
        _handleDeviceAttached(event);
        break;

      case 'detached':
        // جهاز USB مفصول
        _handleDeviceDetached(event);
        break;

      case 'connected':
        // جهاز متصل بالفعل
        _handleDeviceConnected(event);
        break;

      case 'permission_result':
        // نتيجة طلب الصلاحية
        if (event.granted == true) {
          _autoConnectUsb();
        } else {
          _setError('❌ تم رفض صلاحية الوصول للقارئ');
          _isAutoConnecting = false;
          notifyListeners();
        }
        break;
    }
  }

  void _handleDeviceAttached(UsbDeviceEvent event) {
    _isAutoConnecting = true;
    _clearError();
    notifyListeners();

    // محاولة الاتصال بالجهاز
    _connectedDevice = UsbDevice(
      deviceId: event.deviceId ?? 0,
      vendorId: event.vendorId ?? 0,
      productId: event.productId ?? 0,
      deviceName: event.deviceName ?? 'RFID Reader',
      manufacturer: '',
      product: '',
      serial: '',
      interfaceCount: 0,
      hasPermission: event.hasPermission,
    );

    if (event.hasPermission) {
      _autoConnectUsb();
    } else {
      // طلب صلاحية
      UsbService.requestPermission(event.deviceId ?? 0);
    }
  }

  void _handleDeviceDetached(UsbDeviceEvent event) {
    _disconnect();
    _connectedDevice = null;
    _setError('⚠️ تم فصل القارئ');
    notifyListeners();
  }

  void _handleDeviceConnected(UsbDeviceEvent event) {
    if (!_isConnected) {
      _connectedDevice = UsbDevice(
        deviceId: event.deviceId ?? 0,
        vendorId: event.vendorId ?? 0,
        productId: event.productId ?? 0,
        deviceName: event.deviceName ?? 'RFID Reader',
        manufacturer: '',
        product: '',
        serial: '',
        interfaceCount: 0,
        hasPermission: event.hasPermission,
      );

      if (event.hasPermission) {
        _autoConnectUsb();
      }
    }
  }

  // ============ الاتصال التلقائي عبر USB ============

  Future<void> _autoConnectUsb() async {
    if (_isConnected) return;

    _isAutoConnecting = true;
    _clearError();
    notifyListeners();

    try {
      final success = await RfidService.connectUSB();

      if (success) {
        _isConnected = true;
        _isAutoConnecting = false;
        _getDeviceInfo();
        notifyListeners();
        print('✅ تم الاتصال التلقائي بالقارئ عبر USB');
      } else {
        _isAutoConnecting = false;
        _setError('❌ فشل الاتصال التلقائي بالقارئ');
        notifyListeners();
      }
    } catch (e) {
      _isAutoConnecting = false;
      _setError('❌ خطأ في الاتصال التلقائي: $e');
      notifyListeners();
    }
  }

  // ============ دوال الاتصال اليدوي (احتياطي) ============

  Future<bool> connectUSB() async {
    _setConnecting(true);
    _clearError();

    try {
      _isConnected = await RfidService.connectUSB();
      if (_isConnected) {
        _getDeviceInfo();
      }
      notifyListeners();
      return _isConnected;
    } catch (e) {
      _setError('فشل الاتصال عبر USB: $e');
      return false;
    } finally {
      _setConnecting(false);
    }
  }

  Future<bool> connect(String address, int ports) async {
    _setConnecting(true);
    _clearError();

    try {
      _isConnected = await RfidService.connect(address, ports);
      if (_isConnected) {
        _getDeviceInfo();
      }
      notifyListeners();
      return _isConnected;
    } catch (e) {
      _setError('فشل الاتصال: $e');
      return false;
    } finally {
      _setConnecting(false);
    }
  }

  Future<void> _disconnect() async {
    try {
      if (_isReading) {
        await stopReading();
      }
      await RfidService.disconnect();
      _isConnected = false;
      _scannedTags.clear();
      notifyListeners();
    } catch (e) {
      print('⚠️ Error disconnecting: $e');
    }
  }

  // ============ دوال القراءة ============

  Future<void> startReading() async {
    if (!_isConnected) {
      _setError('الجهاز غير متصل');
      return;
    }

    try {
      await RfidService.startReading();
      _isReading = true;
      _scannedTags.clear();
      notifyListeners();
    } catch (e) {
      _setError('فشل بدء القراءة: $e');
    }
  }

  Future<void> stopReading() async {
    try {
      await RfidService.stopReading();
      _isReading = false;
      notifyListeners();
    } catch (e) {
      _setError('فشل إيقاف القراءة: $e');
    }
  }

  // ============ معالجة العلامات ============

  void _handleRfidTags(List<dynamic> tags) {
    for (var tag in tags) {
      final epc = tag['epc']?.toString();
      final rssi = tag['rssi']?.toString();

      if (epc != null && epc.isNotEmpty) {
        final existingIndex = _scannedTags.indexWhere((t) => t['epc'] == epc);
        final tagData = {
          'epc': epc,
          'rssi': rssi,
          'timestamp': DateTime.now().toIso8601String(),
          'tid': tag['tid']?.toString() ?? '',
          'readCount': tag['readCount'] ?? 0,
        };

        if (existingIndex != -1) {
          _scannedTags[existingIndex] = tagData;
        } else {
          _scannedTags.add(tagData);
        }

        notifyListeners();
      }
    }
  }

  // ============ معلومات الجهاز ============

  Future<void> _getDeviceInfo() async {
    try {
      final status = await RfidService.getStatus();
      _moduleInfo = status['module'] ?? 'UHF RFID Reader';
      _firmwareVersion = status['firmware'] ?? 'v1.0.0';
      _temperature = status['temperature'] ?? '25°C';
      notifyListeners();
    } catch (e) {
      print('⚠️ Error getting device info: $e');
    }
  }

  Future<void> setPower(int power) async {
    try {
      await RfidService.setPower(power);
    } catch (e) {
      _setError('فشل ضبط القوة: $e');
    }
  }

  // ============ دوال مساعدة ============

  void _setConnecting(bool value) {
    _isConnecting = value;
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

  void clearTags() {
    _scannedTags.clear();
    notifyListeners();
  }

  // إعادة محاولة الاتصال التلقائي
  Future<void> retryAutoConnect() async {
    await _checkConnectedDevices();
  }

  @override
  void dispose() {
    UsbService.dispose();
    RfidService.disconnect();
    super.dispose();
  }
}
