import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rawi_go/screens/cart_provider.dart';
import '../services/firebase_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FirebaseService _service = FirebaseService();
  late Future<List<Map<String, dynamic>>> _allItemsFuture;
  List<Map<String, dynamic>> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _allItemsFuture = _service.getAllItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _filterItems(query);
    });
  }

  // قائمة لتخزين الأطباق المختارة

  void _addToCartAndFirebase(BuildContext context, Map<String, dynamic> item) {
    var cart = Provider.of<CartProvider>(context, listen: false);

    cart.addToCart(
      item['name'],
      item['price'].toDouble(),
      item['imageUrl'], // إذا كانت لديك صورة
      item['rname'],
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("${item['name']} تمت الإضافة")));
  }

  Future<void> _filterItems(String query) async {
    if (query.isEmpty) {
      setState(() => _filteredItems = []);
      return;
    }
    setState(() => _isLoading = true);
    final items = await _allItemsFuture;
    setState(() {
      _filteredItems = items
          .where(
            (item) => (item['name'] as String).toLowerCase().contains(
              query.toLowerCase(),
            ),
          )
          .toList();
      _isLoading = false;
    });
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: "ابحث عن طبق...",
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onChanged: _onSearchChanged,
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_searchController.text.isNotEmpty && _filteredItems.isEmpty) {
      return const Center(child: Text("لا توجد نتائج مطابقة"));
    }
    if (_filteredItems.isEmpty) {
      return const Center(child: Text("اكتب اسم طبق للبحث"));
    }
    return ListView.builder(
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 30,
            // إذا كانت لديك صورة، استخدمها
            // وإلا استخدم صورة افتراضية
            backgroundImage: item['imageUrl'] != null
                ? NetworkImage(item['imageUrl'])
                : null,
          ),
          title: Text(item['name']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${item['price']} دينار"),
              Text(
                "مطعم: ${item['rname']}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.green),
            onPressed: () => _addToCartAndFirebase(context, item),
          ),
          onTap: () {
            // Navigate to details if needed
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("البحث عن أطباق")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _allItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("حدث خطأ أثناء تحميل البيانات"));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSearchField(),
                const SizedBox(height: 20),
                Expanded(child: _buildList()),
              ],
            ),
          );
        },
      ),
    );
  }
}
