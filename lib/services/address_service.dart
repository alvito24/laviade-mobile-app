import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/address_model.dart';
import '../utils/constants.dart';

class AddressService {
  final String? token;

  AddressService(this.token);

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // Get all user addresses
  Future<List<Address>> getAddresses() async {
    if (token == null) return [];

    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.addressesEndpoint}',
    );
    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> addressesJson = data['data'] ?? data;
        return addressesJson.map((json) => Address.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching addresses: $e");
      rethrow;
    }
  }

  // Add new address
  Future<Address> addAddress({
    String? label,
    required String recipientName,
    required String phone,
    required String province,
    required String city,
    required String district,
    required String postalCode,
    required String addressDetail,
    bool isPrimary = false,
  }) async {
    if (token == null) throw Exception('Tidak terautentikasi');

    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.addressesEndpoint}',
    );
    try {
      final body = {
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

      final response = await http.post(
        url,
        body: json.encode(body),
        headers: _headers,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Address.fromJson(responseData['data'] ?? responseData);
      } else {
        throw Exception(responseData['message'] ?? 'Gagal menambahkan alamat');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update address
  Future<Address> updateAddress({
    required int addressId,
    String? label,
    String? recipientName,
    String? phone,
    String? province,
    String? city,
    String? district,
    String? postalCode,
    String? addressDetail,
    bool? isPrimary,
  }) async {
    if (token == null) throw Exception('Tidak terautentikasi');

    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.addressesEndpoint}/$addressId',
    );
    try {
      final body = <String, dynamic>{};
      if (label != null) body['label'] = label;
      if (recipientName != null) body['recipient_name'] = recipientName;
      if (phone != null) body['phone'] = phone;
      if (province != null) body['province'] = province;
      if (city != null) body['city'] = city;
      if (district != null) body['district'] = district;
      if (postalCode != null) body['postal_code'] = postalCode;
      if (addressDetail != null) body['address_detail'] = addressDetail;
      if (isPrimary != null) body['is_primary'] = isPrimary;

      final response = await http.put(
        url,
        body: json.encode(body),
        headers: _headers,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return Address.fromJson(responseData['data'] ?? responseData);
      } else {
        throw Exception(responseData['message'] ?? 'Gagal memperbarui alamat');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete address
  Future<void> deleteAddress(int addressId) async {
    if (token == null) throw Exception('Tidak terautentikasi');

    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.addressesEndpoint}/$addressId',
    );
    try {
      final response = await http.delete(url, headers: _headers);

      if (response.statusCode != 200) {
        final responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Gagal menghapus alamat');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Set as primary address
  Future<void> setPrimary(int addressId) async {
    await updateAddress(addressId: addressId, isPrimary: true);
  }
}
