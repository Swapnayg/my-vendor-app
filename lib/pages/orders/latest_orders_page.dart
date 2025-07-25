import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/common/common_layout.dart';
import '/services/api_service.dart'; // assume this is your shared API service

class LatestOrdersPage extends StatefulWidget {
  const LatestOrdersPage({super.key});

  @override
  State<LatestOrdersPage> createState() => _LatestOrdersPageState();
}

class _LatestOrdersPageState extends State<LatestOrdersPage> {
  List<dynamic> latestOrders = [];
  bool isLoading = true;
  String token = ''; // replace with your token fetch logic

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token not found');
      }

      final api = ApiService(token: token);
      final res = await api.get('vendor/lattest-orders');

      if (res != null && res['data'] != null) {
        setState(() {
          latestOrders = res['data'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching latest orders: $e');
      setState(() => isLoading = false);
    }
  }

  Color getStatusColor(String status) {
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

  @override
  Widget build(BuildContext context) {
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
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
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
                            title: Text(order['orderId'] ?? 'Unknown ID'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order['customerName'] ?? 'Unknown Customer',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  order['orderDate'] ?? '',
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
                                    color: getStatusColor(status),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Icon(Icons.arrow_forward_ios, size: 14),
                              ],
                            ),
                            onTap: () {
                              context.go(
                                '/orders/track',
                                extra: {'orderId': order['orderId']},
                              );
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
