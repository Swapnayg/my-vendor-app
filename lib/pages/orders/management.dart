import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_vendor_app/common/common_layout.dart';
import 'package:my_vendor_app/models/order_item.dart';
import 'package:my_vendor_app/models/payment.dart';
import 'package:my_vendor_app/models/product.dart';
import 'package:my_vendor_app/models/product_image.dart';
import '/models/order.dart'; // Adjust this import based on your actual path
import 'package:go_router/go_router.dart';

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
  DateTime? _selectedDate;

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

      // Generate 3 mock images per product
      final List<ProductImage> images = List.generate(3, (j) {
        return ProductImage(
          id: j,
          url: 'https://source.unsplash.com/random/200x200?sig=${i * 10 + j}',
          productId: i,
          createdAt: DateTime.now().subtract(Duration(minutes: j * 10)),
        );
      });

      images.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final latestImageUrl = images.first.url;

      final product = Product(
        id: i,
        name: 'Product ${i + 1}',
        images: images,
        description: '',
        price: 0.0,
        basePrice: 0.0,
        taxRate: 0.0,
        stock: 100,
        vendorId: 1,
        status: ProductStatus.approved,
        createdAt: DateTime.now().subtract(Duration(days: i * 2)),
        updatedAt: DateTime.now().subtract(Duration(days: i * 2)),
      );

      return Order(
        id: orderId,
        customerId: 1,
        vendorId: 2,
        payment: Payment(
          id: orderId,
          orderId: orderId,
          amount: 100.0 + i,
          method: 'Cash',
          createdAt: DateTime.now().subtract(Duration(days: i * 2)),
          status: PaymentStatus.PAID,
        ),
        vendor: {'businessName': 'Vendor ${i + 1}'},
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
            product: product,
          ),
        ],

        customer: {
          'name': 'Customer ${i + 1}',
          'email': 'customer${i + 1}@example.com',
          'phone': '+91 90000${i + 1000}',
        },
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
          _selectedDate == null ||
          (order.createdAt.year == _selectedDate!.year &&
              order.createdAt.month == _selectedDate!.month &&
              order.createdAt.day == _selectedDate!.day);

      final matchesStatus =
          _selectedStatus == null || order.status == _selectedStatus;

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
          final isMobile = constraints.maxWidth < 600;

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.start,
            children: [
              // Search Field
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : 220,
                ),
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

              // Single Date Picker
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : 200,
                ),
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
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() => _selectedDate = pickedDate);
                    }
                  },
                ),
              ),

              // Status Filter
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : 200,
                ),
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
    final productImage =
        product?.images.isNotEmpty == true ? product!.images.first.url : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID, Date, View Button
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
                  onPressed: () {
                    // TODO: Navigate to order details
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: TextButton(
                    onPressed: () {
                      context.go('/orders/view', extra: order);
                    },
                    child: const Text(
                      'View',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Product Info Row
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

                // Product name and qty
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

                // Total price
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

            // Order status badge
            _buildStatusBadge(order.status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color bgColor;
    String text;

    switch (status) {
      case OrderStatus.PENDING:
        bgColor = Colors.orange;
        text = 'Pending';
        break;
      case OrderStatus.SHIPPED:
        bgColor = Colors.blue;
        text = 'Shipped';
        break;
      case OrderStatus.DELIVERED:
        bgColor = Colors.green;
        text = 'Delivered';
        break;
      case OrderStatus.RETURNED:
        bgColor = Colors.redAccent;
        text = 'Returned';
        break;
      case OrderStatus.CANCELLED:
        bgColor = Colors.grey;
        text = 'Cancelled';
        break;
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
