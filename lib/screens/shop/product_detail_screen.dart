import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../services/cart_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedSize = 'M';
  final List<String> _sizes = ['S', 'M', 'L', 'XL'];

  void _addToCart() {
    Provider.of<CartService>(context, listen: false).addToCart(
      widget.product, 
      1, 
      _selectedSize
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to bag'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 450,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                image: widget.product.imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(widget.product.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
              ),
              child: widget.product.imageUrl.isEmpty 
                  ? const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey))
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${widget.product.price}',
                    style: const TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: const TextStyle(color: Colors.grey, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Text('Select Size', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: _sizes.map((size) => GestureDetector(
                      onTap: () => setState(() => _selectedSize = size),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedSize == size ? Colors.black : Colors.grey[300]!
                          ),
                          color: _selectedSize == size ? Colors.black : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          size,
                          style: TextStyle(
                            color: _selectedSize == size ? Colors.white : Colors.black
                          ),
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       const Text('Reviews', style: TextStyle(fontWeight: FontWeight.bold)),
                       Row(
                         children: [
                           const Icon(Icons.star, color: Colors.amber, size: 16),
                           Text(' ${widget.product.rating}'),
                         ],
                       )
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('No reviews yet.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _addToCart,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.black),
                  ),
                  child: const Text('ADD TO CART', style: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                     _addToCart();
                     // Navigate to Cart or Checkout
                     Navigator.of(context).popUntil((route) => route.isFirst);
                     // Usually would navigate to Cart Tab
                  },
                  child: const Text('BUY NOW'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
