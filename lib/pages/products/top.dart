import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_vendor_app/common/common_layout.dart';
import 'package:my_vendor_app/models/product.dart';

enum ProductFilter { mostOrdered, topRated }

class TopProductsPage extends StatefulWidget {
  const TopProductsPage({super.key});

  @override
  State<TopProductsPage> createState() => _TopProductsPageState();
}

class _TopProductsPageState extends State<TopProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  ProductFilter selectedFilter = ProductFilter.mostOrdered;

  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final uri = Uri.parse(
        'http://localhost:3000/api/MobileApp/vendor/top-products',
      );
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['products'];
        setState(() {
          _products = data.map((json) => Product.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        debugPrint('Failed to fetch products: ${response.body}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Product> get filteredProducts {
    List<Product> result =
        searchQuery.isEmpty
            ? _products
            : _products
                .where(
                  (p) =>
                      p.name.toLowerCase().contains(searchQuery.toLowerCase()),
                )
                .toList();

    result.sort((a, b) {
      switch (selectedFilter) {
        case ProductFilter.mostOrdered:
          return b.orderItems.length.compareTo(a.orderItems.length);
        case ProductFilter.topRated:
          return _averageRating(b).compareTo(_averageRating(a));
      }
    });

    return result;
  }

  double _averageRating(Product product) {
    if (product.reviews.isEmpty) return 0;
    final total = product.reviews.fold<int>(0, (sum, r) => sum + r.rating);
    return total / product.reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Top Products",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 200,
                    maxWidth: 300,
                  ),
                  child: SizedBox(
                    height: 42,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => searchQuery = val),
                      decoration: InputDecoration(
                        hintText: "Search...",
                        prefixIcon: const Icon(Icons.search),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                _buildFilterChip(
                  ProductFilter.mostOrdered,
                  "Most Ordered",
                  Colors.pink,
                ),
                _buildFilterChip(
                  ProductFilter.topRated,
                  "Top Rated",
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _products.isEmpty
                      ? const Center(child: Text("No products yet."))
                      : ListView.separated(
                        itemCount: filteredProducts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return GestureDetector(
                            onTap:
                                () => context.go(
                                  '/products/details',
                                  extra: product,
                                ),
                            child: ProductCard(product: product),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    ProductFilter filter,
    String label,
    Color selectedColor,
  ) {
    final isSelected = selectedFilter == filter;
    IconData icon;
    switch (filter) {
      case ProductFilter.mostOrdered:
        icon = Icons.shopping_cart;
        break;
      case ProductFilter.topRated:
        icon = Icons.star;
        break;
    }

    return ChoiceChip(
      showCheckmark: false,
      selected: isSelected,
      onSelected: (_) => setState(() => selectedFilter = filter),
      backgroundColor: Colors.grey[300],
      selectedColor: selectedColor,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.black87,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final double rating =
        product.reviews.isNotEmpty
            ? product.reviews.fold(0, (sum, r) => sum + r.rating) /
                product.reviews.length
            : 0;
    final int orders = product.orderItems.length;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Left: Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${product.price}',
                    style: const TextStyle(color: Colors.green, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      Text(
                        ' ${rating.toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.shopping_cart,
                        size: 14,
                        color: Colors.grey,
                      ),
                      Text(' $orders', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Right: Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.images.first.url,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      height: 80,
                      width: 80,
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
