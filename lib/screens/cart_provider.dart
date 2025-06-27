import 'package:flutter/material.dart';

class CartItem {
  final String name;
  final double price;
  final String? imageUrl;
  final String? rname;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    this.imageUrl,
    this.rname,
    this.quantity = 1,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'],
      rname: map['rname'],
      quantity: (map['quantity'] is int && map['quantity'] != null) ? map['quantity'] as int : 1,
    );
  }

  // 👇 هذه الدالة تحول الطبق إلى Map
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "price": price,
      "imageUrl": imageUrl ?? "",
      "rname": rname ?? "",
      "quantity": quantity,
    };
  }
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => [..._items];
  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.price * item.quantity);

  void addToCart(String name, double price, [String? imageUrl, String? rname]) {
    final index = _items.indexWhere((item) => item.name == name && item.rname == rname);
    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(name: name, price: price, imageUrl: imageUrl, rname: rname));
    }
    notifyListeners();
  }

  void increaseQuantity(int index) {
    _items[index].quantity++;
    notifyListeners();
  }

  void decreaseQuantity(int index) {
    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }
}

