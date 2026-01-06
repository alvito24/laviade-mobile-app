class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? gender;
  final String? birthDate;
  final String? profilePhotoUrl;
  final String? token;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.gender,
    this.birthDate,
    this.profilePhotoUrl,
    this.token,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      gender: json['gender'],
      birthDate: json['birth_date'],
      profilePhotoUrl: json['profile_photo_url'],
      token: json['token'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'birth_date': birthDate,
      'profile_photo_url': profilePhotoUrl,
      'token': token,
      'is_active': isActive,
    };
  }

  // Get initials for avatar
  String get initials {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
