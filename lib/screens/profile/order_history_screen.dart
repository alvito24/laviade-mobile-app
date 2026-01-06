import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import 'order_detail_screen.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MY ORDERS')),
      body: FutureBuilder<List<Order>>(
        future: Provider.of<OrderService>(context, listen: false).getOrders(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(child: Text('No orders yet.'));
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (ctx, i) {
              final order = orders[i];
              return ListTile(
                title: Text('Order #${order.id}'),
                subtitle: Text(DateFormat('dd MMM yyyy').format(order.createdAt)),
                trailing: Text('\$${order.totalAmount}'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => OrderDetailScreen(order: order)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
