import 'package:alarm/login_page.dart';
import 'package:alarm/screens/rfid_inventory_page.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
  } catch (_) {}

  runApp(const TracGoldApp());
}

class TracGoldApp extends StatelessWidget {
  const TracGoldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TRAC-GOLD RFID',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD4AF37)),
        fontFamily: 'Arial',
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/inventory': (_) => const RfidInventoryPage(),
      },
    );
  }
}
