import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../services/wishlist_service.dart';
import '../../services/cart_service.dart';
import '../shop/product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    // Fetch wishlist on load
    Future.microtask(() {
      Provider.of<WishlistService>(context, listen: false).fetchWishlist();
    });
  }

  void _addToCart(Product product) {
    final cart = Provider.of<CartService>(context, listen: false);
    cart.addToCart(product, 1);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ditambahkan ke keranjang'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WISHLIST')),
      body: Consumer<WishlistService>(
        builder: (ctx, wishlist, child) {
          if (wishlist.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (wishlist.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Wishlist kamu kosong',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Simpan produk favoritmu di sini',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => wishlist.fetchWishlist(),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.55,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: wishlist.items.length,
              itemBuilder: (ctx, i) =>
                  _buildWishlistItem(wishlist.items[i], wishlist),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWishlistItem(Product product, WishlistService wishlist) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with remove button
            Stack(
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    image: product.displayImage.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(product.displayImage),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: product.displayImage.isEmpty
                      ? const Center(
                          child: Icon(Icons.image, color: Colors.grey),
                        )
                      : null,
                ),
                // Remove button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => wishlist.removeFromWishlist(product.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                // Sale badge
                if (product.isOnSale)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${product.discountPercentage}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Product info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  if (product.isOnSale) ...[
                    Text(
                      currencyFormat.format(product.currentPrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      currencyFormat.format(product.price),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ] else
                    Text(
                      currencyFormat.format(product.price),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 8),
                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: product.stock > 0
                          ? () => _addToCart(product)
                          : null,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        product.stock > 0 ? 'KERANJANG' : 'HABIS',
                        style: TextStyle(
                          fontSize: 12,
                          color: product.stock > 0 ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
