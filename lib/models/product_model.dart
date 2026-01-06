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
  final String imageUrl;
  final bool isPrimary;

  ProductImage({
    required this.id,
    required this.imageUrl,
    this.isPrimary = false,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'],
      imageUrl: json['image_url'] ?? json['url'] ?? '',
      isPrimary: json['is_primary'] ?? false,
    );
  }
}

class Product {
  final int id;
  final String name;
  final String slug;
  final String description;
  final double price;
  final double? salePrice;
  final String? primaryImageUrl;
  final List<ProductImage> images;
  final Category? category;
  final double rating;
  final int reviewCount;
  final int stock;
  final List<String> sizes;
  final List<String> colors;
  final bool isActive;
  final bool isFeatured;
  final bool isNewArrival;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    this.salePrice,
    this.primaryImageUrl,
    this.images = const [],
    this.category,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.stock = 0,
    this.sizes = const [],
    this.colors = const [],
    this.isActive = true,
    this.isFeatured = false,
    this.isNewArrival = false,
  });

  // Get the display price (sale price if available, otherwise regular price)
  double get currentPrice => salePrice ?? price;

  // Check if product is on sale
  bool get isOnSale => salePrice != null && salePrice! < price;

  // Get discount percentage
  int get discountPercentage {
    if (!isOnSale) return 0;
    return (((price - salePrice!) / price) * 100).round();
  }

  // Get primary image or first image
  String get displayImage {
    if (primaryImageUrl != null && primaryImageUrl!.isNotEmpty) {
      return primaryImageUrl!;
    }
    if (images.isNotEmpty) {
      final primary = images.firstWhere(
        (img) => img.isPrimary,
        orElse: () => images.first,
      );
      return primary.imageUrl;
    }
    return ''; // Placeholder image URL could go here
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse sizes - can be JSON string or list
    List<String> parseSizes(dynamic sizesData) {
      if (sizesData == null) return [];
      if (sizesData is List) return sizesData.cast<String>();
      if (sizesData is String) {
        try {
          // Try to parse as JSON array
          return List<String>.from(
            (sizesData.startsWith('[')
                ? List.from(
                    json.containsKey('sizes_parsed')
                        ? json['sizes_parsed']
                        : [],
                  )
                : sizesData.split(',').map((s) => s.trim())),
          );
        } catch (_) {
          return sizesData.split(',').map((s) => s.trim()).toList();
        }
      }
      return [];
    }

    // Parse colors - can be JSON string or list
    List<String> parseColors(dynamic colorsData) {
      if (colorsData == null) return [];
      if (colorsData is List) return colorsData.cast<String>();
      if (colorsData is String) {
        try {
          return colorsData.split(',').map((s) => s.trim()).toList();
        } catch (_) {
          return [];
        }
      }
      return [];
    }

    // Parse images
    List<ProductImage> parseImages(dynamic imagesData) {
      if (imagesData == null) return [];
      if (imagesData is List) {
        return imagesData.map((img) => ProductImage.fromJson(img)).toList();
      }
      return [];
    }

    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      price: _parseDouble(json['price']),
      salePrice: json['sale_price'] != null
          ? _parseDouble(json['sale_price'])
          : null,
      primaryImageUrl: json['primary_image_url'] ?? json['image_url'],
      images: parseImages(json['images']),
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      rating: _parseDouble(json['average_rating'] ?? json['rating'] ?? 0),
      reviewCount: json['reviews_count'] ?? json['review_count'] ?? 0,
      stock: json['stock'] ?? 0,
      sizes: parseSizes(json['sizes']),
      colors: parseColors(json['colors']),
      isActive: json['is_active'] ?? true,
      isFeatured: json['is_featured'] ?? false,
      isNewArrival: json['is_new_arrival'] ?? false,
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
