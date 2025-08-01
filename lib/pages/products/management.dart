import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '/common/common_layout.dart';
import '/models/product.dart';
import '/theme/colors.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  List<Product> allProducts = [];
  List<Product> displayedProducts = [];
  String selectedCategory = 'All';
  String selectedStatus = 'All';
  String searchQuery = '';
  int itemsToShow = 10;

  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        _loadMore();
      }
    });
  }

  Future<void> fetchProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final uri = Uri.parse(
      'http://localhost:3000/api/MobileApp/vendor/product-management',
    );

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        final products = data.map((json) => Product.fromJson(json)).toList();

        setState(() {
          allProducts = products;
          _filterProducts();
        });
      } else {
        debugPrint('Failed to load products: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _loadMore() {
    setState(() {
      itemsToShow += 10;
      _filterProducts();
    });
  }

  void _filterProducts() {
    setState(() {
      displayedProducts =
          allProducts
              .where((product) {
                final matchesSearch = product.name.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
                final matchesCategory =
                    selectedCategory == 'All' ||
                    product.category?.name == selectedCategory;
                final matchesStatus =
                    selectedStatus == 'All' ||
                    product.status.name == selectedStatus.toLowerCase();
                return matchesSearch && matchesCategory && matchesStatus;
              })
              .take(itemsToShow)
              .toList();
    });
  }

  Future<void> _deleteProduct(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      // Optionally show an error/snackbar
      print("Token not found");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/MobileApp/vendor/delete-product'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'productId': product.id}),
      );

      if (response.statusCode == 200) {
        setState(() {
          allProducts.remove(product);
          _filterProducts(); // Apply any active filters
        });
      } else {
        final data = jsonDecode(response.body);
        print("Delete failed: ${data['error'] ?? 'Unknown error'}");
        // Optionally show a snackbar with failure
      }
    } catch (e) {
      print("Delete error: $e");
      // Optionally show a snackbar with error
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: TextField(
                    onChanged: (value) {
                      searchQuery = value;
                      _filterProducts();
                    },
                    decoration: InputDecoration(
                      hintText: "Search Products...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primary.withOpacity(0.8),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: selectedCategory,
                  items:
                      ['All', 'Electronics', 'Clothing', 'Food']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (value) {
                    selectedCategory = value!;
                    _filterProducts();
                  },
                ),
                DropdownButton<String>(
                  value: selectedStatus,
                  items:
                      ['All', 'Pending', 'Approved', 'Rejected', 'Suspended']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (value) {
                    selectedStatus = value!;
                    _filterProducts();
                  },
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    context.go('/add-product');
                  },
                  icon: const Icon(Icons.add),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  label: const Text("Add Product"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LayoutBuilder(
                builder:
                    (context, constraints) => ListView.builder(
                      controller: scrollController,
                      itemCount: displayedProducts.length,
                      itemBuilder: (context, index) {
                        final product = displayedProducts[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Flex(
                              direction:
                                  constraints.maxWidth > 600
                                      ? Axis.horizontal
                                      : Axis.vertical,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child:
                                          product.images.isNotEmpty
                                              ? Image.network(
                                                product.images.first.url,
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                              )
                                              : Container(
                                                width: 60,
                                                height: 60,
                                                color: Colors.grey.shade200,
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                ),
                                              ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Category: ${product.category?.name ?? 'N/A'}",
                                        ),
                                        Text(
                                          "Vendor: ${product.vendor?.businessName ?? 'Unknown'}",
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                              product.status.name,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            product.status.name.toUpperCase(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: _getStatusColor(
                                                product.status.name,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "₹${product.price.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.visibility,
                                            color: Colors.blue,
                                          ),
                                          tooltip: "View",
                                          onPressed:
                                              () => context.go(
                                                '/view-product',
                                                extra: product,
                                              ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.orange,
                                          ),
                                          tooltip: "Edit",
                                          onPressed:
                                              () => context.go(
                                                '/add-product',
                                                extra: product,
                                              ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          tooltip: "Delete",
                                          onPressed:
                                              () => showDialog(
                                                context: context,
                                                builder:
                                                    (ctx) => AlertDialog(
                                                      title: const Text(
                                                        "Delete Product",
                                                      ),
                                                      content: const Text(
                                                        "Are you sure you want to delete this product?",
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    ctx,
                                                                  ),
                                                          child: const Text(
                                                            "Cancel",
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(ctx);
                                                            _deleteProduct(
                                                              product,
                                                            );
                                                          },
                                                          child: const Text(
                                                            "Delete",
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green.shade700;
      case 'pending':
        return Colors.orange.shade700;
      case 'rejected':
        return Colors.red.shade700;
      case 'suspended':
        return Colors.grey.shade700;
      default:
        return Colors.black87;
    }
  }
}
