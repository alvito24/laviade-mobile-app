import 'product_model.dart';

class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double price;
  final String? size;
  final String? color;
  final Product? product;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
    this.size,
    this.color,
    this.product,
  });

  double get totalPrice => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    Product? product;
    if (json['product'] != null) {
      product = Product.fromJson(json['product']);
    }

    return OrderItem(
      id: json['id'],
      productId: json['product_id'] ?? product?.id ?? 0,
      productName: json['product_name'] ?? product?.name ?? '',
      productImage: json['product_image'] ?? product?.primaryImageUrl,
      quantity: json['quantity'] ?? 1,
      price: _parseDouble(json['price']),
      size: json['size'],
      color: json['color'],
      product: product,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class ShippingAddress {
  final String recipientName;
  final String phone;
  final String province;
  final String city;
  final String district;
  final String postalCode;
  final String addressDetail;

  ShippingAddress({
    required this.recipientName,
    required this.phone,
    required this.province,
    required this.city,
    required this.district,
    required this.postalCode,
    required this.addressDetail,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      recipientName: json['recipient_name'] ?? '',
      phone: json['phone'] ?? '',
      province: json['province'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      postalCode: json['postal_code'] ?? '',
      addressDetail: json['address_detail'] ?? '',
    );
  }

  String get fullAddress =>
      '$addressDetail, $district, $city, $province $postalCode';
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
  final String? paymentStatus;
  final String? notes;
  final ShippingAddress? shippingAddress;
  final DateTime createdAt;
  final DateTime? paidAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
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
    this.paymentStatus,
    this.notes,
    this.shippingAddress,
    required this.createdAt,
    this.paidAt,
    this.shippedAt,
    this.deliveredAt,
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

    // Parse shipping address
    ShippingAddress? parseAddress(dynamic addressData) {
      if (addressData == null) return null;
      if (addressData is Map<String, dynamic>) {
        return ShippingAddress.fromJson(addressData);
      }
      return null;
    }

    return Order(
      id: json['id'],
      orderNumber: json['order_number'] ?? '',
      status: json['status'] ?? 'pending',
      subtotal: _parseDouble(json['subtotal']),
      shippingCost: _parseDouble(json['shipping_cost']),
      totalAmount: _parseDouble(json['total_amount']),
      shippingMethod: json['shipping_method'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      notes: json['notes'],
      shippingAddress: parseAddress(json['shipping_address']),
      createdAt: DateTime.parse(json['created_at']),
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'])
          : null,
      shippedAt: json['shipped_at'] != null
          ? DateTime.tryParse(json['shipped_at'])
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse(json['delivered_at'])
          : null,
      items: parseItems(json['items']),
    );
  }

  // Get status display text
  String get statusDisplay {
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

  // Get status color
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'orange';
      case 'processing':
        return 'blue';
      case 'shipped':
        return 'purple';
      case 'delivered':
        return 'green';
      case 'cancelled':
        return 'red';
      default:
        return 'grey';
    }
  }

  // Check if order can be cancelled
  bool get canCancel => status.toLowerCase() == 'pending';

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
