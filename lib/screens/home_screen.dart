import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:rawi_go/screens/cart_screen.dart';
import 'package:rawi_go/screens/my_orders_screen.dart';
import 'package:rawi_go/screens/order_details_screen.dart';
import 'package:rawi_go/screens/search_screen.dart';
import 'package:rawi_go/screens/settings_screen.dart';
import 'package:rawi_go/widgets/dummy_data.dart';
import '../services/firebase_service.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Get the current user from Firebase Auth
  final user = FirebaseAuth.instance.currentUser!;
  int _selectedIndex = 0;
  late Future<List<Map<String, dynamic>>> restaurants;
  final FirebaseService _firebaseService = FirebaseService();

  // بيانات العروض الثابتة
  final List<Map<String, dynamic>> offers = dummyOffers;

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
          IconButton(
            icon: const Icon(Icons.search_rounded, size: 32, color: Colors.white),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            // قسم العروض الأفقية
            SizedBox(
              height: 180, // ارتفاع البطاقات الأفقية
              child: ListView.builder(
                scrollDirection: Axis.horizontal, // عرض البطاقات بشكل أفقي
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  var offer = offers[index];
                  return GestureDetector(
                    onTap: () {
                      // يمكنك إضافة وظيفة عند الضغط على البطاقة
                      
                    },
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),side: const BorderSide(color: Colors.teal, width: 1.6)),
                      child: Container(
                        width: 250, // عرض البطاقة
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(offer['imageUrl']),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 10,
                              left: 10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    textDirection: TextDirection.rtl,
                                    offer['restaurantName'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 4)],
                                    ),
                                  ),
                                  Text(
                                    textDirection: TextDirection.rtl,
                                    offer['description'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      shadows: [Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 4)],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // قائمة المطاعم
            FutureBuilder<List<Map<String, dynamic>>>(
              future: restaurants,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("لا يوجد مطاعم حالياً"));
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(6.0),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var restaurant = snapshot.data![index];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.teal, width: 1.6),
                      ),
                      leading: restaurant['imageUrl'] != null && restaurant['imageUrl'].isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                              imageUrl: restaurant['imageUrl'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                              errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 60),
                              ),
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
                            builder: (_) => OrderDetailsScreen(restaurantId: restaurant['id']),
                          ),
                        );
                      },
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: FlashyTabBar(
        selectedIndex: _selectedIndex,
        showElevation: true,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (_) => CartScreen()));
              break;
            case 2:
              Navigator.push(context, MaterialPageRoute(builder: (_) => MyOrdersScreen()));
              break;
            case 3:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              break;
          }
        },
        items: [
          FlashyTabBarItem(icon: const Icon(Icons.restaurant_menu_rounded), title: const Text('المطاعم')),
          FlashyTabBarItem(icon: const Icon(Icons.shopping_cart_outlined), title: const Text('السلة')),
          FlashyTabBarItem(icon: const Icon(Icons.fastfood_rounded), title: const Text('طلباتي')),
          FlashyTabBarItem(icon: const Icon(Icons.settings_applications_sharp), title: const Text('الإعدادات')),
        ],
      ),
    );
  }
}