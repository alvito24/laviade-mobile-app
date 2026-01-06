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

  // Get products with filters and pagination
  Future<ProductResponse> getProducts({
    String? search,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String? sort,
    int page = 1,
    int perPage = 12,
  }) async {
    Map<String, String> queryParams = {
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (categoryId != null) queryParams['category_id'] = categoryId.toString();
    if (minPrice != null) queryParams['min_price'] = minPrice.toString();
    if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
    if (sort != null) queryParams['sort'] = sort;

    final uri = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.productsEndpoint}',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ProductResponse.fromJson(data);
      } else {
        throw Exception('Gagal memuat produk');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get product by slug (not ID)
  Future<Product> getProductBySlug(String slug) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.productsEndpoint}/$slug',
    );
    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Product.fromJson(data['data'] ?? data);
      } else if (response.statusCode == 404) {
        throw Exception('Produk tidak ditemukan');
      } else {
        throw Exception('Gagal memuat produk');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Search products
  Future<List<Product>> searchProducts(String query, {int limit = 10}) async {
    if (query.length < 2) return [];

    final uri = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.productsEndpoint}/search',
    ).replace(queryParameters: {'q': query});

    try {
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productsJson = data['data'] ?? data;
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Get new arrivals
  Future<List<Product>> getNewArrivals({int limit = 8}) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.productsEndpoint}/new-arrivals',
    );
    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productsJson = data['data'] ?? data;
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Get best sellers
  Future<List<Product>> getBestSellers({int limit = 8}) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.productsEndpoint}/best-sellers',
    );
    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productsJson = data['data'] ?? data;
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}

// Response class for paginated products
class ProductResponse {
  final List<Product> products;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasMorePages;

  ProductResponse({
    required this.products,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.hasMorePages = false,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    // Handle Laravel pagination structure
    List<Product> products = [];
    int currentPage = 1;
    int lastPage = 1;
    int total = 0;

    // Check if it's paginated response (has 'data' as list inside)
    if (json['data'] != null) {
      if (json['data'] is List) {
        // Paginated: { data: [...], current_page: 1, last_page: 3, ... }
        products = (json['data'] as List)
            .map((item) => Product.fromJson(item))
            .toList();
        currentPage = json['current_page'] ?? 1;
        lastPage = json['last_page'] ?? 1;
        total = json['total'] ?? products.length;
      } else if (json['data']['data'] != null) {
        // Wrapped: { success: true, data: { data: [...], current_page: 1 } }
        final innerData = json['data'];
        products = (innerData['data'] as List)
            .map((item) => Product.fromJson(item))
            .toList();
        currentPage = innerData['current_page'] ?? 1;
        lastPage = innerData['last_page'] ?? 1;
        total = innerData['total'] ?? products.length;
      }
    } else if (json['products'] != null) {
      // Alternative format: { products: [...] }
      products = (json['products'] as List)
          .map((item) => Product.fromJson(item))
          .toList();
    }

    return ProductResponse(
      products: products,
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
      hasMorePages: currentPage < lastPage,
    );
  }
}
