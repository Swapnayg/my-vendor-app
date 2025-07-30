import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/models/product.dart';
import '/theme/colors.dart';
import '/common/common_layout.dart';

class ProductStockUpdatePage extends StatefulWidget {
  final Product product;
  const ProductStockUpdatePage({super.key, required this.product});

  @override
  _ProductStockUpdatePageState createState() => _ProductStockUpdatePageState();
}

class _ProductStockUpdatePageState extends State<ProductStockUpdatePage> {
  late int stock;
  List<Map<String, dynamic>> stockHistory = [];
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    stock = widget.product.stock;
    fetchStockHistory();
  }

  Future<void> fetchStockHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/MobileApp/vendor/update-stock'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'productId': widget.product.id,
          'newStock': stock, // fetch latest even if not updated
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> recent = data['data']['recentUpdates'];
        setState(() {
          stockHistory =
              recent.map<Map<String, dynamic>>((item) {
                int oldStock = item['stock']; // this will be the new stock
                return {
                  'quantity': item['stock'] - stock, // difference from previous
                  'date': item['updatedAt'],
                };
              }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching stock history: $e');
    }
  }

  Future<void> updateStockOnServer() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/MobileApp/vendor/update-stock'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'productId': widget.product.id, 'newStock': stock}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          stock = data['data']['updatedProduct']['stock'];
        });
        fetchStockHistory();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update stock (${response.statusCode})'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating stock: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while updating stock.'),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void updateStock(int value) {
    setState(() {
      stock = value;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;

              return Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                radius: const Radius.circular(8),
                thickness: 6,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16.0 : 32.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => context.go('/products/inventory'),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.arrow_back, size: 20),
                            SizedBox(width: 4),
                            Text('Back', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Stock Management',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            const Icon(Icons.wallet, size: 80),
                            Text(
                              widget.product.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Current Stock: $stock',
                              style: const TextStyle(fontSize: 18),
                            ),
                            Chip(
                              label: Text(
                                stock > 0 ? 'In Stock' : 'Out of Stock',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor:
                                  stock > 0 ? AppColors.green : AppColors.pink,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      const Text(
                        'Set New Stock Quantity',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              if (stock > 0) updateStock(stock - 1);
                            },
                          ),
                          Text('$stock', style: const TextStyle(fontSize: 20)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => updateStock(stock + 1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton(
                            onPressed: isLoading ? null : updateStockOnServer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child:
                                isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text(
                                      'Update Stock',
                                      style: TextStyle(fontSize: 16),
                                    ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () => updateStock(widget.product.stock),
                            child: const Text('Clear Form'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      if (stockHistory.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 32),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.inventory_2_outlined, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Recent Stock Movements',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ...stockHistory.map((entry) {
                                final isIncrease = entry['quantity'] > 0;
                                final formattedDate = DateFormat(
                                  'MMM dd, yyyy',
                                ).format(DateTime.parse(entry['date']));
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              isIncrease
                                                  ? Colors.green.shade100
                                                  : Colors.red.shade100,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: Icon(
                                          isIncrease ? Icons.add : Icons.remove,
                                          size: 18,
                                          color:
                                              isIncrease
                                                  ? Colors.green
                                                  : Colors.red,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isIncrease
                                                  ? 'Stock Increased'
                                                  : 'Stock Decreased',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                            Text(
                                              formattedDate,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${isIncrease ? '+' : ''}${entry['quantity']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isIncrease
                                                  ? Colors.green
                                                  : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
