import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../utils/constants.dart';

class CartService with ChangeNotifier {
  List<CartItem> _items = [];
  final String? token; // In real app, cart syncs with server.
  // If basic, token needed.

  CartService(this.token, this._items);

  List<CartItem> get items => _items;

  double get totalAmount {
    var total = 0.0;
    for (var item in _items) {
      if (item.isSelected) {
        total += item.totalPrice;
      }
    }
    return total;
  }

  int get itemCount => _items.length;

  Future<void> fetchCart() async {
    if (token == null) return;
    final url = Uri.parse('${AppConstants.baseUrl}/cart');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> cartJson = data['data'] ?? data;
        _items = cartJson.map((item) => CartItem.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      // Silent fail or rethrow
      print("Error fetching cart: $e");
    }
  }

  Future<void> addToCart(
    Product product,
    int quantity,
    String? size, {
    String? color,
  }) async {
    // Optimistic update
    // Check if exists with same size and color
    final index = _items.indexWhere(
      (i) => i.product.id == product.id && i.size == size && i.color == color,
    );
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      // Temp ID, will be refreshed
      _items.add(
        CartItem(
          id: DateTime.now().millisecondsSinceEpoch,
          product: product,
          quantity: quantity,
          size: size,
          color: color,
        ),
      );
    }
    notifyListeners();

    if (token == null) return;

    // Sync API
    final url = Uri.parse('${AppConstants.baseUrl}/cart');
    try {
      await http.post(
        url,
        body: json.encode({
          'product_id': product.id,
          'quantity': quantity,
          'size': size,
          'color': color,
        }),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      await fetchCart(); // Refresh to get real IDs
    } catch (e) {
      // Rollback managed by refetching usually
      print("Add to cart failed: $e");
    }
  }

  Future<void> removeFromCart(int id) async {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();

    if (token == null) return;
    final url = Uri.parse('${AppConstants.baseUrl}/cart/$id');
    try {
      await http.delete(url, headers: {'Authorization': 'Bearer $token'});
    } catch (e) {
      print("Delete cart failed: $e");
    }
  }

  Future<void> updateQuantity(int id, int quantity) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();

      if (token == null) return;
      final url = Uri.parse('${AppConstants.baseUrl}/cart/$id');
      try {
        await http.put(
          url,
          body: json.encode({'quantity': quantity}),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      } catch (e) {
        print("Update cart failed: $e");
      }
    }
  }

  void toggleSelection(int id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index].isSelected = !_items[index].isSelected;
      notifyListeners();
    }
  }
}
