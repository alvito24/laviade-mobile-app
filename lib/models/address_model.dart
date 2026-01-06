class Address {
  final int id;
  final String? label;
  final String recipientName;
  final String phone;
  final String province;
  final String city;
  final String district;
  final String postalCode;
  final String addressDetail;
  final bool isPrimary;

  Address({
    required this.id,
    this.label,
    required this.recipientName,
    required this.phone,
    required this.province,
    required this.city,
    required this.district,
    required this.postalCode,
    required this.addressDetail,
    this.isPrimary = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      label: json['label'],
      recipientName: json['recipient_name'] ?? '',
      phone: json['phone'] ?? '',
      province: json['province'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      postalCode: json['postal_code'] ?? '',
      addressDetail: json['address_detail'] ?? '',
      isPrimary: json['is_primary'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'recipient_name': recipientName,
      'phone': phone,
      'province': province,
      'city': city,
      'district': district,
      'postal_code': postalCode,
      'address_detail': addressDetail,
      'is_primary': isPrimary,
    };
  }

  String get fullAddress =>
      '$addressDetail, $district, $city, $province $postalCode';

  String get displayLabel =>
      label ?? (isPrimary ? 'Alamat Utama' : 'Alamat $id');
}
