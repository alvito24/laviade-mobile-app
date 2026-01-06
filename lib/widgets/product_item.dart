import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../screens/shop/product_detail_screen.dart';
import '../utils/theme.dart';

class ProductItem extends StatelessWidget {
  final Product product;
  
  const ProductItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => ProductDetailScreen(product: product)),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: 160,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                image: product.imageUrl.isNotEmpty 
                  ? DecorationImage(image: NetworkImage(product.imageUrl), fit: BoxFit.cover)
                  : null,
              ),
              child: product.imageUrl.isEmpty 
                  ? const Icon(Icons.image_not_supported, color: Colors.grey) 
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${product.price}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
