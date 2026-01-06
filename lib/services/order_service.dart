import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import '../utils/constants.dart';

class OrderService {
  final String? token;

  OrderService(this.token);

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // Get all user orders
  Future<List<Order>> getOrders() async {
    if (token == null) return [];

    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.ordersEndpoint}',
    );
    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle Laravel pagination or direct data
        List<dynamic> ordersJson;
        if (data['data'] is List) {
          ordersJson = data['data'];
        } else if (data['data']?['data'] is List) {
          ordersJson = data['data']['data'];
        } else {
          ordersJson = [];
        }

        return ordersJson.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching orders: $e");
      rethrow;
    }
  }

  // Get order detail by order number
  Future<Order> getOrderDetail(String orderNumber) async {
    if (token == null) throw Exception('Tidak terautentikasi');

    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.ordersEndpoint}/$orderNumber',
    );
    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Order.fromJson(data['data'] ?? data);
      } else if (response.statusCode == 404) {
        throw Exception('Pesanan tidak ditemukan');
      } else {
        throw Exception('Gagal memuat detail pesanan');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Create new order (checkout)
  Future<Order> createOrder({
    required int addressId,
    required String shippingMethod,
    required String paymentMethod,
    double? shippingCost,
    String? paymentChannel,
    String? notes,
  }) async {
    if (token == null) throw Exception('Tidak terautentikasi');

    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.checkoutEndpoint}',
    );
    try {
      final body = {
        'address_id': addressId,
        'shipping_method': shippingMethod,
        'payment_method': paymentMethod,
        if (shippingCost != null) 'shipping_cost': shippingCost,
        if (paymentChannel != null) 'payment_channel': paymentChannel,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      final response = await http.post(
        url,
        body: json.encode(body),
        headers: _headers,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Order.fromJson(responseData['data'] ?? responseData);
      } else {
        throw Exception(responseData['message'] ?? 'Checkout gagal');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderNumber) async {
    if (token == null) throw Exception('Tidak terautentikasi');

    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.ordersEndpoint}/$orderNumber/cancel',
    );
    try {
      final response = await http.post(url, headers: _headers);

      final responseData = json.decode(response.body);

      if (response.statusCode != 200) {
        throw Exception(responseData['message'] ?? 'Gagal membatalkan pesanan');
      }
    } catch (e) {
      rethrow;
    }
  }
}
