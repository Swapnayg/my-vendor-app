import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_vendor_app/models/order_item.dart';
import 'package:my_vendor_app/models/product.dart';
import '/models/order.dart'; // Adjust this import based on your actual path

class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({super.key});

  @override
  State<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  final ScrollController _scrollController = ScrollController();
  final List<Order> _orders = [];
  bool _isLoading = false;

  String _search = '';
  DateTimeRange? _dateRange;
  OrderStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        _fetchOrders();
      }
    });
  }

  void _fetchOrders() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Mock network delay

    final newOrders = List.generate(10, (i) {
      final orderId = i + _orders.length + 1000;

      return Order(
        id: orderId,
        customerId: 1,
        vendorId: 2,
        status: OrderStatus.values[i % OrderStatus.values.length],
        subTotal: 100.0 + i,
        taxTotal: 10.0,
        shippingCharge: 5.0,
        total: 115.0 + i,
        createdAt: DateTime.now().subtract(Duration(days: i * 2)),
        items: [
          OrderItem(
            id: i * 10,
            orderId: orderId,
            productId: i,
            quantity: 2 + i,
            basePrice: 50.0,
            taxRate: 0.1,
            taxAmount: 5.0,
            price: 55.0,
            product: Product(
              id: i,
              name: 'Product ${i + 1}',
              image:
                  'https://source.unsplash.com/random/200x200?sig=$i&product', // random image
            ),
          ),
          // You can add more items here if needed
        ],
        payment: null,
      );
    });

    setState(() {
      _orders.addAll(newOrders);
      _isLoading = false;
    });
  }

  List<Order> get _filteredOrders {
    return _orders.where((order) {
      final lowerSearch = _search.toLowerCase();

      final matchesSearch =
          _search.isEmpty ||
          order.id.toString().contains(_search) ||
          order.total.toString().contains(_search) ||
          order.status.name.toLowerCase().contains(lowerSearch) ||
          DateFormat(
            'dd MMM yyyy',
          ).format(order.createdAt).toLowerCase().contains(lowerSearch) ||
          order.items!.any(
            (item) => item.product!.name.toLowerCase().contains(lowerSearch),
          );

      final matchesDate =
          _dateRange == null ||
          (order.createdAt.isAfter(
                _dateRange!.start.subtract(const Duration(days: 1)),
              ) &&
              order.createdAt.isBefore(
                _dateRange!.end.add(const Duration(days: 1)),
              ));
      final matchesStatus =
          _selectedStatus == null || order.status == _selectedStatus;
      return matchesSearch && matchesDate && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Management')),
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
                final order = _filteredOrders[index];
                return _buildOrderCard(order);
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
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // Search Field
              SizedBox(
                width: constraints.maxWidth < 500 ? constraints.maxWidth : 200,
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

              // Date Range Picker
              SizedBox(
                width: constraints.maxWidth < 500 ? constraints.maxWidth : 220,
                child: TextField(
                  readOnly: true,
                  controller: TextEditingController(
                    text:
                        _dateRange == null
                            ? ''
                            : '${DateFormat('dd MMM yyyy').format(_dateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_dateRange!.end)}',
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Select Date Range',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onTap: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _dateRange = picked);
                    }
                  },
                ),
              ),

              // Status Filter
              SizedBox(
                width: constraints.maxWidth < 500 ? constraints.maxWidth : 180,
                child: DropdownButtonFormField<OrderStatus?>(
                  value: _selectedStatus,
                  isDense: true,
                  decoration: const InputDecoration(
                    hintText: 'Filter by Status',
                    prefixIcon: Icon(Icons.filter_alt),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Status'),
                    ),
                    ...OrderStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(orderStatusToString(status)),
                      );
                    }),
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

  Widget _buildOrderCard(Order order) {
    final firstItem =
        order.items?.isNotEmpty == true ? order.items!.first : null;
    final product = firstItem?.product;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID, Date and View
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy').format(order.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'View',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Product row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    image:
                        product?.image != null
                            ? DecorationImage(
                              image: NetworkImage(product!.image!),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  child:
                      product?.image == null
                          ? const Icon(
                            Icons.image,
                            size: 30,
                            color: Colors.grey,
                          )
                          : null,
                ),
                const SizedBox(width: 12),

                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product?.name ?? 'Unnamed Product',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Qty: ${firstItem?.quantity ?? '-'}',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Price
                Text(
                  '₹${order.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Status badge
            _buildStatusBadge(order.status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    final label = orderStatusToString(status);
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING:
        return Colors.orange;
      case OrderStatus.SHIPPED:
        return Colors.blue;
      case OrderStatus.DELIVERED:
        return Colors.green;
      case OrderStatus.RETURNED:
        return Colors.red;
      case OrderStatus.CANCELLED:
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
