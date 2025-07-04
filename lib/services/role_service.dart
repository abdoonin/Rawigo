import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// دالة للتحقق من أن المستخدم هو مدير مطعم
Future<bool> isUserRestaurantManager() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  if (!doc.exists) return false;
  final role = doc.data()?['role'];
  return role == 'restaurant_manager';
  
}

// دالة للتحقق من أن المستخدم هو سائق
Future<bool> isUserDriver() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  final role = doc.get('role') as String?;
  return role == 'driver';
}

// دالة للتحقق من أن المستخدم هو عميل
Future<bool> isUserCustomer() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  final role = doc.get('role') as String?;
  return role == 'customer';
}