import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../utils/constants.dart';

class ProductService {
  final String? token;

  ProductService(this.token);

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<List<Product>> getProducts({
    String? query,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    String? sort,
    int? perPage,
  }) async {
    Map<String, String> queryParams = {};
    if (query != null && query.isNotEmpty) queryParams['search'] = query;
    if (categoryId != null) queryParams['category_id'] = categoryId;
    if (minPrice != null) queryParams['min_price'] = minPrice.toString();
    if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
    if (sort != null) queryParams['sort'] = sort;
    if (perPage != null) queryParams['per_page'] = perPage.toString();

    final uri = Uri.parse(
      '${AppConstants.baseUrl}/products',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    try {
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Laravel pagination returns { data: [...], ... } or { success: true, data: { data: [...] } }
        final dynamic productsData = data['data'];

        // Handle paginated response
        List<dynamic> productsJson;
        if (productsData is List) {
          productsJson = productsData;
        } else if (productsData is Map && productsData['data'] != null) {
          productsJson = productsData['data'];
        } else {
          productsJson = [];
        }

        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Product> getProductBySlug(String slug) async {
    final url = Uri.parse('${AppConstants.baseUrl}/products/$slug');
    try {
      final response = await http.get(url, headers: _headers);
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

  Future<List<Product>> getNewArrivals({int limit = 8}) async {
    final url = Uri.parse('${AppConstants.baseUrl}/products/new-arrivals');
    try {
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productsJson = data['data'] ?? [];
        return productsJson.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Product>> getBestSellers({int limit = 8}) async {
    final url = Uri.parse('${AppConstants.baseUrl}/products/best-sellers');
    try {
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productsJson = data['data'] ?? [];
        return productsJson.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Product>> searchProducts(String query, {int limit = 10}) async {
    if (query.length < 2) return [];

    final url = Uri.parse(
      '${AppConstants.baseUrl}/products/search',
    ).replace(queryParameters: {'q': query});
    try {
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productsJson = data['data'] ?? [];
        return productsJson.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
