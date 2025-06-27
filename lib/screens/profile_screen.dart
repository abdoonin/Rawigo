import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:rawi_go/screens/cart_screen.dart';
import 'package:rawi_go/screens/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 2;

  void _onTabSelected(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);

    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CartScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        break;
      // case 0 and 2: do nothing (already on screen)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الملف الشخصي"),
        centerTitle: true,
      ),
      body: Center(
        child: _ProfileCard(),
      ),
      bottomNavigationBar: FlashyTabBar(
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
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(
                Icons.person_2_rounded,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              " عطؤمة",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "البريد الإلكتروني: example@email.com",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Add edit profile functionality here
              },
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text(
                "تعديل الملف الشخصي",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.location_on, color: Colors.teal),
                SizedBox(width: 8),
                Text(
                  "العنوان: الانبار, راوه ",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}