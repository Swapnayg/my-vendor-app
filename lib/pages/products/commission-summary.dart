import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:my_vendor_app/common/common_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommissionSummaryPage extends StatefulWidget {
  const CommissionSummaryPage({super.key});

  @override
  State<CommissionSummaryPage> createState() => _CommissionSummaryPageState();
}

class _CommissionSummaryPageState extends State<CommissionSummaryPage> {
  Map<String, dynamic> reportData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final url = Uri.parse(
      'http://localhost:3000/api/MobileApp/vendor/commission-summary',
    );

    final res = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      setState(() {
        reportData = json.decode(res.body);
        _isLoading = false;
      });
    } else {
      debugPrint("Error fetching report: ${res.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return CommonLayout(
      body: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    "Commission Summary",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              _buildInfoCard(
                "Total Sales",
                "₹${reportData['totalSales'] ?? 0}",
              ),
              _buildInfoCard("Orders", "${reportData['totalOrders'] ?? 0}"),
              _buildInfoCard(
                "New Customers",
                "${reportData['newCustomers'] ?? 0}",
              ),
              _buildInfoCard(
                "Total Commission",
                "₹${reportData['finalTotalCommission'] ?? 0}",
              ),
              const SizedBox(height: 24),
              _buildCommissionChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommissionChart() {
    final trends = reportData['productCommissionTrends'] ?? [];
    final List<Color> productColors = [
      Colors.blue,
      Colors.pink,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.redAccent,
    ];

    if (trends.isEmpty || trends is! List) {
      return const Center(child: Text("No product commission trend data."));
    }

    final List<Color> colors = List.generate(
      trends.length,
      (i) => Colors.grey.shade400,
    );

    final List<BarChartGroupData> bars = [];

    for (int i = 0; i < trends.length; i++) {
      final item = trends[i];
      final commission = (item['totalCommission'] as num?)?.toDouble() ?? 0;

      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: commission,
              color:
                  productColors[i %
                      productColors.length], // Unique color per product
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Product-wise Commission",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 1.5,
          child: BarChart(
            BarChartData(
              barGroups: bars,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= trends.length)
                        return const SizedBox();
                      return Text(
                        trends[index]['name'],
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                    reservedSize: 42,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text("₹${value.toInt()}"),
                    reservedSize: 40,
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(show: false), // ❌ Hide grid lines
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  left: BorderSide(color: Colors.black12),
                  bottom: BorderSide(color: Colors.black12),
                  top: BorderSide.none,
                  right: BorderSide.none,
                ),
              ),
              maxY:
                  trends
                      .map(
                        (e) => (e['totalCommission'] as num?)?.toDouble() ?? 0,
                      )
                      .reduce((a, b) => a > b ? a : b) +
                  10,
            ),
          ),
        ),
      ],
    );
  }
}
