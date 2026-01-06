class Category {
  final int id;
  final String name;
  final String slug;
  final String? iconUrl;
  final String? imageUrl;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.iconUrl,
    this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      iconUrl: json['icon_url'],
      imageUrl: json['image_url'],
    );
  }
}
