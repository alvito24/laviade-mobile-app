import 'product_model.dart';

class CartItem {
  final int id;
  final Product product;
  int quantity;
  final String size;
  bool isSelected;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.size,
    this.isSelected = true,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      size: json['size'],
    );
  }
  
  double get totalPrice => product.price * quantity;
}
