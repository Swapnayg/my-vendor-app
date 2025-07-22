import 'package:flutter/material.dart';
import '/common/common_layout.dart';
import 'package:go_router/go_router.dart';

class OrderTrackPage extends StatelessWidget {
  const OrderTrackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mockOrder = {
  'orderId': '#MDX789012345',
  'status': 'Pending',
  'payment': 'Paid',
  'date': '2025-07-22T10:30:00',
  'vendor': {
    'businessName': 'Smart Workspaces Inc.',
  },
  'customer': {
    'name': 'Eleanor Vance',
    'email': 'eleanor.vance@example.com',
    'phone': '+1 (555) 123-4567',
  },
  'items': [
    {
      'name': 'Ergonomic Office Chair Pro',
      'qty': 1,
      'price': 299.99,
      'image': 'assets/images/upload.png',
    },
    {
      'name': 'Wireless Mechanical Keyboard',
      'qty': 1,
      'price': 129.99,
      'image': 'assets/images/upload.png',
    },
  ],
};

    return CommonLayout(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        context.go('/orders/latest-orders');
                      },
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    context.go('/orders/invoice', extra: mockOrder);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _sectionCard(
                  title: "Order Summary",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _labelValue("Order ID:", mockOrder['orderId'].toString()),
                      const SizedBox(height: 6),
                      _labelValue(
                        "Payment:",
                        mockOrder['payment'].toString(),
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(height: 6),
                      _labelValue(
                        "Status:",
                        mockOrder['status'].toString(),
                        color: Colors.orange.shade700,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _sectionCard(
                  title: "Customer Information",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Name:  ${(mockOrder['customer'] as Map<String, dynamic>)['name']}",
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.email, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            (mockOrder['customer']
                                as Map<String, dynamic>)['email'],
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            (mockOrder['customer']
                                as Map<String, dynamic>)['phone'],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _sectionCard(
                  title: "Items List",
                  child: Column(
                    children: List.generate(
                      ((mockOrder['items'] as List?)?.length ?? 0),
                      (index) {
                        final item = (mockOrder['items'] as List)[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: AssetImage(item['image']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "Qty: ${item['qty']}",
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
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Reject Button
                    OutlinedButton(
                      onPressed: () {
                        // Reject logic (confirmation optional)
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.orange,
                        side: BorderSide.none,
                      ),
                      child: const Text("Reject"),
                    ),

                    // Accept Order Button
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to Mark as Shipped after accepting
                        context.go('/orders/mark-shipped');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Accept Order"),
                    ),

                    // Mark as Shipped Button
                    ElevatedButton(
                      onPressed: () {
                        context.go('/orders/mark-shipped');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Mark as Shipped"),
                    ),

                    // Start Shipping Button
                    OutlinedButton(
                      onPressed: () {
                        context.go('/orders/tracking-details');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.orange,
                        side: BorderSide.none,
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

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                title.contains("Order")
                    ? Icons.receipt_long
                    : title.contains("Customer")
                    ? Icons.person
                    : Icons.inventory_2,
                size: 18,
                color: Colors.grey[700],
              ),
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
            color: (color ?? Colors.grey[200])?.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: TextStyle(color: color ?? Colors.black, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
