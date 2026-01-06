import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/address_model.dart';
import '../../services/address_service.dart';
import 'add_address_screen.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  List<Address> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    setState(() => _isLoading = true);
    try {
      final addresses = await Provider.of<AddressService>(
        context,
        listen: false,
      ).getAddresses();
      setState(() {
        _addresses = addresses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat alamat: $e')));
      }
    }
  }

  Future<void> _deleteAddress(Address address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Alamat?'),
        content: Text('Hapus alamat "${address.displayLabel}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('HAPUS', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Provider.of<AddressService>(
          context,
          listen: false,
        ).deleteAddress(address.id);
        _fetchAddresses();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alamat berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
        }
      }
    }
  }

  Future<void> _setPrimary(Address address) async {
    try {
      await Provider.of<AddressService>(
        context,
        listen: false,
      ).setPrimary(address.id);
      _fetchAddresses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alamat utama berhasil diubah')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengubah: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ALAMAT SAYA')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _fetchAddresses,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _addresses.length,
                itemBuilder: (ctx, i) => _buildAddressCard(_addresses[i]),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const AddAddressScreen()));
          if (result == true) {
            _fetchAddresses();
          }
        },
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Alamat',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada alamat',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan alamat pengiriman',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Address address) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: address.isPrimary
            ? const BorderSide(color: Colors.black, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        address.displayLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (address.isPrimary) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Utama',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (ctx) =>
                                  AddAddressScreen(address: address),
                            ),
                          )
                          .then((result) {
                            if (result == true) _fetchAddresses();
                          });
                    } else if (value == 'delete') {
                      _deleteAddress(address);
                    } else if (value == 'primary') {
                      _setPrimary(address);
                    }
                  },
                  itemBuilder: (ctx) => [
                    if (!address.isPrimary)
                      const PopupMenuItem(
                        value: 'primary',
                        child: Row(
                          children: [
                            Icon(Icons.star_outline, size: 20),
                            SizedBox(width: 8),
                            Text('Jadikan Utama'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 16),
            Text(
              address.recipientName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(address.phone, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(
              address.fullAddress,
              style: TextStyle(color: Colors.grey[600], height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
