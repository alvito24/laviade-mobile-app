class AppBanner {
  final int id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? link;

  AppBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.link,
  });

  factory AppBanner.fromJson(Map<String, dynamic> json) {
    return AppBanner(
      id: json['id'],
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      imageUrl: json['image_url'] ?? '',
      link: json['link'],
    );
  }
}
