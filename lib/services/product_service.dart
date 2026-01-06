import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../utils/constants.dart';

class ProductService {
  final String? token;

  ProductService(this.token);

  Future<List<Product>> getProducts({String? query, String? categoryId, double? minPrice, double? maxPrice}) async {
    // Build query string
    Map<String, String> queryParams = {};
    if (query != null) queryParams['search'] = query;
    if (categoryId != null) queryParams['category_id'] = categoryId;
    if (minPrice != null) queryParams['min_price'] = minPrice.toString();
    if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();

    final uri = Uri.parse('${AppConstants.baseUrl}/products').replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Assuming Laravel returns { data: [...] } or just [...]
        // Adjust based on actual API response structure (usually pagination or wrapper)
        final List<dynamic> productsJson = data['data'] ?? data; 
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Product> getProductById(int id) async {
    final url = Uri.parse('${AppConstants.baseUrl}/products/$id');
    try {
      final response = await http.get(url, headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Product.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Failed to load product');
      }
    } catch (e) {
      rethrow;
    }
  }
}
