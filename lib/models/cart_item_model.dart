import 'product_model.dart';

class CartItem {
  final int id;
  final Product product;
  int quantity;
  final String? size;
  final String? color;
  bool isSelected;
  final double priceAtTime; // Price when added to cart

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    this.size,
    this.color,
    this.isSelected = true,
    double? priceAtTime,
  }) : priceAtTime = priceAtTime ?? product.currentPrice;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Handle nested product data from Laravel API
    Product product;
    if (json['product'] != null) {
      product = Product.fromJson(json['product']);
    } else {
      // If product is flattened in the response
      product = Product(
        id: json['product_id'] ?? 0,
        name: json['product_name'] ?? '',
        slug: json['product_slug'] ?? '',
        description: '',
        price: _parseDouble(json['product_price'] ?? json['price']),
        primaryImageUrl: json['product_image'] ?? json['image_url'],
      );
    }

    return CartItem(
      id: json['id'],
      product: product,
      quantity: json['quantity'] ?? 1,
      size: json['size'],
      color: json['color'],
      isSelected: json['is_selected'] ?? true,
      priceAtTime: _parseDouble(
        json['price'] ?? json['price_at_time'] ?? product.currentPrice,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': product.id,
      'quantity': quantity,
      'size': size,
      'color': color,
      'is_selected': isSelected,
    };
  }

  // Calculate total price for this item
  double get totalPrice => priceAtTime * quantity;

  // Get display variant text
  String get variantText {
    List<String> parts = [];
    if (size != null && size!.isNotEmpty) parts.add('Size: $size');
    if (color != null && color!.isNotEmpty) parts.add('Color: $color');
    return parts.join(' | ');
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
