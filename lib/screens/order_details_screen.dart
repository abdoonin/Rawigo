import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rawi_go/screens/cart_provider.dart';
import 'package:rawi_go/screens/cart_screen.dart';
import 'package:rawi_go/services/firebase_service.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String restaurantId;

  const OrderDetailsScreen({super.key, required this.restaurantId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late Future<List<Map<String, dynamic>>> items;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    items = _firebaseService.getItemsByRestaurant(widget.restaurantId);
  }

  // قائمة لتخزين الأطباق المختارة

  void _addToCartAndFirebase(BuildContext context, Map<String, dynamic> item) {
    var cart = Provider.of<CartProvider>(context, listen: false);

    cart.addToCart(
      item['name'],
      item['price'].toDouble(),
      item['imageUrl'], // إذا كانت لديك صورة
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
      content: Text("${item['name']} تمت الإضافة"),
      duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("قائمة الطعام")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: items,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("لا يوجد أطباق متاحة"));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var item = snapshot.data![index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 12.0,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: Colors.teal,
                      width: 1.5,
                    ),
                  ),
                  // ignore: deprecated_member_use
                  tileColor: Colors.teal.withOpacity(0.13),
                  // ignore: deprecated_member_use
                  leading:
                      item['imageUrl'] != null && item['imageUrl'].isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                          imageUrl: item['imageUrl'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                            const Icon(Icons.error_outline),
                          ),
                        )
                      : const Icon(Icons.food_bank_rounded, size: 60),
                  title: Text(item['name']),
                  subtitle: Text("${item['price']} دينار"),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () => _addToCartAndFirebase(context, item),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => CartScreen()),
          );
        },
        label: const Text(
          "السلة",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        icon: const Icon(
          Icons.shopping_cart_outlined,
          size: 24,
          color: Colors.white,
        ),
        backgroundColor: Colors.teal,

        //       ),
        //       bottomNavigationBar: Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: ElevatedButton.icon(
        //     onPressed: () async {
        //       final cart = Provider.of<CartProvider>(context, listen: false);
        //       final user = FirebaseAuth.instance.currentUser;

        //       if (user == null) {
        //         ScaffoldMessenger.of(context).showSnackBar(
        //           const SnackBar(content: Text("يجب تسجيل الدخول لإرسال الطلب")),
        //         );
        //         return;
        //       }

        //       bool success = await _firebaseService.addOrderToFirebase(
        //         userId: user.uid,
        //         items: cart.items.map((item) => item.toMap()).toList(),
        //         totalPrice: cart.totalPrice,
        //       );

        //       if (success) {
        //         cart.clearCart();
        //         ScaffoldMessenger.of(context).showSnackBar(
        //           const SnackBar(content: Text("تم إرسال الطلب بنجاح")),
        //         );
        //       } else {
        //         ScaffoldMessenger.of(context).showSnackBar(
        //           const SnackBar(content: Text("فشل في إرسال الطلب")),
        //         );
        //       }
        //     },
        //     icon: const Icon(Icons.send),
        //     label: const Text("إرسال الطلب"),
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Colors.orange,
        //       padding: const EdgeInsets.symmetric(vertical: 16),
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
