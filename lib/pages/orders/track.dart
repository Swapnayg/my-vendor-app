import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/common/common_layout.dart';
import 'package:http/http.dart' as http;

class OrderTrackPage extends StatefulWidget {
  final String orderId;

  const OrderTrackPage({super.key, required this.orderId});

  @override
  State<OrderTrackPage> createState() => _OrderTrackPageState();
}

class _OrderTrackPageState extends State<OrderTrackPage> {
  Map<String, dynamic>? order;
  bool isLoading = true;
  String orderStatus = '';

  // New loading flags for each button
  bool isApproving = false;
  bool isRejecting = false;
  bool isMarkingShipped = false;
  bool isStartingShipping = false;

  @override
  void initState() {
    super.initState();
    fetchOrder();
  }

  Future<void> approveOrder() async {
    if (isApproving) return;
    setState(() {
      isApproving = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      setState(() => isApproving = false);
      return;
    }

    final idMatch = RegExp(r'\d+').firstMatch(widget.orderId);
    final idOnly = idMatch != null ? int.tryParse(idMatch.group(0)!) : null;

    if (idOnly == null) {
      setState(() {
        isApproving = false;
        isLoading = false;
      });
      return;
    }

    final response = await http.post(
      Uri.parse('http://localhost:3000/api/MobileApp/vendor/app-approve-order'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'orderId': idOnly}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order Approved!')));
      await fetchOrder();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to approve order')));
    }

    setState(() {
      isApproving = false;
    });
  }

  Future<void> rejectOrder() async {
    if (isRejecting) return;
    setState(() {
      isRejecting = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      setState(() => isRejecting = false);
      return;
    }

    final idMatch = RegExp(r'\d+').firstMatch(widget.orderId);
    final idOnly = idMatch != null ? int.tryParse(idMatch.group(0)!) : null;

    if (idOnly == null) {
      setState(() {
        isRejecting = false;
        isLoading = false;
      });
      return;
    }

    final response = await http.post(
      Uri.parse('http://localhost:3000/api/MobileApp/vendor/reject-order'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'orderId': idOnly}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order Rejected!')));
      await fetchOrder();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to reject order')));
    }

    setState(() {
      isRejecting = false;
    });
  }

  Future<void> fetchOrder() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final idMatch = RegExp(r'\d+').firstMatch(widget.orderId);
    final idOnly = idMatch != null ? int.tryParse(idMatch.group(0)!) : null;

    if (idOnly == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final response = await http.post(
      Uri.parse('http://localhost:3000/api/MobileApp/vendor/track'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'id': idOnly}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final fetchedOrder = jsonResponse['data'];
      setState(() {
        order = fetchedOrder;
        orderStatus = (fetchedOrder?['status'] ?? '').toString().toUpperCase();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> markAsShipped() async {
    if (isMarkingShipped) return;
    setState(() {
      isMarkingShipped = true;
    });
    // navigate; if there were async logic, await it here
    context.go('/orders/mark-shipped');
    // no reset needed if navigation leaves page
  }

  Future<void> startShipping() async {
    if (isStartingShipping) return;
    setState(() {
      isStartingShipping = true;
    });
    context.go('/orders/tracking-details');
    // no reset needed if navigation leaves page
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : order == null
              ? const Center(child: Text("Failed to load order details"))
              : Column(
                children: [
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
                                  () => context.go('/orders/latest-orders'),
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
                          label: const Text("Invoice"),
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
                              extra: {'order': order, 'source': 'latest'},
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
                              _labelValue("Order ID:", order!['orderId']),
                              const SizedBox(height: 8),
                              _labelValue(
                                "Payment:",
                                order!['payment'] ?? 'N/A',
                                color: Colors.green,
                              ),
                              const SizedBox(height: 8),
                              _labelValue(
                                "Status:",
                                order!['status'] ?? 'Pending',
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
                                  const Icon(
                                    Icons.place,
                                    size: 18,
                                    color: Colors.deepOrange,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order!['address'] ??
                                              "No address provided",
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        TextButton(
                                          onPressed: () {},
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: const Size(40, 30),
                                            tapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
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
                                children: const [
                                  Icon(
                                    Icons.timer,
                                    size: 18,
                                    color: Colors.deepOrange,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
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
                                "Name: ${order!['customer']['name']}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.email,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    order!['customer']['email'] ?? '',
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(order!['customer']['phone'] ?? ''),
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
                              (order!['items'] as List).length,
                              (index) {
                                final item = order!['items'][index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          item['image'] ??
                                              'https://via.placeholder.com/50',
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (orderStatus == 'PENDING') ...[
                              // Reject Button
                              OutlinedButton(
                                onPressed: isRejecting ? null : rejectOrder,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.orange,
                                  side: BorderSide.none,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 12,
                                  ),
                                ),
                                child:
                                    isRejecting
                                        ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            valueColor: AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                        : const Text("Reject"),
                              ),
                              // Accept Order Button
                              ElevatedButton(
                                onPressed: isApproving ? null : approveOrder,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 12,
                                  ),
                                ),
                                child:
                                    isApproving
                                        ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            valueColor: AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                        : const Text("Accept Order"),
                              ),
                            ],
                            if (orderStatus == 'ACCEPTED') ...[
                              ElevatedButton(
                                onPressed:
                                    isMarkingShipped ? null : markAsShipped,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 12,
                                  ),
                                ),
                                child:
                                    isMarkingShipped
                                        ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            valueColor: AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                        : const Text("Mark as Shipped"),
                              ),
                              OutlinedButton(
                                onPressed:
                                    isStartingShipping ? null : startShipping,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.orange,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 12,
                                  ),
                                ),
                                child:
                                    isStartingShipping
                                        ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            valueColor: AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                        : const Text("Start Shipping"),
                              ),
                            ],
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
