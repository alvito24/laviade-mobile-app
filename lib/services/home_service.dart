import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../utils/constants.dart';

class HomeService {
  final String? token;

  HomeService(this.token);

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // Get Banners
  Future<List<AppBanner>> getBanners() async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.bannersEndpoint}',
    );
    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> bannersJson = data['data'] ?? data;
        return bannersJson.map((json) => AppBanner.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get Categories
  Future<List<Category>> getCategories() async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.categoriesEndpoint}',
    );
    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> categoriesJson = data['data'] ?? data;
        return categoriesJson.map((json) => Category.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
