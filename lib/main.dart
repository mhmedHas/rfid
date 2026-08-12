// import 'package:alarm/home.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';
// import 'package:device_preview/device_preview.dart'; // 🔹 استيراد DevicePreview
// import 'firebase_options.dart';
// import 'login_page.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   // تفعيل App Check لتجنب التحذيرات
//   try {
//     await FirebaseAppCheck.instance.activate(
//       androidProvider: AndroidProvider.debug,
//       appleProvider: AppleProvider.debug,
//     );
//   } catch (e) {
//     print('App Check not configured, continuing anyway');
//   }

//   // 🔹 تشغيل التطبيق مع DevicePreview
//   runApp(
//     DevicePreview(
//       enabled: false, // 🔹 فعّال في وضع التطوير
//       builder: (context) => const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'متجر الذهب',
//       debugShowCheckedModeBanner: false,

//       // 🔹 استخدام DevicePreview
//       locale: DevicePreview.locale(context),
//       builder: DevicePreview.appBuilder,

//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),

//       // تعريف المسارات
//       initialRoute: '/login',
//       routes: {
//         '/simple_inventory': (context) => const SimpleInventoryPage(),
//         '/login': (context) => const LoginPage(),
//       },
//     );
//   }
// }
import 'package:alarm/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'package:alarm/providers/inventory_provider.dart';
import 'package:alarm/providers/rfid_provider.dart';
import 'package:alarm/screens/inventory_page.dart';
import 'package:alarm/screens/missing_items_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('⚠️ Firebase initialization error: $e');
  }

  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
  } catch (e) {
    print('⚠️ App Check not configured: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RfidProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TRAC-GOLD RFID Inventory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFF0D0B08),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          secondary: Color(0xFFF5E6A3),
          surface: Color(0xFF1A1510),
          error: Color(0xFFE55B5B),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1510),
          elevation: 0,
          centerTitle: true,
        ),

        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFF8F5F0)),
          bodyMedium: TextStyle(color: Color(0xFFF8F5F0)),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/inventory': (context) => const InventoryPage(),
        '/missing': (context) => const MissingItemsPage(),
      },
    );
  }
}
