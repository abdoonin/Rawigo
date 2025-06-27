import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyOrdersScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

   MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String? userId = _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("طلباتي")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .where("userId", isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var order = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              String status = order['status'] ?? "غير معروف";

              Color statusColor = Colors.grey;
              if (status == "قيد التجهيز") statusColor = Colors.orange;
              if (status == "جاهز للتوصيل") statusColor = Colors.blue;
              if (status == "تم التوصيل") statusColor = Colors.green;

              return ListTile(
                title: Text("المجموع: ${order['totalPrice']} دينار"),
                subtitle: Text("الحالة: $status"),
                trailing: Icon(Icons.circle, color: statusColor),
              );
            },
          );
        },

        
      ),
    );
  }
}