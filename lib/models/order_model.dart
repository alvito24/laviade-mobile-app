import 'product_model.dart';

class OrderItem {
  final int id;
  final Product product;
  final int quantity;
  final double price;
  final String size;

  OrderItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
    required this.size,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      price: double.parse(json['price'].toString()),
      size: json['size'],
    );
  }
}

class Order {
  final int id;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      status: json['status'],
      totalAmount: double.parse(json['total_amount'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      items: (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList(),
    );
  }
}
