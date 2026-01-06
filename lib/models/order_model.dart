import 'product_model.dart';

class OrderItem {
  final int id;
  final Product? product;
  final int productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double price;
  final String? size;
  final String? color;

  OrderItem({
    required this.id,
    this.product,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
    this.size,
    this.color,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      product: json['product'] != null
          ? Product.fromJson(json['product'])
          : null,
      productId: json['product_id'] ?? 0,
      productName:
          json['product_name'] ?? json['product']?['name'] ?? 'Unknown',
      productImage:
          json['product_image'] ??
          json['product']?['primary_image']?['image_path'],
      quantity: json['quantity'] ?? 1,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      size: json['size'],
      color: json['color'],
    );
  }

  double get totalPrice => price * quantity;
}

class ShippingAddress {
  final String recipientName;
  final String phone;
  final String fullAddress;
  final String? province;
  final String? city;
  final String? district;
  final String? postalCode;

  ShippingAddress({
    required this.recipientName,
    required this.phone,
    required this.fullAddress,
    this.province,
    this.city,
    this.district,
    this.postalCode,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      recipientName: json['recipient_name'] ?? '',
      phone: json['phone'] ?? '',
      fullAddress: json['full_address'] ?? json['address_detail'] ?? '',
      province: json['province'],
      city: json['city'],
      district: json['district'],
      postalCode: json['postal_code'],
    );
  }
}

class Order {
  final int id;
  final String orderNumber;
  final String status;
  final double subtotal;
  final double shippingCost;
  final double totalAmount;
  final String? shippingMethod;
  final String? paymentMethod;
  final String? paymentChannel;
  final String? paymentStatus;
  final String? notes;
  final ShippingAddress? shippingAddress;
  final DateTime createdAt;
  final DateTime? paidAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.subtotal,
    required this.shippingCost,
    required this.totalAmount,
    this.shippingMethod,
    this.paymentMethod,
    this.paymentChannel,
    this.paymentStatus,
    this.notes,
    this.shippingAddress,
    required this.createdAt,
    this.paidAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Parse items
    List<OrderItem> parseItems(dynamic itemsData) {
      if (itemsData == null) return [];
      if (itemsData is List) {
        return itemsData.map((i) => OrderItem.fromJson(i)).toList();
      }
      return [];
    }

    return Order(
      id: json['id'],
      orderNumber: json['order_number'] ?? 'N/A',
      status: json['status'] ?? 'pending',
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      shippingCost:
          double.tryParse(json['shipping_cost']?.toString() ?? '0') ?? 0,
      totalAmount:
          double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      shippingMethod: json['shipping_method'],
      paymentMethod: json['payment_method'],
      paymentChannel: json['payment_channel'],
      paymentStatus: json['payment_status'],
      notes: json['notes'],
      shippingAddress: json['shipping_address'] != null
          ? ShippingAddress.fromJson(json['shipping_address'])
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'])
          : null,
      items: parseItems(json['items']),
    );
  }

  // Helper getters
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'processing':
        return 'Diproses';
      case 'shipped':
        return 'Dikirim';
      case 'delivered':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  bool get canCancel => status.toLowerCase() == 'pending';
}
