import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../widgets/product_item.dart';
import '../../widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = Provider.of<ProductService>(context, listen: false).getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text('LAVIADE.', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
            centerTitle: true,
            actions: [
               IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner
                CarouselSlider(
                  options: CarouselOptions(
                    height: 200.0,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                    aspectRatio: 16/9,
                  ),
                  items: [1,2,3].map((i) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: Center(child: Text('Campaign $i', style: const TextStyle(fontSize: 16.0))),
                        );
                      },
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // New Release
                SectionHeader(title: 'New Release', onViewAll: () {}),
                SizedBox(
                  height: 270,
                  child: FutureBuilder<List<Product>>(
                    future: _productsFuture,
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                         // Fallback dummy for development if API fails
                         return _buildDummyList();
                      }
                      final products = snapshot.data ?? [];
                      if (products.isEmpty) return _buildDummyList();

                      return ListView.builder(
                        padding: const EdgeInsets.only(left: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: products.length,
                        itemBuilder: (ctx, i) => ProductItem(product: products[i]),
                      );
                    },
                  ),
                ),

                // Best Seller
                SectionHeader(title: 'Best Seller', onViewAll: () {}),
                 SizedBox(
                  height: 270,
                  child: FutureBuilder<List<Product>>(
                    future: _productsFuture, // Use same list for now
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final products = snapshot.data ?? [];
                      if (products.isEmpty) return _buildDummyList();

                      return ListView.builder(
                        padding: const EdgeInsets.only(left: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: products.length,
                        itemBuilder: (ctx, i) => ProductItem(product: products.reversed.toList()[i]),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDummyList() {
    // Dummy Data
    final dummyProducts = [
      Product(id: 101, name: 'Oversized Tee', description: 'Cotton', price: 45.0, imageUrl: ''),
      Product(id: 102, name: 'Cargo Pants', description: 'Utility', price: 85.0, imageUrl: ''),
      Product(id: 103, name: 'Varsity Jacket', description: 'Wool', price: 120.0, imageUrl: ''),
    ];
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16),
      scrollDirection: Axis.horizontal,
      itemCount: dummyProducts.length,
      itemBuilder: (ctx, i) => ProductItem(product: dummyProducts[i]),
    );
  }
}
