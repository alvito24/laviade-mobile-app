import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  final double totalAmount;
  const CheckoutScreen({super.key, required this.totalAmount});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  bool _isLoading = false;

  void _placeOrder() async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<OrderService>(context, listen: false).createOrder({
        'address': _addressController.text,
        'payment_method': 'cod', // Hardcoded for simplified version
        'items': [] // Backend usually takes items from cart session, or we send them here
      });
      // Clear cart
      // Navigate to success or Orders
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order Placed Successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CHECKOUT')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
             TextField(
               controller: _addressController,
               decoration: const InputDecoration(labelText: 'Shipping Address'),
               maxLines: 3,
             ),
             const Spacer(),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                 Text('\$${widget.totalAmount}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               ],
             ),
             const SizedBox(height: 16),
             SizedBox(
               width: double.infinity,
               child: ElevatedButton(
                 onPressed: _isLoading ? null : _placeOrder,
                 child: _isLoading ? const CircularProgressIndicator() : const Text('CONFIRM ORDER'),
               ),
             )
          ],
        ),
      ),
    );
  }
}
