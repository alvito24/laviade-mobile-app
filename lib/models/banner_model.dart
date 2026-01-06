class AppBanner {
  final int id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? mobileImageUrl;
  final String? ctaText;
  final String? ctaLink;

  AppBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.mobileImageUrl,
    this.ctaText,
    this.ctaLink,
  });

  /// Get the best image URL for mobile (prefer mobile_image_url if available)
  String get displayImageUrl => mobileImageUrl ?? imageUrl;

  factory AppBanner.fromJson(Map<String, dynamic> json) {
    return AppBanner(
      id: json['id'],
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      imageUrl: json['image_url'] ?? '',
      mobileImageUrl: json['mobile_image_url'],
      ctaText: json['cta_text'],
      ctaLink: json['cta_link'],
    );
  }
}
