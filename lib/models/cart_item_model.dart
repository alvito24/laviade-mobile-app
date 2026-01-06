import 'product_model.dart';

class CartItem {
  final int id;
  final Product product;
  int quantity;
  final String? size;
  final String? color;
  bool isSelected;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    this.size,
    this.color,
    this.isSelected = true,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Handle nested product data from Laravel API
    // The API returns cart item with product relationship loaded
    final productData = json['product'];

    return CartItem(
      id: json['id'],
      product: productData != null
          ? Product.fromJson(productData)
          : Product(
              id: json['product_id'] ?? 0,
              name: 'Unknown Product',
              slug: 'unknown',
              description: '',
              price: 0,
            ),
      quantity: json['quantity'] ?? 1,
      size: json['size'],
      color: json['color'],
      isSelected: json['is_selected'] == 1 || json['is_selected'] == true,
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

  double get totalPrice => product.currentPrice * quantity;

  // Copy with method for immutability
  CartItem copyWith({
    int? id,
    Product? product,
    int? quantity,
    String? size,
    String? color,
    bool? isSelected,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      color: color ?? this.color,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
