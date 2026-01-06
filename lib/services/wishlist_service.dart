import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../utils/constants.dart';

class WishlistService with ChangeNotifier {
  final String? token;
  List<Product> _items = [];
  bool _isLoading = false;

  WishlistService(this.token);

  List<Product> get items => _items;
  bool get isLoading => _isLoading;
  int get itemCount => _items.length;

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // Check if product is in wishlist
  bool isInWishlist(int productId) {
    return _items.any((p) => p.id == productId);
  }

  // Fetch wishlist from server
  Future<void> fetchWishlist() async {
    if (token == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.wishlistEndpoint}',
      );
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> itemsJson = data['data'] ?? data;
        _items = itemsJson.map((item) {
          // Handle if API returns product directly or wrapped
          if (item['product'] != null) {
            return Product.fromJson(item['product']);
          }
          return Product.fromJson(item);
        }).toList();
      }
    } catch (e) {
      debugPrint("Error fetching wishlist: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle wishlist (add/remove)
  Future<void> toggleWishlist(Product product) async {
    final isCurrentlyInWishlist = isInWishlist(product.id);

    // Optimistic update
    if (isCurrentlyInWishlist) {
      _items.removeWhere((p) => p.id == product.id);
    } else {
      _items.add(product);
    }
    notifyListeners();

    if (token == null) return;

    try {
      // Use the correct Laravel API endpoint: POST /wishlist/toggle
      final url = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.wishlistEndpoint}/toggle',
      );
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode({'product_id': product.id}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        // Rollback on error
        if (isCurrentlyInWishlist) {
          _items.add(product);
        } else {
          _items.removeWhere((p) => p.id == product.id);
        }
        notifyListeners();
      }
    } catch (e) {
      // Rollback on error
      if (isCurrentlyInWishlist) {
        _items.add(product);
      } else {
        _items.removeWhere((p) => p.id == product.id);
      }
      notifyListeners();
      debugPrint("Error toggling wishlist: $e");
    }
  }

  // Remove from wishlist
  Future<void> removeFromWishlist(int productId) async {
    final product = _items.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Not found'),
    );

    _items.removeWhere((p) => p.id == productId);
    notifyListeners();

    if (token == null) return;

    try {
      final url = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.wishlistEndpoint}/$productId',
      );
      final response = await http.delete(url, headers: _headers);

      if (response.statusCode != 200) {
        // Rollback on error
        _items.add(product);
        notifyListeners();
      }
    } catch (e) {
      // Rollback on error
      _items.add(product);
      notifyListeners();
      debugPrint("Error removing from wishlist: $e");
    }
  }

  // Clear wishlist
  void clearWishlist() {
    _items.clear();
    notifyListeners();
  }
}
