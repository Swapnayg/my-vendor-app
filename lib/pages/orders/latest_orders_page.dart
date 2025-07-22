import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/common/common_layout.dart';

class LatestOrdersPage extends StatelessWidget {
  const LatestOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> latestOrders = [
      {
        'orderId': 'ORD-1023',
        'customer': 'Rahul Sharma',
        'status': 'Shipped',
        'date': 'Jul 19, 2025',
      },
      {
        'orderId': 'ORD-1022',
        'customer': 'Anjali Verma',
        'status': 'Out for Delivery',
        'date': 'Jul 19, 2025',
      },
      {
        'orderId': 'ORD-1021',
        'customer': 'Vikram Singh',
        'status': 'Processing',
        'date': 'Jul 18, 2025',
      },
    ];

    Color _getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'shipped':
          return Colors.blue;
        case 'out for delivery':
          return Colors.orange;
        case 'processing':
          return Colors.deepPurple;
        default:
          return Colors.grey;
      }
    }

    return CommonLayout(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: const [
                Icon(Icons.list_alt, size: 24),
                SizedBox(width: 8),
                Text(
                  'Latest Orders',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: latestOrders.length,
              itemBuilder: (context, index) {
                final order = latestOrders[index];
                final status = order['status'] ?? '';
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    tileColor: Colors.white,
                    leading: const Icon(
                      Icons.local_shipping,
                      color: Colors.deepPurple,
                    ),
                    title: Text(order['orderId']!),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['customer']!,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          order['date']!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          status,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(status),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Icon(Icons.arrow_forward_ios, size: 14),
                      ],
                    ),
                    onTap: () {
                      context.go('/orders/track');
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
