import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';


class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

   // دالة تسجيل الدخول
  Future<bool> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true; // تسجيل الدخول ناجح
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (kDebugMode) {
          print("FirebaseAuthException during sign-in: ${e.message}");
        }
      } else {
        if (kDebugMode) {
          print("Error during sign-in: $e");
        }
      }
      return false; // فشل في تسجيل الدخول
    }
  }

  // تسجيل مستخدم جديد
   Future<bool> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (kDebugMode) {
        print("✅ تم إنشاء الحساب بنجاح");
      }
      return true; // تسجيل ناجح
    } catch (e) {
      print("Error during registration: $e");
      return false; // فشل في التسجيل
    }
  }

  // جلب قائمة المطاعم - الطريقة الأولى
  Future<List<Map<String, dynamic>>> getRestaurants() async {
    try {
      QuerySnapshot snapshot = await _db.collection("restaurants").get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>}).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  // جلب الأطباق حسب المطعم
  Future<List<Map<String, dynamic>>> getItemsByRestaurant(String restaurantId) async {
    try {
      QuerySnapshot snapshot = await _db.collection("restaurants").doc(restaurantId).collection("items").get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

 // جلب كل الأطباق من جميع المطاعم
  Future<List<Map<String, dynamic>>> getAllItems() async {
    try {
      QuerySnapshot restaurantsSnapshot = await _db.collection("restaurants").get();

      List<Map<String, dynamic>> allItems = [];

      for (var restaurant in restaurantsSnapshot.docs) {
        QuerySnapshot itemsSnapshot = await _db
            .collection("restaurants")
            .doc(restaurant.id)
            .collection("items")
            .get();

        allItems.addAll(itemsSnapshot.docs.map((doc) {
          return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
        }).toList());
      }

      return allItems;
    } catch (e) {
      print("Error fetching all items: $e");
      return [];
    }
  }


















  // 👇 إضافة جديدة: متغير ودالة ثانية لجلب المطاعم
  final CollectionReference restaurants = FirebaseFirestore.instance.collection("restaurants");

  Future<List<Map<String, dynamic>>> getRestaurantsV2() async {
    QuerySnapshot snapshot = await restaurants.get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>}).toList();
  }

final FirebaseFirestore _db = FirebaseFirestore.instance;

Future<bool> registerRestaurant(String email, String password) async {
  try {
    UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await result.user?.sendEmailVerification(); // اختياري

    // حفظ البيانات الإضافية مع الدور
    await _db.collection("users").doc(result.user?.uid).set({
      "email": email,
      "role": "restaurant",
      "timestamp": FieldValue.serverTimestamp(),
    });

    return true;
  } catch (e) {
    print("Error registering restaurant: $e");
    return false;
  }
}

// إضافة الطبق إلى السلة
  Future<void> addToCart(Map<String, dynamic> item) async {
    try {
      final userId = "user_id_here"; // استبدل هذا بمعرف المستخدم الحالي (يمكنك استخدام FirebaseAuth.instance.currentUser?.uid)
      await _db.collection("users").doc(userId).collection("cart").add({
        "itemId": item['id'],
        "name": item['name'],
        "price": item['price'],
        "imageUrl": item['imageUrl'],
        "timestamp": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding item to cart: $e");
      rethrow; // لإعادة الخطأ إلى الـ UI
    }
  }








  
//دالة حفظ الطلب في فايربايس
Future<bool> addOrderToFirebase({
  required String userId,
  required List<Map<String, dynamic>> items,
  required double totalPrice,
}) async {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  try {
    await db.collection("orders").add({
      "userId": userId,
      "items": items,
      "totalPrice": totalPrice,
      "status": "قيد التجهيز",
      "timestamp": FieldValue.serverTimestamp(),
    });
    return true;
  } catch (e) {
    if (kDebugMode) {
      print("Error adding order: $e");
    }
    return false;
  }
}
}

