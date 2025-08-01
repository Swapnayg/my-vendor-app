// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_vendor_app/common/common_layout.dart';
import 'package:my_vendor_app/models/order.dart';
import 'package:my_vendor_app/theme/colors.dart';

class CommissionSummaryPage extends StatefulWidget {
  const CommissionSummaryPage({super.key});

  @override
  State<CommissionSummaryPage> createState() => _CommissionSummaryPageState();
}

class _CommissionSummaryPageState extends State<CommissionSummaryPage> {
  bool _isLoading = true;
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('vendor_token');

    final res = await http.get(
      Uri.parse(
        'http://localhost:3000/api/MobileApp/vendor/commission-summary',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      setState(() {
        _orders = data.map((json) => Order.fromJson(json)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCommissionChart(),
                    const SizedBox(height: 20),
                    _buildProductDateWiseLineChart(),
                    const SizedBox(height: 20),
                    const Text(
                      "Recent Orders",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _orders.isEmpty
                        ? _buildNoDataCard("No recent orders")
                        : Column(
                          children: _orders.map(_buildOrderTile).toList(),
                        ),
                  ],
                ),
              ),
    );
  }

  Widget _buildCommissionChart() {
    final grouped = <String, double>{};

    for (var order in _orders) {
      final dateKey = DateFormat('dd MMM').format(order.createdAt);
      final total = order.items.fold(
        0.0,
        (sum, item) => sum + (item.commissionAmt ?? 0),
      );
      grouped[dateKey] = (grouped[dateKey] ?? 0) + total;
    }

    if (grouped.isEmpty) {
      return _buildNoDataCard("No commission data available");
    }

    final sorted =
        grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final averageCommission =
        sorted.map((e) => e.value).reduce((a, b) => a + b) / sorted.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Commission Chart",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index >= 0 && index < sorted.length) {
                          return Text(
                            sorted[index].key,
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 50,
                    ),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(sorted.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: sorted[index].value,
                        color: AppColors.primary,
                        width: 18,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: averageCommission,
                      color: Colors.redAccent,
                      strokeWidth: 1,
                      dashArray: [5, 5],
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

  Widget _buildProductDateWiseLineChart() {
    final Map<String, Map<String, double>> grouped = {};

    for (var order in _orders) {
      final date = DateFormat('dd MMM').format(order.createdAt);
      for (var item in order.items) {
        final key = item.product!.name;
        if (key == null) continue;
        grouped[key] = grouped[key] ?? {};
        grouped[key]![date] =
            (grouped[key]![date] ?? 0) + (item.commissionAmt ?? 0);
      }
    }

    if (grouped.isEmpty) {
      return _buildNoDataCard("No product-wise commission data");
    }

    final allDates = <String>{};
    for (var map in grouped.values) {
      allDates.addAll(map.keys);
    }
    final sortedDates = allDates.toList()..sort();

    final xInterval =
        (sortedDates.length <= 1)
            ? 1.0
            : (sortedDates.length / 5).ceilToDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Product-Wise Commission",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                minY: 0,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: xInterval,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index >= 0 && index < sortedDates.length) {
                          return Text(
                            sortedDates[index],
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 50,
                    ),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
                lineBarsData:
                    grouped.entries.map((entry) {
                      final color =
                          Colors.primaries[entry.key.hashCode %
                              Colors.primaries.length];
                      return LineChartBarData(
                        isCurved: true,
                        color: color,
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                        spots:
                            sortedDates.asMap().entries.map((e) {
                              final date = e.value;
                              final y = entry.value[date] ?? 0;
                              return FlSpot(e.key.toDouble(), y);
                            }).toList(),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTile(Order order) {
    final totalCommission = order.items.fold(
      0.0,
      (sum, item) => sum + (item.commissionAmt ?? 0),
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order ID: ${order.id}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text("Date: ${DateFormat.yMMMd().format(order.createdAt)}"),
          const SizedBox(height: 4),
          Text("Commission: ₹${totalCommission.toStringAsFixed(2)}"),
        ],
      ),
    );
  }

  Widget _buildNoDataCard(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
      ],
    );
  }
}
