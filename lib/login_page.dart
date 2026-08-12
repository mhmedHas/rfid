// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:google_sign_in/google_sign_in.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

// // // ==================== Design Tokens ====================
// // class _Palette {
// //   static const darkBg = Color(0xFF0D0B08);
// //   static const darkSurface = Color(0xFF1A1510);
// //   static const goldPrimary = Color(0xFFD4AF37);
// //   static const goldLight = Color(0xFFF5E6A3);
// //   static const goldDark = Color(0xFFAA7C11);
// //   static const textWhite = Color(0xFFF8F5F0);
// //   static const textMuted = Color(0xFFA09582);
// //   static const errorRed = Color(0xFFE55B5B);
// //   static const errorBg = Color(0x1AE55B5B);
// //   static const glassBg = Color(0x15FFFFFF);
// //   static const glassBorder = Color(0x25FFFFFF);
// // }

// // class LoginPage extends StatefulWidget {
// //   const LoginPage({super.key});

// //   @override
// //   State<LoginPage> createState() => _LoginPageState();
// // }

// // class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
// //   final emailController = TextEditingController();
// //   final passController = TextEditingController();
// //   bool busy = false;
// //   String? error;
// //   bool _obscurePassword = true;

// //   late final AnimationController _pageController;
// //   late final Animation<double> _fadeAnimation;
// //   late final Animation<Offset> _slideAnimation;

// //   final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

// //   @override
// //   void initState() {
// //     super.initState();

// //     // إعداد الأنيمشن
// //     _pageController = AnimationController(
// //       duration: const Duration(milliseconds: 1000),
// //       vsync: this,
// //     );

// //     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
// //       CurvedAnimation(
// //         parent: _pageController,
// //         curve: const Interval(0.0, 0.8, curve: Curves.easeOutQuad),
// //       ),
// //     );

// //     _slideAnimation =
// //         Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
// //           CurvedAnimation(
// //             parent: _pageController,
// //             curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
// //           ),
// //         );

// //     _pageController.forward();

// //     // التحقق من حالة المستخدم عند بدء التطبيق
// //     _checkUserLoggedIn();
// //   }

// //   // دالة التحقق من حالة تسجيل الدخول
// //   Future<void> _checkUserLoggedIn() async {
// //     // 1. التحقق من Firebase Auth
// //     final user = FirebaseAuth.instance.currentUser;

// //     if (user != null) {
// //       // 2. التحقق من SharedPreferences للتأكد من أن المستخدم قد سجل دخوله سابقاً
// //       final prefs = await SharedPreferences.getInstance();
// //       final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

// //       if (isLoggedIn && mounted) {
// //         Navigator.pushReplacementNamed(context, '/simple_inventory');
// //       }
// //     }
// //   }

// //   // دالة حفظ حالة تسجيل الدخول
// //   Future<void> _saveLoginState() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     await prefs.setBool('isLoggedIn', true);
// //   }

// //   // دالة حذف حالة تسجيل الدخول (عند تسجيل الخروج)
// //   Future<void> _clearLoginState() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     await prefs.remove('isLoggedIn');
// //   }

// //   @override
// //   void dispose() {
// //     _pageController.dispose();
// //     emailController.dispose();
// //     passController.dispose();
// //     super.dispose();
// //   }

// //   Future<void> _emailLogin() async {
// //     setState(() {
// //       busy = true;
// //       error = null;
// //     });

// //     try {
// //       await FirebaseAuth.instance.signInWithEmailAndPassword(
// //         email: emailController.text.trim(),
// //         password: passController.text,
// //       );

// //       // حفظ حالة تسجيل الدخول
// //       await _saveLoginState();

// //       if (mounted) {
// //         Navigator.pushReplacementNamed(context, '/home');
// //       }
// //     } on FirebaseAuthException catch (e) {
// //       setState(() {
// //         error = _getFriendlyErrorMessage(e.code);
// //       });
// //     } catch (e) {
// //       setState(() {
// //         error = 'حدث خطأ غير متوقع. حاول مرة أخرى.';
// //       });
// //     } finally {
// //       if (mounted) {
// //         setState(() {
// //           busy = false;
// //         });
// //       }
// //     }
// //   }

// //   String _getFriendlyErrorMessage(String code) {
// //     switch (code) {
// //       case 'user-not-found':
// //         return 'البريد الإلكتروني غير مسجل';
// //       case 'wrong-password':
// //         return 'كلمة المرور غير صحيحة';
// //       case 'invalid-email':
// //         return 'البريد الإلكتروني غير صالح';
// //       case 'too-many-requests':
// //         return 'تم حظر الحساب مؤقتاً، حاول لاحقاً';
// //       default:
// //         return 'خطأ في تسجيل الدخول';
// //     }
// //   }

// //   Future<void> _googleLogin() async {
// //     setState(() {
// //       busy = true;
// //       error = null;
// //     });

// //     try {
// //       await _googleSignIn.signOut();
// //       final googleUser = await _googleSignIn.signIn();

// //       if (googleUser == null) {
// //         setState(() => error = 'تم إلغاء عملية الدخول');
// //         return;
// //       }

// //       final googleAuth = await googleUser.authentication;
// //       final credential = GoogleAuthProvider.credential(
// //         accessToken: googleAuth.accessToken,
// //         idToken: googleAuth.idToken,
// //       );

// //       await FirebaseAuth.instance.signInWithCredential(credential);

// //       // حفظ حالة تسجيل الدخول
// //       await _saveLoginState();

// //       if (mounted) {
// //         Navigator.pushReplacementNamed(context, '/home');
// //       }
// //     } on FirebaseAuthException catch (e) {
// //       setState(() {
// //         error = e.message ?? 'خطأ في المصادقة';
// //       });
// //     } catch (e) {
// //       setState(() {
// //         error = 'حدث خطأ غير متوقع';
// //       });
// //     } finally {
// //       if (mounted) {
// //         setState(() {
// //           busy = false;
// //         });
// //       }
// //     }
// //   }

// //   InputDecoration _buildInputDecoration({
// //     required String label,
// //     required IconData icon,
// //     Widget? suffix,
// //   }) {
// //     return InputDecoration(
// //       labelText: label,
// //       labelStyle: const TextStyle(color: _Palette.textMuted),
// //       prefixIcon: Icon(
// //         icon,
// //         color: _Palette.goldPrimary.withOpacity(0.7),
// //         size: 20,
// //       ),
// //       suffixIcon: suffix,
// //       filled: true,
// //       fillColor: _Palette.glassBg,
// //       contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
// //       border: OutlineInputBorder(
// //         borderRadius: BorderRadius.circular(16),
// //         borderSide: BorderSide(color: _Palette.glassBorder),
// //       ),
// //       enabledBorder: OutlineInputBorder(
// //         borderRadius: BorderRadius.circular(16),
// //         borderSide: BorderSide(color: _Palette.glassBorder),
// //       ),
// //       focusedBorder: OutlineInputBorder(
// //         borderRadius: BorderRadius.circular(16),
// //         borderSide: const BorderSide(color: _Palette.goldPrimary, width: 1.5),
// //       ),
// //       errorBorder: OutlineInputBorder(
// //         borderRadius: BorderRadius.circular(16),
// //         borderSide: const BorderSide(color: _Palette.errorRed, width: 1.5),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Stack(
// //         children: [
// //           // خلفية
// //           Positioned.fill(
// //             child: Container(color: const Color.fromARGB(255, 0, 0, 0)),
// //           ),
// //           SafeArea(
// //             child: Center(
// //               child: SingleChildScrollView(
// //                 padding: const EdgeInsets.all(24),
// //                 child: FadeTransition(
// //                   opacity: _fadeAnimation,
// //                   child: SlideTransition(
// //                     position: _slideAnimation,
// //                     child: ConstrainedBox(
// //                       constraints: const BoxConstraints(maxWidth: 420),
// //                       child: Transform.translate(
// //                         offset: const Offset(0, -80),
// //                         child: Column(
// //                           mainAxisAlignment: MainAxisAlignment.center,
// //                           children: [
// //                             // اللوجو
// //                             _buildLogo(),
// //                             const SizedBox(height: 28),

// //                             // العنوان
// //                             const Text(
// //                               'Gold Store',
// //                               style: TextStyle(
// //                                 fontSize: 32,
// //                                 fontWeight: FontWeight.w700,
// //                                 letterSpacing: 1.0,
// //                                 color: _Palette.textWhite,
// //                                 fontFamily: 'Serif',
// //                               ),
// //                             ),
// //                             const SizedBox(height: 8),
// //                             Text(
// //                               'تسجيل الدخول للمتابعة',
// //                               style: TextStyle(
// //                                 fontSize: 15,
// //                                 color: _Palette.textMuted,
// //                                 letterSpacing: 0.3,
// //                               ),
// //                             ),
// //                             const SizedBox(height: 40),

// //                             // حقول الإدخال
// //                             _buildCard(
// //                               child: Column(
// //                                 children: [
// //                                   TextField(
// //                                     controller: emailController,
// //                                     keyboardType: TextInputType.emailAddress,
// //                                     style: const TextStyle(
// //                                       color: _Palette.textWhite,
// //                                     ),
// //                                     decoration: _buildInputDecoration(
// //                                       label: 'البريد الإلكتروني',
// //                                       icon: Icons.email_outlined,
// //                                     ),
// //                                   ),
// //                                   const SizedBox(height: 20),
// //                                   TextField(
// //                                     controller: passController,
// //                                     obscureText: _obscurePassword,
// //                                     style: const TextStyle(
// //                                       color: _Palette.textWhite,
// //                                     ),
// //                                     decoration: _buildInputDecoration(
// //                                       label: 'كلمة المرور',
// //                                       icon: Icons.lock_outline,
// //                                       suffix: IconButton(
// //                                         icon: Icon(
// //                                           _obscurePassword
// //                                               ? Icons.visibility_off_outlined
// //                                               : Icons.visibility_outlined,
// //                                           color: _Palette.textMuted,
// //                                           size: 20,
// //                                         ),
// //                                         onPressed: () => setState(
// //                                           () => _obscurePassword =
// //                                               !_obscurePassword,
// //                                         ),
// //                                       ),
// //                                     ),
// //                                   ),

// //                                   Padding(
// //                                     padding: const EdgeInsets.only(top: 30),
// //                                     child: _buildGradientButton(
// //                                       onPressed: busy ? null : _emailLogin,
// //                                       text: 'تسجيل الدخول',
// //                                       isLoading: busy,
// //                                     ),
// //                                   ),

// //                                   // زر جوجل
// //                                   // Padding(
// //                                   //   padding: const EdgeInsets.only(top: 12),
// //                                   //   child: _buildGoogleButton(),
// //                                   // ),

// //                                   // رسالة الخطأ
// //                                   if (error != null)
// //                                     Padding(
// //                                       padding: const EdgeInsets.only(top: 16),
// //                                       child: Container(
// //                                         padding: const EdgeInsets.symmetric(
// //                                           horizontal: 16,
// //                                           vertical: 12,
// //                                         ),
// //                                         decoration: BoxDecoration(
// //                                           color: _Palette.errorBg,
// //                                           borderRadius: BorderRadius.circular(
// //                                             12,
// //                                           ),
// //                                           border: Border.all(
// //                                             color: _Palette.errorRed
// //                                                 .withOpacity(0.3),
// //                                           ),
// //                                         ),
// //                                         child: Row(
// //                                           children: [
// //                                             const Icon(
// //                                               Icons.error_outline,
// //                                               color: _Palette.errorRed,
// //                                               size: 18,
// //                                             ),
// //                                             const SizedBox(width: 10),
// //                                             Expanded(
// //                                               child: Text(
// //                                                 error!,
// //                                                 style: const TextStyle(
// //                                                   color: _Palette.errorRed,
// //                                                   fontSize: 13,
// //                                                 ),
// //                                               ),
// //                                             ),
// //                                           ],
// //                                         ),
// //                                       ),
// //                                     ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildLogo() {
// //     return Container(
// //       width: 80,
// //       height: 80,
// //       decoration: BoxDecoration(
// //         shape: BoxShape.circle,
// //         gradient: const LinearGradient(
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //           colors: [_Palette.goldLight, _Palette.goldPrimary, _Palette.goldDark],
// //         ),
// //       ),
// //       child: const Icon(Icons.diamond, size: 40, color: _Palette.darkBg),
// //     );
// //   }

// //   Widget _buildCard({required Widget child}) {
// //     return Container(
// //       padding: const EdgeInsets.all(24),
// //       decoration: BoxDecoration(
// //         color: _Palette.darkSurface.withOpacity(0.8),
// //         borderRadius: BorderRadius.circular(20),
// //         border: Border.all(color: _Palette.glassBorder, width: 1),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.3),
// //             blurRadius: 40,
// //             offset: const Offset(0, 20),
// //           ),
// //         ],
// //       ),
// //       child: child,
// //     );
// //   }

// //   Widget _buildGradientButton({
// //     required VoidCallback? onPressed,
// //     required String text,
// //     required bool isLoading,
// //   }) {
// //     return SizedBox(
// //       width: double.infinity,
// //       height: 54,
// //       child: DecoratedBox(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(16),
// //           gradient: const LinearGradient(
// //             begin: Alignment.centerLeft,
// //             end: Alignment.centerRight,
// //             colors: [
// //               _Palette.goldDark,
// //               _Palette.goldPrimary,
// //               _Palette.goldLight,
// //             ],
// //           ),
// //           boxShadow: [
// //             BoxShadow(
// //               color: _Palette.goldPrimary.withOpacity(0.3),
// //               blurRadius: 20,
// //               offset: const Offset(0, 8),
// //             ),
// //           ],
// //         ),
// //         child: ElevatedButton(
// //           onPressed: onPressed,
// //           style: ElevatedButton.styleFrom(
// //             backgroundColor: Colors.transparent,
// //             shadowColor: Colors.transparent,
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(16),
// //             ),
// //           ),
// //           child: isLoading
// //               ? const SizedBox(
// //                   width: 24,
// //                   height: 24,
// //                   child: CircularProgressIndicator(
// //                     color: _Palette.darkBg,
// //                     strokeWidth: 2.5,
// //                   ),
// //                 )
// //               : Text(
// //                   text,
// //                   style: const TextStyle(
// //                     fontSize: 17,
// //                     fontWeight: FontWeight.w700,
// //                     letterSpacing: 0.5,
// //                     color: _Palette.darkBg,
// //                   ),
// //                 ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // // ==================== Background Pattern ====================
// // class _BgPatternPainter extends CustomPainter {
// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final paint = Paint()
// //       ..color = _Palette.goldPrimary.withOpacity(0.035)
// //       ..style = PaintingStyle.stroke
// //       ..strokeWidth = 1.0;

// //     const step = 80.0;
// //     for (double y = -step; y < size.height + step; y += step) {
// //       for (double x = -step; x < size.width + step; x += step) {
// //         final path = Path()
// //           ..moveTo(x, y + step / 2)
// //           ..lineTo(x + step / 2, y)
// //           ..lineTo(x + step, y + step / 2)
// //           ..lineTo(x + step / 2, y + step)
// //           ..close();
// //         canvas.drawPath(path, paint);
// //       }
// //     }
// //   }

// //   @override
// //   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// // }
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:provider/provider.dart';
// import '../providers/rfid_provider.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;
//   String? _error;
//   bool _obscurePassword = true;
//   bool _isConnecting = false;

//   final GoogleSignIn _googleSignIn = GoogleSignIn();

//   @override
//   void initState() {
//     super.initState();
//     _checkUserLoggedIn();

//     // مراقبة حالة الاتصال
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final rfidProvider = Provider.of<RfidProvider>(context, listen: false);
//       rfidProvider.addListener(_onRfidStatusChanged);
//     });
//   }

//   void _onRfidStatusChanged() {
//     final rfidProvider = Provider.of<RfidProvider>(context, listen: false);
//     if (rfidProvider.isConnected && mounted) {
//       // إذا تم الاتصال تلقائياً، انتقل إلى المخزون
//       Navigator.pushReplacementNamed(context, '/inventory');
//     }
//   }

//   Future<void> _checkUserLoggedIn() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final prefs = await SharedPreferences.getInstance();
//       final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

//       if (isLoggedIn && mounted) {
//         // الانتظار قليلاً للاتصال التلقائي
//         setState(() => _isConnecting = true);

//         // بدء الاتصال التلقائي
//         final rfidProvider = Provider.of<RfidProvider>(context, listen: false);
//         await rfidProvider.retryAutoConnect();

//         setState(() => _isConnecting = false);

//         // إذا كان متصلاً، انتقل للمخزون
//         if (rfidProvider.isConnected && mounted) {
//           Navigator.pushReplacementNamed(context, '/inventory');
//         } else {
//           // إذا لم يتصل، ابق في شاشة الدخول مع إشعار
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('⏳ جاري محاولة الاتصال بالقارئ...'),
//               backgroundColor: Colors.orange,
//               duration: Duration(seconds: 3),
//             ),
//           );
//         }
//       }
//     }
//   }

//   Future<void> _emailLogin() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text,
//       );

//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isLoggedIn', true);

//       if (mounted) {
//         // محاولة الاتصال التلقائي بعد تسجيل الدخول
//         setState(() => _isConnecting = true);

//         final rfidProvider = Provider.of<RfidProvider>(context, listen: false);
//         await rfidProvider.retryAutoConnect();

//         setState(() => _isConnecting = false);

//         // الانتقال للمخزون
//         Navigator.pushReplacementNamed(context, '/inventory');
//       }
//     } on FirebaseAuthException catch (e) {
//       setState(() {
//         _error = _getErrorMessage(e.code);
//       });
//     } catch (e) {
//       setState(() {
//         _error = 'حدث خطأ غير متوقع';
//       });
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<void> _googleLogin() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       await _googleSignIn.signOut();
//       final googleUser = await _googleSignIn.signIn();

//       if (googleUser == null) {
//         setState(() => _error = 'تم إلغاء عملية الدخول');
//         return;
//       }

//       final googleAuth = await googleUser.authentication;
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       await FirebaseAuth.instance.signInWithCredential(credential);

//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isLoggedIn', true);

//       if (mounted) {
//         setState(() => _isConnecting = true);

//         final rfidProvider = Provider.of<RfidProvider>(context, listen: false);
//         await rfidProvider.retryAutoConnect();

//         setState(() => _isConnecting = false);

//         Navigator.pushReplacementNamed(context, '/inventory');
//       }
//     } catch (e) {
//       setState(() {
//         _error = 'حدث خطأ في تسجيل الدخول';
//       });
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   String _getErrorMessage(String code) {
//     switch (code) {
//       case 'user-not-found':
//         return 'البريد الإلكتروني غير مسجل';
//       case 'wrong-password':
//         return 'كلمة المرور غير صحيحة';
//       case 'invalid-email':
//         return 'البريد الإلكتروني غير صالح';
//       case 'too-many-requests':
//         return 'تم حظر الحساب مؤقتاً، حاول لاحقاً';
//       default:
//         return 'خطأ في تسجيل الدخول';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Color(0xFF0D0B08), Color(0xFF1A1510)],
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // حالة الاتصال التلقائي
//                   if (_isConnecting) ...[
//                     const CircularProgressIndicator(color: Color(0xFFD4AF37)),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'جاري الاتصال بالقارئ...',
//                       style: TextStyle(color: Color(0xFFD4AF37), fontSize: 14),
//                     ),
//                     const SizedBox(height: 24),
//                   ],

//                   // حالة القارئ
//                   Consumer<RfidProvider>(
//                     builder: (context, provider, child) {
//                       if (provider.isConnected) {
//                         return Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.green.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: Colors.green),
//                           ),
//                           child: const Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.usb, color: Colors.green),
//                               SizedBox(width: 8),
//                               Text(
//                                 '✅ القارئ متصل',
//                                 style: TextStyle(
//                                   color: Colors.green,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       } else if (provider.error != null) {
//                         return Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.red.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: Colors.red),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const Icon(Icons.error, color: Colors.red),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   provider.error!,
//                                   style: const TextStyle(
//                                     color: Colors.red,
//                                     fontSize: 12,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       }
//                       return const SizedBox();
//                     },
//                   ),

//                   const SizedBox(height: 24),

//                   // Logo
//                   Container(
//                     width: 80,
//                     height: 80,
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFFD4AF37), Color(0xFFF5E6A3)],
//                       ),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.diamond,
//                       size: 40,
//                       color: Colors.black,
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   const Text(
//                     'TRAC-GOLD',
//                     style: TextStyle(
//                       color: Color(0xFFF8F5F0),
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 2,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'RFID Inventory System',
//                     style: TextStyle(color: Color(0xFFA09582), fontSize: 16),
//                   ),
//                   const SizedBox(height: 40),

//                   // Form
//                   Container(
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF1A1510),
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(color: const Color(0x25FFFFFF)),
//                     ),
//                     child: Column(
//                       children: [
//                         TextField(
//                           controller: _emailController,
//                           style: const TextStyle(color: Color(0xFFF8F5F0)),
//                           decoration: InputDecoration(
//                             labelText: 'البريد الإلكتروني',
//                             labelStyle: const TextStyle(
//                               color: Color(0xFFA09582),
//                             ),
//                             prefixIcon: const Icon(
//                               Icons.email_outlined,
//                               color: Color(0xFFD4AF37),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(
//                                 color: Color(0x25FFFFFF),
//                               ),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(
//                                 color: Color(0xFFD4AF37),
//                               ),
//                             ),
//                             filled: true,
//                             fillColor: const Color(0xFF2A2520),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         TextField(
//                           controller: _passwordController,
//                           obscureText: _obscurePassword,
//                           style: const TextStyle(color: Color(0xFFF8F5F0)),
//                           decoration: InputDecoration(
//                             labelText: 'كلمة المرور',
//                             labelStyle: const TextStyle(
//                               color: Color(0xFFA09582),
//                             ),
//                             prefixIcon: const Icon(
//                               Icons.lock_outline,
//                               color: Color(0xFFD4AF37),
//                             ),
//                             suffixIcon: IconButton(
//                               icon: Icon(
//                                 _obscurePassword
//                                     ? Icons.visibility_off_outlined
//                                     : Icons.visibility_outlined,
//                                 color: const Color(0xFFA09582),
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   _obscurePassword = !_obscurePassword;
//                                 });
//                               },
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(
//                                 color: Color(0x25FFFFFF),
//                               ),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(
//                                 color: Color(0xFFD4AF37),
//                               ),
//                             ),
//                             filled: true,
//                             fillColor: const Color(0xFF2A2520),
//                           ),
//                         ),
//                         const SizedBox(height: 24),

//                         // Login Button
//                         SizedBox(
//                           width: double.infinity,
//                           height: 50,
//                           child: ElevatedButton(
//                             onPressed: (_isLoading || _isConnecting)
//                                 ? null
//                                 : _emailLogin,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFFD4AF37),
//                               foregroundColor: Colors.black,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             child: _isLoading
//                                 ? const SizedBox(
//                                     width: 24,
//                                     height: 24,
//                                     child: CircularProgressIndicator(
//                                       color: Colors.black,
//                                       strokeWidth: 2,
//                                     ),
//                                   )
//                                 : const Text(
//                                     'تسجيل الدخول',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                           ),
//                         ),

//                         if (_error != null) ...[
//                           const SizedBox(height: 16),
//                           Container(
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: Colors.red.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(
//                                 color: Colors.red.withOpacity(0.3),
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 const Icon(
//                                   Icons.error_outline,
//                                   color: Colors.red,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: Text(
//                                     _error!,
//                                     style: const TextStyle(color: Colors.red),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   // زر إعادة محاولة الاتصال
//                   Consumer<RfidProvider>(
//                     builder: (context, provider, child) {
//                       if (!provider.isConnected && !provider.isAutoConnecting) {
//                         return TextButton(
//                           onPressed: () async {
//                             setState(() => _isConnecting = true);
//                             await provider.retryAutoConnect();
//                             setState(() => _isConnecting = false);

//                             if (provider.isConnected && mounted) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('✅ تم الاتصال بالقارئ'),
//                                   backgroundColor: Colors.green,
//                                 ),
//                               );
//                               Navigator.pushReplacementNamed(
//                                 context,
//                                 '/inventory',
//                               );
//                             }
//                           },
//                           child: const Text(
//                             '🔄 محاولة الاتصال بالقارئ',
//                             style: TextStyle(color: Color(0xFFD4AF37)),
//                           ),
//                         );
//                       }
//                       return const SizedBox();
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==================== Design Tokens ====================
class _Palette {
  static const darkBg = Color(0xFF0D0B08);
  static const darkSurface = Color(0xFF1A1510);
  static const goldPrimary = Color(0xFFD4AF37);
  static const goldLight = Color(0xFFF5E6A3);
  static const goldDark = Color(0xFFAA7C11);
  static const textWhite = Color(0xFFF8F5F0);
  static const textMuted = Color(0xFFA09582);
  static const errorRed = Color(0xFFE55B5B);
  static const errorBg = Color(0x1AE55B5B);
  static const glassBg = Color(0x15FFFFFF);
  static const glassBorder = Color(0x25FFFFFF);
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool busy = false;
  String? error;
  bool _obscurePassword = true;

  late final AnimationController _pageController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  @override
  void initState() {
    super.initState();

    // إعداد الأنيمشن
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutQuad),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _pageController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _pageController.forward();

    // ✅ التحقق من حالة المستخدم عند بدء التطبيق
    _checkUserLoggedIn();
  }

  // ===================== دوال حفظ الجلسة =====================

  /// ✅ دالة التحقق من حالة تسجيل الدخول
  Future<void> _checkUserLoggedIn() async {
    try {
      // 1. التحقق من Firebase Auth
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // 2. التحقق من SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

        if (isLoggedIn && mounted) {
          // ✅ التوجيه لشاشة المخزون
          Navigator.pushReplacementNamed(context, '/inventory');
        }
      }
    } catch (e) {
      print('⚠️ Error checking login state: $e');
    }
  }

  /// ✅ دالة حفظ حالة تسجيل الدخول
  Future<void> _saveLoginState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      print('✅ Login state saved');
    } catch (e) {
      print('⚠️ Error saving login state: $e');
    }
  }

  /// ✅ دالة حذف حالة تسجيل الدخول (عند تسجيل الخروج)
  Future<void> _clearLoginState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      print('✅ Login state cleared');
    } catch (e) {
      print('⚠️ Error clearing login state: $e');
    }
  }

  // ===================== دوال تسجيل الدخول =====================

  /// ✅ تسجيل الدخول بالبريد الإلكتروني
  Future<void> _emailLogin() async {
    if (!mounted) return;

    setState(() {
      busy = true;
      error = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text,
      );

      // ✅ حفظ حالة تسجيل الدخول
      await _saveLoginState();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/inventory');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          error = _getFriendlyErrorMessage(e.code);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'حدث خطأ غير متوقع. حاول مرة أخرى.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  /// ✅ تسجيل الدخول بـ Google
  Future<void> _googleLogin() async {
    if (!mounted) return;

    setState(() {
      busy = true;
      error = null;
    });

    try {
      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        if (mounted) {
          setState(() => error = 'تم إلغاء عملية الدخول');
        }
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // ✅ حفظ حالة تسجيل الدخول
      await _saveLoginState();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/inventory');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          error = e.message ?? 'خطأ في المصادقة';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'حدث خطأ غير متوقع';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  /// ✅ ترجمة رسائل الخطأ
  String _getFriendlyErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'البريد الإلكتروني غير مسجل';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'too-many-requests':
        return 'تم حظر الحساب مؤقتاً، حاول لاحقاً';
      default:
        return 'خطأ في تسجيل الدخول';
    }
  }

  // ===================== دوال الـ UI =====================

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _Palette.textMuted),
      prefixIcon: Icon(
        icon,
        color: _Palette.goldPrimary.withOpacity(0.7),
        size: 20,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: _Palette.glassBg,
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _Palette.glassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _Palette.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _Palette.goldPrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _Palette.errorRed, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ خلفية سوداء مع نقشة ذهبية
          Positioned.fill(
            child: CustomPaint(
              painter: _BgPatternPainter(),
              child: Container(color: _Palette.darkBg),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Transform.translate(
                        offset: const Offset(0, -40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ✅ اللوجو
                            _buildLogo(),
                            const SizedBox(height: 28),

                            // ✅ العنوان
                            const Text(
                              'TRAC-GOLD',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.0,
                                color: _Palette.textWhite,
                                fontFamily: 'Serif',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'تسجيل الدخول للمتابعة',
                              style: TextStyle(
                                fontSize: 15,
                                color: _Palette.textMuted,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // ✅ حقول الإدخال
                            _buildCard(
                              child: Column(
                                children: [
                                  TextField(
                                    controller: emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(
                                      color: _Palette.textWhite,
                                    ),
                                    decoration: _buildInputDecoration(
                                      label: 'البريد الإلكتروني',
                                      icon: Icons.email_outlined,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    controller: passController,
                                    obscureText: _obscurePassword,
                                    style: const TextStyle(
                                      color: _Palette.textWhite,
                                    ),
                                    decoration: _buildInputDecoration(
                                      label: 'كلمة المرور',
                                      icon: Icons.lock_outline,
                                      suffix: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: _Palette.textMuted,
                                          size: 20,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        // ✅ يمكن إضافة وظيفة "نسيت كلمة المرور"
                                      },
                                      child: Text(
                                        'نسيت كلمة المرور؟',
                                        style: TextStyle(
                                          color: _Palette.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: _buildGradientButton(
                                      onPressed: busy ? null : _emailLogin,
                                      text: 'تسجيل الدخول',
                                      isLoading: busy,
                                    ),
                                  ),

                                  // ✅ زر جوجل (معلق)
                                  // Padding(
                                  //   padding: const EdgeInsets.only(top: 12),
                                  //   child: _buildGoogleButton(),
                                  // ),

                                  // ✅ رسالة الخطأ
                                  if (error != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _Palette.errorBg,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: _Palette.errorRed
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.error_outline,
                                              color: _Palette.errorRed,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                error!,
                                                style: const TextStyle(
                                                  color: _Palette.errorRed,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  // ✅ زر الخروج من الجلسة (للتجربة)
                                  if (FirebaseAuth.instance.currentUser != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: TextButton(
                                        onPressed: () async {
                                          await FirebaseAuth.instance.signOut();
                                          await _clearLoginState();
                                          if (mounted) {
                                            setState(() {
                                              error = 'تم تسجيل الخروج';
                                            });
                                          }
                                        },
                                        child: Text(
                                          'تسجيل الخروج',
                                          style: TextStyle(
                                            color: _Palette.textMuted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== مكونات الـ UI =====================

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_Palette.goldLight, _Palette.goldPrimary, _Palette.goldDark],
        ),
      ),
      child: const Icon(Icons.diamond, size: 40, color: _Palette.darkBg),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _Palette.darkSurface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _Palette.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildGradientButton({
    required VoidCallback? onPressed,
    required String text,
    required bool isLoading,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              _Palette.goldDark,
              _Palette.goldPrimary,
              _Palette.goldLight,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: _Palette.goldPrimary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: _Palette.darkBg,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: _Palette.darkBg,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }
}

// ==================== Background Pattern ====================
class _BgPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _Palette.goldPrimary.withOpacity(0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const step = 80.0;
    for (double y = -step; y < size.height + step; y += step) {
      for (double x = -step; x < size.width + step; x += step) {
        final path = Path()
          ..moveTo(x, y + step / 2)
          ..lineTo(x + step / 2, y)
          ..lineTo(x + step, y + step / 2)
          ..lineTo(x + step / 2, y + step)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
