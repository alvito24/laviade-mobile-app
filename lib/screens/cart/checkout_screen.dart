import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/address_model.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../../services/address_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = false;
  bool _isLoadingAddresses = true;
  List<Address> _addresses = [];
  Address? _selectedAddress;
  String _selectedShipping = 'regular';
  String _selectedPayment = 'bank_transfer';

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final Map<String, Map<String, dynamic>> _shippingOptions = {
    'regular': {'name': 'Regular', 'cost': 15000, 'estimate': '3-5 hari'},
    'express': {'name': 'Express', 'cost': 25000, 'estimate': '1-2 hari'},
  };

  final Map<String, String> _paymentOptions = {
    'bank_transfer': 'Transfer Bank',
    'cod': 'Bayar di Tempat (COD)',
  };

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    try {
      final addresses = await Provider.of<AddressService>(
        context,
        listen: false,
      ).getAddresses();
      setState(() {
        _addresses = addresses;
        _selectedAddress = addresses.isNotEmpty
            ? addresses.firstWhere(
                (a) => a.isPrimary,
                orElse: () => addresses.first,
              )
            : null;
        _isLoadingAddresses = false;
      });
    } catch (e) {
      setState(() => _isLoadingAddresses = false);
    }
  }

  double get _shippingCost =>
      (_shippingOptions[_selectedShipping]?['cost'] as int?)?.toDouble() ?? 0;

  void _placeOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih alamat pengiriman terlebih dahulu'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final cartService = Provider.of<CartService>(context, listen: false);
      final orderService = Provider.of<OrderService>(context, listen: false);

      await orderService.createOrder(
        addressId: _selectedAddress!.id,
        shippingMethod: _selectedShipping,
        shippingCost: _shippingCost,
        paymentMethod: _selectedPayment,
      );

      // Clear selected items from cart
      cartService.clearSelectedItems();

      // Navigate back and show success
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesanan berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);
    final subtotal = cart.totalAmount;
    final total = subtotal + _shippingCost;

    return Scaffold(
      appBar: AppBar(title: const Text('CHECKOUT')),
      body: _isLoadingAddresses
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address Section
                  _buildSectionTitle('Alamat Pengiriman'),
                  _buildAddressSection(),

                  const SizedBox(height: 24),

                  // Shipping Method
                  _buildSectionTitle('Metode Pengiriman'),
                  _buildShippingSection(),

                  const SizedBox(height: 24),

                  // Payment Method
                  _buildSectionTitle('Metode Pembayaran'),
                  _buildPaymentSection(),

                  const SizedBox(height: 24),

                  // Order Summary
                  _buildSectionTitle('Ringkasan Pesanan'),
                  _buildOrderSummary(cart),

                  const SizedBox(height: 24),

                  // Price Summary
                  _buildPriceSummary(subtotal, total),

                  const SizedBox(height: 100),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      currencyFormat.format(subtotal + _shippingCost),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading || _selectedAddress == null
                      ? null
                      : _placeOrder,
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
                      : const Text('BAYAR'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAddressSection() {
    if (_addresses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Belum ada alamat tersimpan. Tambahkan alamat di profil.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: _addresses.map((address) {
        final isSelected = _selectedAddress?.id == address.id;
        return GestureDetector(
          onTap: () => setState(() => _selectedAddress = address),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Radio<int>(
                  value: address.id,
                  groupValue: _selectedAddress?.id,
                  onChanged: (val) =>
                      setState(() => _selectedAddress = address),
                  activeColor: Colors.black,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            address.recipientName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.phone,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.fullAddress,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildShippingSection() {
    return Column(
      children: _shippingOptions.entries.map((entry) {
        final key = entry.key;
        final option = entry.value;
        final isSelected = _selectedShipping == key;

        return GestureDetector(
          onTap: () => setState(() => _selectedShipping = key),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Radio<String>(
                  value: key,
                  groupValue: _selectedShipping,
                  onChanged: (val) => setState(() => _selectedShipping = val!),
                  activeColor: Colors.black,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Estimasi ${option['estimate']}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Text(
                  currencyFormat.format(option['cost']),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      children: _paymentOptions.entries.map((entry) {
        final key = entry.key;
        final label = entry.value;
        final isSelected = _selectedPayment == key;

        return GestureDetector(
          onTap: () => setState(() => _selectedPayment = key),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Radio<String>(
                  value: key,
                  groupValue: _selectedPayment,
                  onChanged: (val) => setState(() => _selectedPayment = val!),
                  activeColor: Colors.black,
                ),
                Text(label),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderSummary(CartService cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: cart.selectedItems.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                    image: item.product.displayImage.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(item.product.displayImage),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.variantText.isNotEmpty)
                        Text(
                          item.variantText,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Text('x${item.quantity}'),
                const SizedBox(width: 16),
                Text(
                  currencyFormat.format(item.totalPrice),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceSummary(double subtotal, double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text(currencyFormat.format(subtotal)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ongkos Kirim'),
              Text(currencyFormat.format(_shippingCost)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                currencyFormat.format(total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
