class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? profilePhotoUrl;
  final String? gender;
  final DateTime? birthDate;
  final bool isActive;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profilePhotoUrl,
    this.gender,
    this.birthDate,
    this.isActive = true,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profilePhotoUrl: json['profile_photo_url'],
      gender: json['gender'],
      birthDate: json['birth_date'] != null
          ? DateTime.tryParse(json['birth_date'])
          : null,
      isActive: json['is_active'] ?? true,
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_photo_url': profilePhotoUrl,
      'gender': gender,
      'birth_date': birthDate?.toIso8601String(),
      'is_active': isActive,
      'token': token,
    };
  }

  // Create a copy with updated values
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? profilePhotoUrl,
    String? gender,
    DateTime? birthDate,
    bool? isActive,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      isActive: isActive ?? this.isActive,
      token: token ?? this.token,
    );
  }

  // Get initials for avatar
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}
