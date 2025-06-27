import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_orders_screen.dart';

class ProtectedAdminScreen extends StatelessWidget {
  const ProtectedAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;

        // الحصول على بيانات المستخدم من Firestore
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection("users").doc(user?.uid).snapshots(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final userData = userSnapshot.data?.data() as Map<String, dynamic>?;

            final role = userData?['role'] ?? '';

            if (role == 'restaurant' || role == 'admin') {
              // السماح بالدخول إلى لوحة الإدارة
              return const AdminOrdersScreen();
            } else {
              // عرض رسالة رفض
              return const AccessDeniedScreen();
            }
          },
        );
      },
    );
  }
}

// شاشة الرفض
class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "عذراً، ليس لديك صلاحية الوصول إلى هذه الصفحة",
        style: TextStyle(fontSize: 18, color: Colors.red),
        textAlign: TextAlign.center,
      ),
    );
  }
}