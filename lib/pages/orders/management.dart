import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_vendor_app/common/common_layout.dart';
import 'package:my_vendor_app/services/order_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({super.key});

  @override
  State<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;

  String _search = '';
  DateTime? _selectedDate;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        _fetchOrders(); // Optional pagination
      }
    });
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Token missing');

      final dynamic fetched = await OrderService.fetchOrders(token);
      if (fetched is List) {
        setState(() {
          _orders.clear();
          _orders.addAll(fetched.whereType<Map<String, dynamic>>());
        });
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      print('Fetch error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching orders: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredOrders {
    return _orders.where((order) {
      final lowerSearch = _search.toLowerCase();

      final id = order['orderId']?.toString() ?? '';
      final status = order['status']?.toString().toLowerCase() ?? '';
      final total = order['total']?.toString() ?? '';
      final createdAtStr = order['createdAt'] ?? '';
      final createdAt = DateTime.tryParse(createdAtStr) ?? DateTime(2000);
      final items = (order['items'] ?? []) as List<dynamic>;

      final matchesSearch =
          _search.isEmpty ||
          id.contains(_search) ||
          total.contains(_search) ||
          status.contains(lowerSearch) ||
          DateFormat(
            'dd MMM yyyy',
          ).format(createdAt).toLowerCase().contains(lowerSearch) ||
          items.any(
            (item) => (item['product']?['name'] ?? '')
                .toString()
                .toLowerCase()
                .contains(lowerSearch),
          );

      final matchesDate =
          _selectedDate == null ||
          (createdAt.year == _selectedDate!.year &&
              createdAt.month == _selectedDate!.month &&
              createdAt.day == _selectedDate!.day);

      final matchesStatus =
          _selectedStatus == null || status == _selectedStatus!.toLowerCase();

      return matchesSearch && matchesDate && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _filteredOrders.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _filteredOrders.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return _buildOrderCard(_filteredOrders[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: isMobile ? double.infinity : 220,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search Order...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) => setState(() => _search = value),
                ),
              ),
              SizedBox(
                width: isMobile ? double.infinity : 200,
                child: TextField(
                  readOnly: true,
                  controller: TextEditingController(
                    text:
                        _selectedDate == null
                            ? ''
                            : DateFormat('dd MMM yyyy').format(_selectedDate!),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Select Date',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                ),
              ),
              SizedBox(
                width: isMobile ? double.infinity : 200,
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  isDense: true,
                  decoration: const InputDecoration(
                    hintText: 'Filter by Status',
                    prefixIcon: Icon(Icons.filter_alt),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Status')),
                    DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
                    DropdownMenuItem(value: 'SHIPPED', child: Text('Shipped')),
                    DropdownMenuItem(
                      value: 'DELIVERED',
                      child: Text('Delivered'),
                    ),
                    DropdownMenuItem(
                      value: 'RETURNED',
                      child: Text('Returned'),
                    ),
                    DropdownMenuItem(
                      value: 'CANCELLED',
                      child: Text('Cancelled'),
                    ),
                  ],
                  onChanged: (value) => setState(() => _selectedStatus = value),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final items = (order['items'] ?? []) as List<dynamic>;
    final firstItem = items.isNotEmpty ? items.first : null;
    final product = firstItem?['product'] ?? {};
    final productImage =
        (product['images'] != null && product['images'].isNotEmpty)
            ? product['images'][0]['url']
            : null;

    final createdAt =
        DateTime.tryParse(order['createdAt'] ?? '') ?? DateTime.now();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ${order['orderId'] ?? 'N/A'}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy').format(createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => context.go('/orders/view', extra: order),
                  child: const Text(
                    'View',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    image:
                        productImage != null
                            ? DecorationImage(
                              image: NetworkImage(productImage),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  child:
                      productImage == null
                          ? const Icon(
                            Icons.image,
                            size: 30,
                            color: Colors.grey,
                          )
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'] ?? 'Unnamed Product',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Qty: ${firstItem?['quantity'] ?? '-'}',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${order['total']?.toStringAsFixed(0) ?? '--'}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusBadge(order['status']),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color bgColor;
    String text;

    switch (status) {
      case 'PENDING':
        bgColor = Colors.orange;
        text = 'Pending';
        break;
      case 'SHIPPED':
        bgColor = Colors.blue;
        text = 'Shipped';
        break;
      case 'DELIVERED':
        bgColor = Colors.green;
        text = 'Delivered';
        break;
      case 'RETURNED':
        bgColor = Colors.redAccent;
        text = 'Returned';
        break;
      case 'CANCELLED':
        bgColor = Colors.grey;
        text = 'Cancelled';
        break;
      default:
        bgColor = Colors.black26;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: bgColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
