import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../models/banner_model.dart';
import '../../services/product_service.dart';
import '../../services/home_service.dart';
import '../../widgets/product_item.dart';
import '../../widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> _newArrivalsFuture;
  late Future<List<Product>> _bestSellersFuture;
  late Future<List<AppBanner>> _bannersFuture;
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    final productService = Provider.of<ProductService>(context, listen: false);
    final homeService = Provider.of<HomeService>(context, listen: false);

    _newArrivalsFuture = productService.getNewArrivals();
    _bestSellersFuture = productService.getBestSellers();
    _bannersFuture = homeService.getBanners();
    _categoriesFuture = homeService.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _fetchData();
          });
          // Wait for all to complete
          await Future.wait([
            _newArrivalsFuture,
            _bestSellersFuture,
            _bannersFuture,
            _categoriesFuture,
          ]);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: const Text(
                'LAVIADE.',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
              centerTitle: true,
              actions: [
                IconButton(icon: const Icon(Icons.search), onPressed: () {}),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Banners Section
                  FutureBuilder<List<AppBanner>>(
                    future: _bannersFuture,
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: 200,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final banners = snapshot.data ?? [];
                      if (banners.isEmpty) {
                        // Fallback to static if no banners
                        return CarouselSlider(
                          options: CarouselOptions(
                            height: 200.0,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            viewportFraction: 0.9,
                            aspectRatio: 16 / 9,
                          ),
                          items: [
                            _buildStaticBanner(
                              'NEW COLLECTION',
                              '2026',
                              Colors.black,
                            ),
                            _buildStaticBanner(
                              'SALE UP TO',
                              '50% OFF',
                              Colors.red[800]!,
                            ),
                            _buildStaticBanner(
                              'FREE SHIPPING',
                              'Min. Order 500K',
                              Colors.grey[800]!,
                            ),
                          ],
                        );
                      }

                      return CarouselSlider(
                        options: CarouselOptions(
                          height: 200.0,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 0.9,
                          aspectRatio: 16 / 9,
                        ),
                        items: banners.map((banner) {
                          return Stack(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 5.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                  image: banner.displayImageUrl.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(
                                            banner.displayImageUrl,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                              ),
                              // Overlay with title, subtitle, and CTA
                              if (banner.title.isNotEmpty ||
                                  banner.ctaText != null)
                                Positioned(
                                  bottom: 0,
                                  left: 5,
                                  right: 5,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(12),
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.7),
                                        ],
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (banner.title.isNotEmpty)
                                          Text(
                                            banner.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        if (banner.subtitle.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            banner.subtitle,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                        if (banner.ctaText != null) ...[
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              banner.ctaText!,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Categories Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Text(
                      'Categories',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: FutureBuilder<List<Category>>(
                      future: _categoriesFuture,
                      builder: (ctx, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final categories = snapshot.data ?? [];
                        if (categories.isEmpty) {
                          return const Center(child: Text('No categories'));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (ctx, i) =>
                              _buildCategoryItem(categories[i]),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // New Release Section
                  SectionHeader(title: 'New Release', onViewAll: () {}),
                  SizedBox(
                    height: 280,
                    child: FutureBuilder<List<Product>>(
                      future: _newArrivalsFuture,
                      builder: (ctx, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return _buildEmptyState('Gagal memuat produk');
                        }
                        final products = snapshot.data ?? [];
                        if (products.isEmpty) {
                          return _buildEmptyState('Belum ada produk baru');
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.only(left: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: products.length,
                          itemBuilder: (ctx, i) =>
                              ProductItem(product: products[i]),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Best Seller Section
                  SectionHeader(title: 'Best Seller', onViewAll: () {}),
                  SizedBox(
                    height: 280,
                    child: FutureBuilder<List<Product>>(
                      future: _bestSellersFuture,
                      builder: (ctx, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return _buildEmptyState('Gagal memuat produk');
                        }
                        final products = snapshot.data ?? [];
                        if (products.isEmpty) {
                          return _buildEmptyState('Belum ada produk terlaris');
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.only(left: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: products.length,
                          itemBuilder: (ctx, i) =>
                              ProductItem(product: products[i]),
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
      ),
    );
  }

  Widget _buildStaticBanner(String title, String subtitle, Color bgColor) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Category category) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
              image: category.iconUrl != null
                  ? DecorationImage(
                      image: NetworkImage(category.iconUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: category.iconUrl == null
                ? const Icon(Icons.category, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 70,
            child: Text(
              category.name,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
