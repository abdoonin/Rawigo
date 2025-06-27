// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // تسجيل الدخول
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;

    } on FirebaseAuthException catch (e) {
      print("Error during sign in: $e");
      // يمكنك إضافة معالجة أخطاء أكثر تفصيلاً هنا
      if (e.code == 'user-not-found') {
        print("User not found");
      }
      return null;

    }
  }

  // التسجيل
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("Error during sign up: $e");
      return null;
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  // مراقبة حالة المستخدم
  Stream<User?> get user {
    return _auth.authStateChanges();
  }



  // تسجيل الدخول عبر Google
  
  
}