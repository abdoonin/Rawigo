import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:rawi_go/screens/admin_orders_screen.dart';
import 'package:rawi_go/screens/cart_screen.dart';
import 'package:rawi_go/screens/home_screen.dart';
import 'package:rawi_go/screens/login_screen.dart';
import 'package:rawi_go/screens/my_orders_screen.dart';
import 'package:rawi_go/screens/profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final user = FirebaseAuth.instance.currentUser!;

Future<void> _logout(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut(); // تسجيل الخروج
    // await FirebaseAuth.instance.setPersistence(Persistence.NONE); // تعطيل الاستمرارية
    // await FirebaseAuth.instance.clearPersistence(); // مسح الجلسة القديمة

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم تسجيل الخروج بنجاح")),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  } catch (e) {
    print("Error during logout: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("حدث خطأ أثناء تسجيل الخروج")),
    );
  }
}

  // Index for the bottom navigation bar
  int _selectedIndex = 3;

  void _onTabSelected(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);

    Widget? destination;
    switch (index) {
      case 0:
        destination = const HomeScreen();
        break;
      case 1:
        destination = const CartScreen();
        break;
      case 2:
        destination = MyOrdersScreen();
        break;
      case 3:
        return; // Already on SettingsScreen
    }
    if (destination != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destination!),
      );
    }
  }

  List<Widget> get _settingsOptions => [
    _buildListTile(
      icon: Icons.person,
      color: Colors.teal,
      title: "الملف الشخصي",
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      },
    ),
    const Divider(),
    _buildListTile(
      icon: Icons.add_location_alt_rounded,
      color: Colors.teal,
      title: "العنوان",
      onTap: () {
        // Implement address settings functionality here
        // عرض حوار لتعديل العنوان
        //بعدين اربط تعديل العنوان بصفحة الشخصية
        final TextEditingController addressController = TextEditingController(
          text: "",
        );
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("العنوان"),
            content: TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "تعديل عنوانك",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              textDirection: TextDirection.rtl,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // يمكنك هنا حفظ العنوان الجديد إذا أردت
                  Navigator.of(context).pop();
                },
                child: const Text("حفظ"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("إغلاق"),
              ),
            ],
          ),
        );
      },
    ),
    const Divider(),
    _buildListTile(
      icon: Icons.notifications,
      color: Colors.teal,
      title: "الإشعارات",
      onTap: () {
        // Implement notification settings functionality here
        bool isNotificationEnabled = true;
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: const Text("الإشعارات"),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("تفعيل الإشعارات"),
                    Switch(
                      value: isNotificationEnabled,
                      onChanged: (value) {
                        setState(() {
                          isNotificationEnabled = value;
                        });
                      },
                      activeColor: Colors.teal,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("إغلاق"),
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
    const Divider(),

    _buildListTile(
      icon: Icons.assignment_ind_outlined,
      color: Colors.teal,
      title: 'ادارة الطلبات',
      onTap: () {
        // Implement admin settings functionality here
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminOrdersScreen()),
        );
      },
    ),
    const Divider(),
    Text(
      user.email!,
      style: const TextStyle(fontSize: 16, color: Colors.black54),
      textAlign: TextAlign.center,
    ),

    _buildListTile(
      icon: Icons.logout,
      color: Colors.red,
      title: "تسجيل الخروج",
      onTap: () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
        title: const Text("تأكيد تسجيل الخروج"),
        content: const Text("هل أنت متأكد أنك تريد تسجيل الخروج؟"),
        actions: [
          TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("إلغاء"),
          ),
          TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog first
            _logout(context);
          },
          child: const Text("تسجيل الخروج"),
          ),
        ],
        ),
      );
      },
      trailing: null,
    ),
  ];

  static List<FlashyTabBarItem> get _tabBarItems => [
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
  ];

  static ListTile _buildListTile({
    required IconData icon,
    required Color color,
    required String title,
    VoidCallback? onTap,
    Widget? trailing = const Icon(Icons.arrow_forward_ios_rounded),
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الإعدادات"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: _settingsOptions,
      ),
      bottomNavigationBar: FlashyTabBar(
        selectedIndex: _selectedIndex,
        showElevation: true,
        onItemSelected: _onTabSelected,
        items: _tabBarItems,
      ),
    );
  }
}
