import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rawi_go/firebase_options.dart';
import 'package:rawi_go/screens/cart_provider.dart';
import 'package:rawi_go/screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
     MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // إعدادات التطبيق


      title: 'راوي جو',
      theme: ThemeData(primarySwatch: Colors.green, 
        textTheme: GoogleFonts.balooBhaijaan2TextTheme(Theme.of(context).textTheme).apply(bodyColor: Colors.black, displayColor: Colors.black),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green,
          titleTextStyle: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 2.0), borderRadius: BorderRadius.circular(8.0)),
          labelStyle: TextStyle(color: Colors.green),
        ),
      ),
      home: const AuthWrapper(),
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),


      
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // مراقبة حالة تسجيل الدخول
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // أثناء التحميل
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // إذا كان المستخدم مسجلًا الدخول
          return const HomeScreen();
        } else {
          // إذا لم يكن المستخدم مسجلًا الدخول
          return const LoginScreen();
        }
      },
    );
  }
}
