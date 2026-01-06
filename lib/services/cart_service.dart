import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../utils/constants.dart';

class CartService with ChangeNotifier {
  List<CartItem> _items = [];
  final String? token;
  bool _isLoading = false;

  CartService(this.token, this._items);

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;

  // Get selected items only
  List<CartItem> get selectedItems =>
      _items.where((item) => item.isSelected).toList();

  // Total amount for selected items
  double get totalAmount {
    return selectedItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Total amount for all items
  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get itemCount => _items.length;
  int get selectedCount => selectedItems.length;

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // Fetch cart from server
  Future<void> fetchCart() async {
    if (token == null) return;

    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.cartEndpoint}',
    );
    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Laravel API returns: { success: true, data: { cart: {...}, items: [...] } }
        final responseData = data['data'] ?? data;

        List<dynamic> itemsJson;
        if (responseData['items'] != null) {
          itemsJson = responseData['items'];
        } else if (responseData is List) {
          itemsJson = responseData;
        } else {
          itemsJson = [];
        }

        _items = itemsJson.map((item) => CartItem.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching cart: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add item to cart
  Future<void> addToCart(
    Product product,
    int quantity, {
    String? size,
    String? color,
  }) async {
    // Optimistic update - add locally first
    final existingIndex = _items.indexWhere(
      (i) => i.product.id == product.id && i.size == size && i.color == color,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
          product: product,
          quantity: quantity,
          size: size,
          color: color,
        ),
      );
    }
    notifyListeners();

    if (token == null) return;

    // Sync with server
    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.cartEndpoint}',
    );
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'product_id': product.id,
          'quantity': quantity,
          'size': size,
          'color': color,
        }),
        headers: _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh cart to get real IDs from server
        await fetchCart();
      }
    } catch (e) {
      debugPrint("Add to cart failed: $e");
      // Could rollback here if needed
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(int id) async {
    final removedItem = _items.firstWhere(
      (item) => item.id == id,
      orElse: () => throw Exception('Item not found'),
    );
    _items.removeWhere((item) => item.id == id);
    notifyListeners();

    if (token == null) return;

    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.cartEndpoint}/$id',
    );
    try {
      final response = await http.delete(url, headers: _headers);

      if (response.statusCode != 200) {
        // Rollback if failed
        _items.add(removedItem);
        notifyListeners();
      }
    } catch (e) {
      // Rollback on error
      _items.add(removedItem);
      notifyListeners();
      debugPrint("Delete cart failed: $e");
    }
  }

  // Update item quantity
  Future<void> updateQuantity(int id, int quantity) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) return;

    final oldQuantity = _items[index].quantity;
    _items[index].quantity = quantity;
    notifyListeners();

    if (token == null) return;

    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.cartEndpoint}/$id',
    );
    try {
      final response = await http.put(
        url,
        body: json.encode({'quantity': quantity}),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        // Rollback if failed
        _items[index].quantity = oldQuantity;
        notifyListeners();
      }
    } catch (e) {
      // Rollback on error
      _items[index].quantity = oldQuantity;
      notifyListeners();
      debugPrint("Update cart failed: $e");
    }
  }

  // Toggle item selection (local only, or sync if API supports it)
  void toggleSelection(int id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index].isSelected = !_items[index].isSelected;
      notifyListeners();

      // Optionally sync with server
      if (token != null) {
        _syncSelection(id);
      }
    }
  }

  // Sync selection with server
  Future<void> _syncSelection(int id) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.cartEndpoint}/$id/toggle',
    );
    try {
      await http.post(url, headers: _headers);
    } catch (e) {
      debugPrint("Toggle selection failed: $e");
    }
  }

  // Select all items
  void selectAll() {
    for (var item in _items) {
      item.isSelected = true;
    }
    notifyListeners();
  }

  // Deselect all items
  void deselectAll() {
    for (var item in _items) {
      item.isSelected = false;
    }
    notifyListeners();
  }

  // Clear cart (after checkout)
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Clear selected items only
  void clearSelectedItems() {
    _items.removeWhere((item) => item.isSelected);
    notifyListeners();
  }
}
