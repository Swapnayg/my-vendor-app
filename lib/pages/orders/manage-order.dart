import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:my_vendor_app/common/common_layout.dart';

class OrderViewPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderViewPage({super.key, required this.order});

  Map<String, dynamic> convertToMockOrder(Map<String, dynamic> order) {
    return {
      'orderId': '#${order['id']}',
      'status': order['status'],
      'payment': order['payment']?['status'] ?? 'UNPAID',
      'createdAt': order['createdAt'],
      'vendor': {
        'businessName': order['vendor']?['businessName'] ?? 'Unknown Vendor',
      },
      'customer': {
        'name': order['customer']?['name'] ?? 'Unknown',
        'email': order['customer']?['email'] ?? '',
        'phone': order['customer']?['phone'] ?? '',
      },
      'items':
          (order['items'] as List).map((item) {
            final product = item['product'] ?? {};
            final images = product['images'] ?? [];
            return {
              'name': product['name'] ?? 'Unnamed Product',
              'quantity': item['quantity'] ?? 0,
              'price': item['price']?.toDouble() ?? 0.0,
              'image':
                  images.isNotEmpty
                      ? images[0]['url']
                      : 'https://via.placeholder.com/200',
            };
          }).toList(),
    };
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'SHIPPED':
        return Colors.blue;
      case 'DELIVERED':
        return Colors.green;
      case 'RETURNED':
        return Colors.purple;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final createdAt =
        DateTime.tryParse(order['createdAt'] ?? '') ??
        DateTime.now(); // Fallback
    final dateFormatted = DateFormat('dd MMM yyyy – hh:mm a').format(createdAt);
    final total = order['total']?.toDouble() ?? 0.0;
    final totalFormatted = '₹${total.toStringAsFixed(2)}';

    final customer = order['customer'] ?? {};
    final items = order['items'] as List? ?? [];

    return CommonLayout(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AppBar-like header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/orders/management'),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    print(convertToMockOrder(order));
                    context.go(
                      '/orders/invoice',
                      extra: {
                        'order': convertToMockOrder(order),
                        'source': 'management',
                      },
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: const Text(
                    'Invoice',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 32),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailTile('Order ID', '#${order['id']}'),
                  Row(
                    children: [
                      const SizedBox(
                        width: 120,
                        child: Text(
                          'Status',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Text(': '),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(order['status']),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order['status'] ?? 'UNKNOWN',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDetailTile('Order Date', dateFormatted),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  /// Customer
                  Text(
                    'Customer Details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailTile('Name', customer['name'] ?? 'N/A'),
                  _buildDetailTile('Email', customer['email'] ?? 'N/A'),
                  _buildDetailTile('Phone', customer['phone'] ?? 'N/A'),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  /// Items
                  Text(
                    'Order Items',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...items.map((item) {
                    final product = item['product'] ?? {};
                    final name = product['name'] ?? 'Unnamed';
                    final qty = item['quantity'] ?? 0;
                    final price = item['price']?.toDouble() ?? 0.0;
                    final images = product['images'] ?? [];
                    final imageUrl =
                        (images.isNotEmpty && images[0]['url'] != null)
                            ? images[0]['url']
                            : 'https://via.placeholder.com/200';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              imageUrl,
                              height: 48,
                              width: 48,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) =>
                                      const Icon(Icons.broken_image),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(flex: 2, child: Text(name)),
                          Expanded(
                            child: Text(
                              'Qty: $qty',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '₹${(price * qty).toStringAsFixed(2)}',
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  /// Total
                  Text(
                    'Total Amount',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    totalFormatted,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
