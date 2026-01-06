import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../widgets/product_item.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _searchController = TextEditingController();
  List<Product> _products = [];
  bool _isLoading = false;
  bool _hasMore = true; // ignore: unused_field - prepared for pagination
  int _currentPage = 1;

  // Filter values
  double? _minPrice;
  double? _maxPrice;
  String _sortBy = 'latest';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts({String? query, bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _products = [];
    }

    setState(() => _isLoading = true);
    try {
      final response = await Provider.of<ProductService>(context, listen: false)
          .getProducts(
            search: query ?? _searchController.text,
            minPrice: _minPrice,
            maxPrice: _maxPrice,
            sort: _sortBy,
            page: _currentPage,
          );

      setState(() {
        if (refresh) {
          _products = response.products;
        } else {
          _products.addAll(response.products);
        }
        _hasMore = response.hasMorePages;
      });
    } catch (e) {
      setState(() => _products = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showFilter() {
    double tempMin = _minPrice ?? 0;
    double tempMax = _maxPrice ?? 1000000;
    String tempSort = _sortBy;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempMin = 0;
                            tempMax = 1000000;
                            tempSort = 'latest';
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sort
                  const Text(
                    'Urutkan',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildSortChip(
                        'Terbaru',
                        'latest',
                        tempSort,
                        (val) => setModalState(() => tempSort = val),
                      ),
                      _buildSortChip(
                        'Termurah',
                        'price_low',
                        tempSort,
                        (val) => setModalState(() => tempSort = val),
                      ),
                      _buildSortChip(
                        'Termahal',
                        'price_high',
                        tempSort,
                        (val) => setModalState(() => tempSort = val),
                      ),
                      _buildSortChip(
                        'Terlaris',
                        'popular',
                        tempSort,
                        (val) => setModalState(() => tempSort = val),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Rentang Harga',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  RangeSlider(
                    values: RangeValues(tempMin, tempMax),
                    min: 0,
                    max: 1000000,
                    divisions: 20,
                    labels: RangeLabels(
                      'Rp ${(tempMin / 1000).toStringAsFixed(0)}K',
                      'Rp ${(tempMax / 1000).toStringAsFixed(0)}K',
                    ),
                    onChanged: (values) {
                      setModalState(() {
                        tempMin = values.start;
                        tempMax = values.end;
                      });
                    },
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _minPrice = tempMin > 0 ? tempMin : null;
                          _maxPrice = tempMax < 1000000 ? tempMax : null;
                          _sortBy = tempSort;
                        });
                        _fetchProducts(refresh: true);
                      },
                      child: const Text('TERAPKAN FILTER'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortChip(
    String label,
    String value,
    String current,
    Function(String) onSelected,
  ) {
    final isSelected = current == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      selectedColor: Colors.black,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SHOP'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onSubmitted: (val) =>
                        _fetchProducts(query: val, refresh: true),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilter,
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchProducts(refresh: true),
        child: _isLoading && _products.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _products.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Produk tidak ditemukan',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _products.length,
                itemBuilder: (ctx, i) => ProductItem(product: _products[i]),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
