import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:rawi_go/screens/cart_screen.dart';
import 'package:rawi_go/screens/my_orders_screen.dart';
import 'package:rawi_go/screens/order_details_screen.dart';
import 'package:rawi_go/screens/search_screen.dart';
import 'package:rawi_go/screens/settings_screen.dart';
import '../services/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Get the current user from Firebase Auth
  // This will be used to display user-specific data if needed
  final user = FirebaseAuth.instance.currentUser!;
  // Index for the bottom navigation bar
  int _selectedIndex = 0;
  late Future<List<Map<String, dynamic>>> restaurants;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    restaurants = _firebaseService.getRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        
        backgroundColor: Colors.teal,
        title: const Text('المطاعم'),
        actions: [
          // IconButton for search functionality
          IconButton(
            icon: const Icon(
              Icons.search_rounded,
              size: 32,
              color: Colors.white,
            ),
            tooltip: 'البحث عن طبق',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: restaurants,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("لا يوجد مطاعم حالياً"));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(6.0),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var restaurant = snapshot.data![index];
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.teal, width: 1.6),
                ),
                leading:
                    restaurant['imageUrl'] != null &&
                        restaurant['imageUrl'].isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: restaurant['imageUrl'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      )
                    : const Icon(Icons.restaurant_menu_rounded, size: 60),
                contentPadding: const EdgeInsets.all(5.0),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                title: Text(restaurant['name']),
                subtitle: Text(restaurant['address']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          OrderDetailsScreen(restaurantId: restaurant['id']),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          );
        },
      ),
      bottomNavigationBar: FlashyTabBar(
        selectedIndex: _selectedIndex,
        showElevation: true,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Navigate to the selected page
          switch (index) {
            case 0:
              // Already on HomeScreen, do nothing
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CartScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MyOrdersScreen()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              break;
          }
        },
        items: [
          FlashyTabBarItem(
            icon: Icon(Icons.restaurant_menu_rounded),
            title: Text('المطاعم'),
          ),
          FlashyTabBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            title: Text('السلة'),
          ),
          FlashyTabBarItem(
            icon: Icon(Icons.fastfood_rounded),
            title: Text('طلباتي'),
          ),
          FlashyTabBarItem(
            icon: Icon(Icons.settings_applications_sharp),
            title: Text('الإعدادات'),
          ),
        ],
      ),
    );
  }
}
