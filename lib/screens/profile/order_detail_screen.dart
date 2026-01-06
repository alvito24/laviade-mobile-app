import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ORDER #${order.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date: ${DateFormat('dd MMM yyyy').format(order.createdAt)}'),
                Text(order.status, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 32),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 60, height: 60,
                    color: Colors.grey[200],
                     child: item.product.imageUrl.isNotEmpty 
                      ? Image.network(item.product.imageUrl) 
                      : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${item.size} x ${item.quantity}'),
                      ],
                    ),
                  ),
                  Text('\$${item.price * item.quantity}'),
                ],
              ),
            )),
            const Divider(height: 32),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Paid', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('\$${order.totalAmount}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            if (order.status.toLowerCase() == 'completed') ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate to review form dialog
                    showDialog(context: context, builder: (ctx) => AlertDialog(
                      title: const Text('Write a Review'),
                      content: const TextField(decoration: InputDecoration(hintText: 'Great product!')),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('SUBMIT')),
                      ],
                    ));
                  },
                  child: const Text('WRITE REVIEW'),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
