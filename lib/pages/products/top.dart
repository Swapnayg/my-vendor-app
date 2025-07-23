import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_vendor_app/common/common_layout.dart';
import 'package:my_vendor_app/data/sample_top_products.dart';
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

  List<Product> get filteredProducts {
    List<Product> result =
        searchQuery.isEmpty
            ? sampleProducts
            : sampleProducts
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Top Products",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Search Field (takes remaining width)
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
                          vertical: 0,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          ), // fallback
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          ), // light gray when inactive
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          ), // light gray when focused
                        ),
                      ),
                    ),
                  ),
                ),

                // Filter Chips
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

            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount =
                      constraints.maxWidth > 800
                          ? 4
                          : constraints.maxWidth > 600
                          ? 3
                          : 2;

                  return GridView.builder(
                    itemCount: filteredProducts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return GestureDetector(
                        onTap:
                            () =>
                                context.go('/products/details', extra: product),
                        child: ProductCard(product: product),
                      );
                    },
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

  double _averageRating() {
    if (product.reviews.isEmpty) return 0;
    final total = product.reviews.fold(0, (sum, r) => sum + r.rating);
    return total / product.reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    final rating = _averageRating().toStringAsFixed(1);
    final orders = product.orderItems.length;

    final imageUrl =
        product.images.isNotEmpty
            ? product.images.first.url
            : 'https://via.placeholder.com/150?text=No+Image';

    final imageWidget =
        imageUrl.startsWith('http')
            ? Image.network(imageUrl, fit: BoxFit.cover)
            : Image.asset(imageUrl, fit: BoxFit.cover);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              child: imageWidget,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '₹${product.price}',
                  style: const TextStyle(color: Colors.green),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    Text(' $rating'),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.shopping_cart_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    Text(' $orders'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
