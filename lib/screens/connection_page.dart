// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/rfid_provider.dart';

// class ConnectionPage extends StatefulWidget {
//   const ConnectionPage({super.key});

//   @override
//   State<ConnectionPage> createState() => _ConnectionPageState();
// }

// class _ConnectionPageState extends State<ConnectionPage> {
//   final _addressController = TextEditingController(text: '192.168.1.100');
//   String _selectedMethod = 'Ethernet';
//   String _selectedBaudRate = '115200';
//   String _selectedPort = '1';
  
//   final List<String> _methods = ['Ethernet', 'USB', 'Bluetooth'];
//   final List<String> _baudRates = ['9600', '19200', '38400', '57600', '115200', '230400'];
//   final List<String> _ports = ['1', '2', '3', '4'];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D0B08),
//       appBar: AppBar(
//         title: const Text('RFID READER CONNECTION'),
//         backgroundColor: const Color(0xFF1A1510),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.inventory_2),
//             onPressed: () {
//               Navigator.pushNamed(context, '/inventory');
//             },
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               // Status
//               _buildStatusCard(),
//               const SizedBox(height: 20),
              
//               // Connection Settings
//               _buildConnectionSettings(),
//               const SizedBox(height: 20),
              
//               // Buttons
//               _buildConnectionButtons(),
//               const SizedBox(height: 20),
              
//               // Device Info
//               _buildDeviceInfo(),
              
//               const Spacer(),
              
//               // Quick Inventory Button
//               _buildQuickInventoryButton(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusCard() {
//     return Consumer<RfidProvider>(
//       builder: (context, provider, child) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: const Color(0xFF1A1510),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: const Color(0x25FFFFFF)),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 width: 12,
//                 height: 12,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: provider.isConnected ? Colors.green : Colors.red,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       provider.isConnected ? 'متصل' : 'غير متصل',
//                       style: TextStyle(
//                         color: provider.isConnected ? Colors.green : Colors.red,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     if (provider.error != null)
//                       Text(
//                         provider.error!,
//                         style: const TextStyle(color: Colors.red, fontSize: 12),
//                       ),
//                   ],
//                 ),
//               ),
//               if (provider.isConnected)
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Text(
//                     'ONLINE',
//                     style: TextStyle(
//                       color: Colors.green,
//                       fontSize: 11,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildConnectionSettings() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1A1510),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0x25FFFFFF)),
//       ),
//       child: Column(
//         children: [
//           _buildDropdown(
//             label: 'Connection Method',
//             value: _selectedMethod,
//             items: _methods,
//             onChanged: (value) {
//               if (value != null) {
//                 setState(() => _selectedMethod = value);
//               }
//             },
//           ),
//           const SizedBox(height: 16),
          
//           if (_selectedMethod != 'USB')
//             _buildTextField(
//               label: 'Address',
//               controller: _addressController,
//               hint: 'Enter IP or MAC Address',
//             ),
          
//           if (_selectedMethod != 'USB') ...[
//             const SizedBox(height: 16),
//             _buildDropdown(
//               label: 'Baud Rate',
//               value: _selectedBaudRate,
//               items: _baudRates,
//               onChanged: (value) {
//                 if (value != null) {
//                   setState(() => _selectedBaudRate = value);
//                 }
//               },
//             ),
//           ],
          
//           const SizedBox(height: 16),
//           _buildDropdown(
//             label: 'Antenna Port',
//             value: _selectedPort,
//             items: _ports,
//             onChanged: (value) {
//               if (value != null) {
//                 setState(() => _selectedPort = value);
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDropdown({
//     required String label,
//     required String value,
//     required List<String> items,
//     required ValueChanged<String?> onChanged,
//   }) {
//     return Row(
//       children: [
//         SizedBox(
//           width: 120,
//           child: Text(
//             label,
//             style: const TextStyle(
//               color: Color(0xFFF8F5F0),
//               fontSize: 14,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 4),
//             decoration: BoxDecoration(
//               color: const Color(0xFF2A2520),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<String>(
//                 value: value,
//                 dropdownColor: const Color(0xFF2A2520),
//                 style: const TextStyle(color: Color(0xFFF8F5F0)),
//                 isExpanded: true,
//                 items: items.map((item) {
//                   return DropdownMenuItem(
//                     value: item,
//                     child: Text(item),
//                   );
//                 }).toList(),
//                 onChanged: onChanged,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTextField({
//     required String label,
//     required TextEditingController controller,
//     String? hint,
//   }) {
//     return Row(
//       children: [
//         SizedBox(
//           width: 120,
//           child: Text(
//             label,
//             style: const TextStyle(
//               color: Color(0xFFF8F5F0),
//               fontSize: 14,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFF2A2520),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: TextField(
//               controller: controller,
//               style: const TextStyle(color: Color(0xFFF8F5F0)),
//               decoration: InputDecoration(
//                 hintText: hint,
//                 hintStyle: const TextStyle(color: Color(0xFFA09582)),
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildConnectionButtons() {
//     return Consumer<RfidProvider>(
//       builder: (context, provider, child) {
//         return Row(
//           children: [
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: provider.isConnecting ? null : _connect,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFD4AF37),
//                   foregroundColor: Colors.black,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: provider.isConnecting
//                     ? const SizedBox(
//                         width: 24,
//                         height: 24,
//                         child: CircularProgressIndicator(
//                           color: Colors.black,
//                           strokeWidth: 2,
//                         ),
//                       )
//                     : const Text(
//                         'CONNECT',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: provider.isConnected ? _disconnect : null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   'DISCONNECT',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildDeviceInfo() {
//     return Consumer<RfidProvider>(
//       builder: (context, provider, child) {
//         if (!provider.isConnected) {
//           return const SizedBox();
//         }
        
//         return Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: const Color(0xFF1A1510),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: const Color(0x25FFFFFF)),
//           ),
//           child: Row(
//             children: [
//               const Icon(
//                 Icons.info_outline,
//                 color: Color(0xFFD4AF37),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Module: ${provider.moduleInfo ?? "---"}',
//                       style: const TextStyle(
//                         color: Color(0xFFF8F5F0),
//                         fontSize: 13,
//                       ),
//                     ),
//                     Text(
//                       'Firmware: ${provider.firmwareVersion ?? "---"}',
//                       style: const TextStyle(
//                         color: Color(0xFFA09582),
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildQuickInventoryButton() {
//     return Consumer<RfidProvider>(
//       builder: (context, provider, child) {
//         if (!provider.isConnected) {
//           return const SizedBox();
//         }
        
//         return SizedBox(
//           width: double.infinity,
//           child: ElevatedButton.icon(
//             onPressed: provider.isReading ? _stopReading : _startReading,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: provider.isReading ? Colors.red : const Color(0xFFD4AF37),
//               foregroundColor: Colors.black,
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             icon: Icon(
//               provider.isReading ? Icons.stop : Icons.play_arrow,
//               color: provider.isReading ? Colors.white : Colors.black,
//             ),
//             label: Text(
//               provider.isReading ? 'إيقاف المسح' : 'بدء المسح',
//               style: TextStyle(
//                 color: provider.isReading ? Colors.white : Colors.black,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _connect() async {
//     final provider = Provider.of<RfidProvider>(context, listen: false);
//     bool success = false;
    
//     switch (_selectedMethod) {
//       case 'USB':
//         success = await provider.connectUSB();
//         break;
//       case 'Bluetooth':
//         success = await provider.connectBluetooth(_addressController.text);
//         break;
//       default:
//         success = await provider.connect(
//           _addressController.text,
//           int.parse(_selectedPort),
//         );
//     }
    
//     if (success && mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('✅ تم الاتصال بنجاح'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } else if (!success && mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(provider.error ?? '❌ فشل الاتصال'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<void> _disconnect() async {
//     final provider = Provider.of<RfidProvider>(context, listen: false);
//     await provider.disconnect();
    
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('تم قطع الاتصال'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//     }
//   }

//   Future<void> _startReading() async {
//     final provider = Provider.of<RfidProvider>(context, listen: false);
//     await provider.startReading();
    
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('بدء المسح...'),
//           backgroundColor: Colors.blue,
//         ),
//       );
//     }
//   }

//   Future<void> _stopReading() async {
//     final provider = Provider.of<RfidProvider>(context, listen: false);
//     await provider.stopReading();
    
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('تم إيقاف المسح'),
//           backgroundColor: Colors.orange,
//         ),
//       );
      
//       // الانتقال إلى شاشة المخزون
//       Navigator.pushNamed(context, '/inventory');
//     }
//   }

//   @override
//   void dispose() {
//     _addressController.dispose();
//     super.dispose();
//   }
// }