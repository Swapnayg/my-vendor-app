import 'package:flutter/material.dart';
import '/common/common_layout.dart';
import 'package:go_router/go_router.dart';

class OrderTrackPage extends StatelessWidget {
  final String orderId;

  const OrderTrackPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final mockOrder = {
      'orderId': '#MDX789012345',
      'status': 'Pending',
      'payment': 'Paid',
      'createdAt': '2025-07-22T10:30:00',
      'vendor': {'businessName': 'Smart Workspaces Inc.'},
      'customer': {
        'name': 'Eleanor Vance',
        'email': 'eleanor.vance@example.com',
        'phone': '+1 (555) 123-4567',
      },
      'items': [
        {
          'name': 'Ergonomic Office Chair Pro',
          'quantity': 1,
          'price': 299.99,
          'image': 'assets/images/upload.png',
        },
        {
          'name': 'Wireless Mechanical Keyboard',
          'quantity': 1,
          'price': 129.99,
          'image': 'assets/images/upload.png',
        },
      ],
    };

    return CommonLayout(
      body: Column(
        children: [
          // Top Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed:
                          () => context.go(
                            '/orders/latest-orders',
                            extra: {'orderId': orderId},
                          ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "Order Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text("Invoice", style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    context.go(
                      '/orders/invoice',
                      extra: {'order': mockOrder, 'source': 'latest'},
                    );
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionCard(
                  title: "Order Summary",
                  icon: Icons.receipt_long,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _labelValue("Order ID:", mockOrder['orderId'].toString()),
                      const SizedBox(height: 8),
                      _labelValue(
                        "Payment:",
                        mockOrder['payment'].toString(),
                        color: Colors.green,
                      ),
                      const SizedBox(height: 8),
                      _labelValue(
                        "Status:",
                        mockOrder['status'].toString(),
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionCard(
                  title: "Delivery Details",
                  icon: Icons.location_on,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.place, size: 18, color: Colors.deepOrange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "201 Orchard Road,\n#01-10, Singapore",
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                TextButton(
                                  onPressed: () {
                                    // Future functionality: Change address
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(40, 30),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    "Change address",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.timer, size: 18, color: Colors.deepOrange),
                          const SizedBox(width: 8),
                          const Text(
                            "Estimated delivery in 25 mins",
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionCard(
                  title: "Customer Information",
                  icon: Icons.person,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Name: ${(mockOrder['customer'] as Map)['name']}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.email, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            (mockOrder['customer'] as Map)['email'],
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text((mockOrder['customer'] as Map)['phone']),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _sectionCard(
                  title: "Items List",
                  icon: Icons.inventory_2,
                  child: Column(
                    children: List.generate(
                      (mockOrder['items'] as List).length,
                      (index) {
                        final item = (mockOrder['items'] as List)[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  item['image'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Qty: ${item['quantity']}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "₹${item['price']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.orange,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                      child: const Text("Reject"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.go('/orders/mark-shipped');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                      child: const Text("Accept Order"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.go('/orders/mark-shipped');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                      child: const Text("Mark as Shipped"),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        context.go('/orders/tracking-details');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.orange,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                      child: const Text("Start Shipping"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.deepOrange),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _labelValue(String label, String value, {Color? color}) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: (color ?? Colors.grey[200])?.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: TextStyle(color: color ?? Colors.black87, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
