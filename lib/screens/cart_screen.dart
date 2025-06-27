import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rawi_go/screens/cart_provider.dart';
import 'package:rawi_go/screens/home_screen.dart';
import 'package:rawi_go/screens/my_orders_screen.dart';
import 'package:rawi_go/screens/settings_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _selectedIndex = 1;

  void _onTabSelected(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);

    Widget? destination;
    switch (index) {
      case 0:
        destination = const HomeScreen();
        break;
      case 2:
        destination = MyOrdersScreen();
        break;
      case 3:
        destination = const SettingsScreen();
        break;
      default:
        return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination!),
    );
  }

  Future<void> _submitOrder(CartProvider cart) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown";
    bool success = await addOrderToFirebase(
      userId: userId,
      items: cart.items.map((item) => item.toMap()).toList(),
      totalPrice: cart.totalPrice,
      status: "pending",
      timestamp: FieldValue.serverTimestamp(),
    );
    if (success) {
      cart.clearCart();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("تم إرسال الطلب بنجاح")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("فشل في إرسال الطلب")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("السلة"), elevation: 0),
      body: cart.items.isEmpty
          ? _buildEmptyCartBody(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      var item = cart.items[index];

                      return ListTile(
                        contentPadding: const EdgeInsets.all(8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Colors.teal,
                            width: 1.5,
                          ),
                        ),
                        tileColor: Colors.teal.withOpacity(0.13),
                        leading: item.imageUrl != null && item.imageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: item.imageUrl!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.image, size: 60),
                        title: Text(item.name),
                        subtitle: Text("${item.price} دينار"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => cart.decreaseQuantity(index),
                            ),
                            Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => cart.increaseQuantity(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => cart.removeItem(index),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 8.0);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "المجموع: ${cart.totalPrice.toStringAsFixed(2)} دينار",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _submitOrder(cart),
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text("اطلب الآن"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildEmptyCartBody(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart, size: 80, color: Colors.black87),
          const SizedBox(height: 20),
          const Text(
            "سلتك فارغة!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "ابدأ بإضافة الطلبات إلى السلة الآن.",
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.storefront,
                  size: 24,
                  color: Colors.white,
                ),
                label: const Text(
                  "اطلب الآن",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return FlashyTabBar(
      selectedIndex: _selectedIndex,
      showElevation: true,
      onItemSelected: _onTabSelected,
      items: [
        FlashyTabBarItem(
          icon: const Icon(Icons.restaurant_menu_rounded),
          title: const Text('المطاعم'),
        ),
        FlashyTabBarItem(
          icon: const Icon(Icons.shopping_cart_outlined),
          title: const Text('السلة'),
        ),
        FlashyTabBarItem(
          icon: const Icon(Icons.fastfood_rounded),
          title: const Text('طلباتي'),
        ),
        FlashyTabBarItem(
          icon: const Icon(Icons.settings_applications_sharp),
          title: const Text('الاعدادات'),
        ),
      ],
    );
  }
}

Future<bool> addOrderToFirebase({
  required String userId,
  required List<Map<String, dynamic>> items,
  required double totalPrice,
  String status = 'pending',
  FieldValue? timestamp,
}) async {
  try {
    await FirebaseFirestore.instance.collection('orders').add({
      'userId': userId,
      'items': items,
      'totalPrice': totalPrice,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
    return true;
  } catch (e) {
    return false;
  }
}
