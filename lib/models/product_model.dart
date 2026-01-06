import '../utils/constants.dart';

class Category {
  final int id;
  final String name;
  final String? slug;
  final String? imageUrl;

  Category({required this.id, required this.name, this.slug, this.imageUrl});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      imageUrl: json['image_url'],
    );
  }
}

class ProductImage {
  final int id;
  final String imagePath;
  final bool isPrimary;

  ProductImage({
    required this.id,
    required this.imagePath,
    this.isPrimary = false,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'],
      imagePath: json['image_path'] ?? '',
      isPrimary: json['is_primary'] == 1 || json['is_primary'] == true,
    );
  }

  String get fullUrl => AppConstants.getImageUrl(imagePath);
}

class Product {
  final int id;
  final String name;
  final String slug;
  final String description;
  final double price;
  final double? discountPrice;
  final int stock;
  final List<String> sizes;
  final List<String> colors;
  final Category? category;
  final List<ProductImage> images;
  final double rating;
  final int totalSold;
  final bool isActive;
  final bool isFeatured;
  final bool isNewArrival;
  final bool isBestSeller;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    this.discountPrice,
    this.stock = 0,
    this.sizes = const [],
    this.colors = const [],
    this.category,
    this.images = const [],
    this.rating = 0.0,
    this.totalSold = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.isNewArrival = false,
    this.isBestSeller = false,
  });

  // Get primary image URL
  String get imageUrl {
    final primary = images.where((img) => img.isPrimary).toList();
    if (primary.isNotEmpty) {
      return primary.first.fullUrl;
    }
    if (images.isNotEmpty) {
      return images.first.fullUrl;
    }
    return AppConstants.getImageUrl(null);
  }

  // Get current price (considering discount)
  double get currentPrice => discountPrice ?? price;

  // Check if product has discount
  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  // Calculate discount percentage
  int get discountPercentage {
    if (!hasDiscount) return 0;
    return (((price - discountPrice!) / price) * 100).round();
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse sizes - can be JSON string or List
    List<String> parseSizes(dynamic sizesData) {
      if (sizesData == null) return [];
      if (sizesData is List) return sizesData.map((e) => e.toString()).toList();
      if (sizesData is String && sizesData.isNotEmpty) {
        try {
          return List<String>.from(sizesData.split(',').map((e) => e.trim()));
        } catch (e) {
          return [];
        }
      }
      return [];
    }

    // Parse colors - can be JSON string or List
    List<String> parseColors(dynamic colorsData) {
      if (colorsData == null) return [];
      if (colorsData is List)
        return colorsData.map((e) => e.toString()).toList();
      if (colorsData is String && colorsData.isNotEmpty) {
        try {
          return List<String>.from(colorsData.split(',').map((e) => e.trim()));
        } catch (e) {
          return [];
        }
      }
      return [];
    }

    // Parse images
    List<ProductImage> parseImages(dynamic imagesData, dynamic primaryImage) {
      List<ProductImage> result = [];

      // Add primary image first if exists
      if (primaryImage != null && primaryImage is Map<String, dynamic>) {
        result.add(ProductImage.fromJson(primaryImage));
      }

      // Add other images
      if (imagesData != null && imagesData is List) {
        for (var img in imagesData) {
          if (img is Map<String, dynamic>) {
            // Avoid duplicates
            final newImg = ProductImage.fromJson(img);
            if (!result.any((existing) => existing.id == newImg.id)) {
              result.add(newImg);
            }
          }
        }
      }

      return result;
    }

    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      discountPrice: json['discount_price'] != null
          ? double.tryParse(json['discount_price'].toString())
          : null,
      stock: json['stock'] ?? 0,
      sizes: parseSizes(json['sizes']),
      colors: parseColors(json['colors']),
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      images: parseImages(json['images'], json['primary_image']),
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      totalSold: json['total_sold'] ?? 0,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      isNewArrival:
          json['is_new_arrival'] == 1 || json['is_new_arrival'] == true,
      isBestSeller:
          json['is_best_seller'] == 1 || json['is_best_seller'] == true,
    );
  }
}
