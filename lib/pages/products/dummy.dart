import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:my_vendor_app/common/common_layout.dart';
import 'package:my_vendor_app/models/order.dart';
import 'package:my_vendor_app/models/order_item.dart';
import 'package:my_vendor_app/theme/colors.dart';

class CommissionSummaryPage extends StatefulWidget {
  const CommissionSummaryPage({super.key});

  @override
  State<CommissionSummaryPage> createState() => _CommissionSummaryPageState();
}

class _CommissionSummaryPageState extends State<CommissionSummaryPage> {
  late DateTime _fromDate;
  late DateTime _toDate;
  late List<Order> _orders;

  @override
  void initState() {
    super.initState();
    _fromDate = DateTime.now().subtract(const Duration(days: 30));
    _toDate = DateTime.now();
    _orders = _getMockOrders();
  }

  void _openDateFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _buildFilterSheet(),
    );
  }

  Widget _buildFilterSheet() {
    DateTime tempFrom = _fromDate;
    DateTime tempTo = _toDate;

    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: BoxDecoration(
        color: AppColors.pink.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Commission Filter',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          _buildDatePicker('From Date', tempFrom, (date) => tempFrom = date),
          const SizedBox(height: 12),
          _buildDatePicker('To Date', tempTo, (date) => tempTo = date),
          const Spacer(),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {
                setState(() {
                  _fromDate = tempFrom;
                  _toDate = tempTo;
                  _orders =
                      _getMockOrders()
                          .where(
                            (o) =>
                                o.createdAt.isAfter(
                                  _fromDate.subtract(const Duration(days: 1)),
                                ) &&
                                o.createdAt.isBefore(
                                  _toDate.add(const Duration(days: 1)),
                                ),
                          )
                          .toList();
                });
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime selectedDate,
    Function(DateTime) onDateChanged,
  ) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        TextButton.icon(
          icon: const Icon(Icons.calendar_today_outlined, size: 18),
          label: Text(DateFormat('MMMM dd, yyyy').format(selectedDate)),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) onDateChanged(picked);
          },
        ),
      ],
    );
  }

  double get totalCommission => _orders
      .expand((o) => o.items ?? [])
      .fold(0.0, (sum, item) => sum + (item.commissionAmt ?? 0));
  int get totalOrders => _orders.length;

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 8),
                    const Text(
                      'Commission Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        _openDateFilter;
                      },
                      icon: const Icon(Icons.filter_alt, color: Colors.white),
                      label: const Text(
                        'Filter',
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
              ],
            ),
          ),

          const Divider(height: 32),
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildCommissionCard(),
              const SizedBox(height: 16),
              _buildStatSummary(),
              const SizedBox(height: 16),
              _buildCommissionChart(),
              const SizedBox(height: 16),
              const Text(
                "Recent Orders",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ..._orders.map(_buildOrderTile).toList(),
              const SizedBox(height: 16),
              _buildTipsCard(),
              const SizedBox(height: 16),
              _buildPartnersRow(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Commission', style: TextStyle(color: Colors.white)),
          const SizedBox(height: 6),
          Text(
            '₹${totalCommission.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'As of ${DateFormat('MMMM dd, yyyy').format(_toDate)}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildStatSummary() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryBox(
            "Current Rate",
            "10%",
            "Across all sales",
            bgColor: AppColors.yellow.withOpacity(0.3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryBox(
            "Total Orders",
            "$totalOrders",
            "Completed this month",
            bgColor: AppColors.green.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryBox(
    String title,
    String value,
    String subtitle, {
    Color? bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionChart() {
    final grouped = <String, double>{};

    for (var order in _orders) {
      final dateKey = DateFormat('dd MMM').format(order.createdAt);
      final total =
          order.items?.fold(
            0.0,
            (sum, item) => sum + (item.commissionAmt ?? 0),
          ) ??
          0.0;
      grouped[dateKey] = (grouped[dateKey] ?? 0) + total;
    }

    final sortedEntries =
        grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    final averageCommission =
        sortedEntries.isNotEmpty
            ? sortedEntries.map((e) => e.value).reduce((a, b) => a + b) /
                sortedEntries.length
            : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Commission Chart',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.black87,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = sortedEntries[groupIndex].key;
                      final amount = rod.toY.toStringAsFixed(2);
                      return BarTooltipItem(
                        '$label\n₹$amount',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < sortedEntries.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              sortedEntries[index].key,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₹${value.toInt()}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  sortedEntries.length,
                  (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: sortedEntries[i].value,
                        color: AppColors.primary,
                        width: 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: averageCommission,
                      color: AppColors.pink,
                      strokeWidth: 2,
                      dashArray: [4, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topLeft,
                        labelResolver:
                            (_) =>
                                'Avg: ₹${averageCommission.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.pink,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTile(Order order) {
    final totalCommission =
        order.items?.fold<double>(
          0.0,
          (sum, item) => sum + (item.commissionAmt ?? 0),
        ) ??
        0.0;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(
            Icons.receipt_long_outlined,
            color: AppColors.primary,
          ),
        ),
        title: Text("Order #${order.id}"),
        subtitle: Text(DateFormat('MMM dd, yyyy').format(order.createdAt)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '₹${totalCommission.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                "10%",
                style: TextStyle(fontSize: 12, color: AppColors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.yellow.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.orange),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Discover strategies to boost your commission rate.",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text("Learn More"),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnersRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Our Partners",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            5,
            (i) => CircleAvatar(
              backgroundColor: AppColors.green.withOpacity(0.2),
              radius: 22,
            ),
          ),
        ),
      ],
    );
  }

  List<Order> _getMockOrders() {
    return List.generate(5, (index) {
      return Order(
        id: 1001 + index,
        customerId: 1,
        vendorId: 1,
        status: OrderStatus.DELIVERED,
        subTotal: 100,
        taxTotal: 10,
        shippingCharge: 0,
        total: 110,
        createdAt: _toDate.subtract(Duration(days: index + 1)),
        items: [
          OrderItem(
            id: index,
            orderId: 1001 + index,
            productId: 1,
            quantity: 1,
            basePrice: 100,
            taxRate: 10,
            taxAmount: 10,
            price: 110,
            commissionAmt: [100, 200, 150, 50, 300][index].toDouble(),
            commissionPct: 10,
            product: null,
          ),
        ],
        vendor: null,
        customer: null,
        user: null,
        payment: null,
        shippingSnapshot: null,
      );
    });
  }
}
