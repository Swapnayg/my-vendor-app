import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/models/order.dart';
import 'package:go_router/go_router.dart';
import 'package:my_vendor_app/common/common_layout.dart'; // Adjust this path

class OrderViewPage extends StatelessWidget {
  final Order order;

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
                      : 'https://via.placeholder.com/200', // fallback image
            };
          }).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat(
      'dd MMM yyyy – hh:mm a',
    ).format(order.createdAt);
    final totalFormatted = '₹${order.total.toStringAsFixed(2)}';

    return CommonLayout(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rebuilt AppBar UI as a header
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
                    context.go(
                      '/orders/invoice',
                      extra: {
                        'order': convertToMockOrder(order.toJson()),
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

          // Main content (scrollable)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailTile('Order ID', '#${order.id}'),
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
                          color: _statusColor(order.status),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          orderStatusToString(order.status),
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
                  _buildDetailTile('Name', order.customer!['name']),
                  _buildDetailTile('Email', order.customer!['email']),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  /// Items
                  Text(
                    'Order Items',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...order.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: Text(item.product!.name)),
                          Expanded(
                            child: Text(
                              'Qty: ${item.quantity}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

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

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING:
        return Colors.orange;
      case OrderStatus.SHIPPED:
        return Colors.blue;
      case OrderStatus.DELIVERED:
        return Colors.green;
      case OrderStatus.RETURNED:
        return Colors.purple;
      case OrderStatus.CANCELLED:
        return Colors.red;
    }
  }
}
