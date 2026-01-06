import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/address_model.dart';
import '../../services/address_service.dart';

class AddAddressScreen extends StatefulWidget {
  final Address? address; // null = add new, not null = edit

  const AddAddressScreen({super.key, this.address});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _provinceController;
  late TextEditingController _cityController;
  late TextEditingController _districtController;
  late TextEditingController _postalCodeController;
  late TextEditingController _addressDetailController;
  bool _isPrimary = false;
  bool _isLoading = false;

  bool get isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();
    final addr = widget.address;
    _labelController = TextEditingController(text: addr?.label ?? '');
    _nameController = TextEditingController(text: addr?.recipientName ?? '');
    _phoneController = TextEditingController(text: addr?.phone ?? '');
    _provinceController = TextEditingController(text: addr?.province ?? '');
    _cityController = TextEditingController(text: addr?.city ?? '');
    _districtController = TextEditingController(text: addr?.district ?? '');
    _postalCodeController = TextEditingController(text: addr?.postalCode ?? '');
    _addressDetailController = TextEditingController(
      text: addr?.addressDetail ?? '',
    );
    _isPrimary = addr?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _postalCodeController.dispose();
    _addressDetailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = Provider.of<AddressService>(context, listen: false);

      if (isEditing) {
        await service.updateAddress(
          addressId: widget.address!.id,
          label: _labelController.text.isNotEmpty
              ? _labelController.text
              : null,
          recipientName: _nameController.text,
          phone: _phoneController.text,
          province: _provinceController.text,
          city: _cityController.text,
          district: _districtController.text,
          postalCode: _postalCodeController.text,
          addressDetail: _addressDetailController.text,
          isPrimary: _isPrimary,
        );
      } else {
        await service.addAddress(
          label: _labelController.text.isNotEmpty
              ? _labelController.text
              : null,
          recipientName: _nameController.text,
          phone: _phoneController.text,
          province: _provinceController.text,
          city: _cityController.text,
          district: _districtController.text,
          postalCode: _postalCodeController.text,
          addressDetail: _addressDetailController.text,
          isPrimary: _isPrimary,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Alamat berhasil diperbarui'
                  : 'Alamat berhasil ditambahkan',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'EDIT ALAMAT' : 'TAMBAH ALAMAT')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label (optional)
              _buildLabel('Label Alamat (opsional)'),
              TextFormField(
                controller: _labelController,
                decoration: _inputDecoration('Contoh: Rumah, Kantor'),
              ),

              const SizedBox(height: 20),

              // Recipient Name
              _buildLabel('Nama Penerima *'),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Masukkan nama penerima'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Nama wajib diisi' : null,
              ),

              const SizedBox(height: 20),

              // Phone
              _buildLabel('Nomor Telepon *'),
              TextFormField(
                controller: _phoneController,
                decoration: _inputDecoration('Masukkan nomor telepon'),
                keyboardType: TextInputType.phone,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Telepon wajib diisi' : null,
              ),

              const SizedBox(height: 20),

              // Province
              _buildLabel('Provinsi *'),
              TextFormField(
                controller: _provinceController,
                decoration: _inputDecoration('Masukkan provinsi'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Provinsi wajib diisi' : null,
              ),

              const SizedBox(height: 20),

              // City & District Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Kota/Kabupaten *'),
                        TextFormField(
                          controller: _cityController,
                          decoration: _inputDecoration('Kota'),
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Wajib diisi' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Kecamatan *'),
                        TextFormField(
                          controller: _districtController,
                          decoration: _inputDecoration('Kecamatan'),
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Wajib diisi' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Postal Code
              _buildLabel('Kode Pos *'),
              TextFormField(
                controller: _postalCodeController,
                decoration: _inputDecoration('Masukkan kode pos'),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Kode pos wajib diisi' : null,
              ),

              const SizedBox(height: 20),

              // Address Detail
              _buildLabel('Detail Alamat *'),
              TextFormField(
                controller: _addressDetailController,
                decoration: _inputDecoration(
                  'Nama jalan, nomor rumah, RT/RW, dll',
                ),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty
                    ? 'Detail alamat wajib diisi'
                    : null,
              ),

              const SizedBox(height: 20),

              // Is Primary
              CheckboxListTile(
                value: _isPrimary,
                onChanged: (val) => setState(() => _isPrimary = val ?? false),
                title: const Text('Jadikan alamat utama'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isEditing ? 'SIMPAN PERUBAHAN' : 'SIMPAN ALAMAT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black),
      ),
    );
  }
}
