import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import '../utils/constants.dart';

class OrderService {
  final String? token;
  OrderService(this.token);

  Future<List<Order>> getOrders() async {
    if (token == null) return [];
    final url = Uri.parse('${AppConstants.baseUrl}/orders');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> ordersJson = data['data'] ?? data;
        return ordersJson.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createOrder(Map<String, dynamic> orderData) async {
     final url = Uri.parse('${AppConstants.baseUrl}/checkout');
     try {
       final response = await http.post(
         url,
         body: json.encode(orderData),
         headers: {
           'Authorization': 'Bearer $token',
           'Content-Type': 'application/json',
           'Accept': 'application/json',
         }
       );
       if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception(json.decode(response.body)['message'] ?? 'Checkout failed');
       }
     } catch (e) {
       rethrow;
     }
  }
}
