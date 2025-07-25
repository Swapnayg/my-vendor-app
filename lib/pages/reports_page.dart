import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/common_layout.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String selectedMonth = 'July';
  int selectedYear = 2025;
  bool isLoading = true;

  String totalSales = '₹0';
  int ordersThisMonth = 0;
  int newCustomers = 0;
  String topProduct = 'N/A';
  List<dynamic> monthlySalesTrends = [];
  List<dynamic> recentOrders = [];
  List<dynamic> partners = [];

  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final List<int> years = [2024, 2025];

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    final int monthIndex = months.indexOf(selectedMonth) + 1;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception("Token not found");
    }
    final url = Uri.parse(
      'https://vendor-admin-portal.netlify.app/api/MobileApp/vendor/reports?month=$monthIndex&year=$selectedYear',
    );
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final report = data['data'];

      setState(() {
        totalSales = report['totalSales'];
        ordersThisMonth = report['ordersThisMonth'];
        newCustomers = report['newCustomers'];
        topProduct = report['topProduct'];
        monthlySalesTrends = report['monthlySalesTrends'];
        recentOrders = report['recentOrders'];
        partners = report['partners'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  List<BarChartGroupData> getBarGroups() {
    return List.generate(monthlySalesTrends.length, (index) {
      final item = monthlySalesTrends[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (item['blue'] ?? 0).toDouble(),
            color: Colors.blue,
            width: 10,
          ),
          BarChartRodData(
            toY: (item['pink'] ?? 0).toDouble(),
            color: Colors.pink,
            width: 10,
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return CommonLayout(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header & Filters
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Key Metrics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            DropdownButton<String>(
                              value: selectedMonth,
                              items:
                                  months
                                      .map(
                                        (m) => DropdownMenuItem(
                                          value: m,
                                          child: Text(m),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (v) => setState(() {
                                    selectedMonth = v!;
                                    isLoading = true;
                                    fetchReports();
                                  }),
                            ),
                            const SizedBox(width: 10),
                            DropdownButton<int>(
                              value: selectedYear,
                              items:
                                  years
                                      .map(
                                        (y) => DropdownMenuItem(
                                          value: y,
                                          child: Text('$y'),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (v) => setState(() {
                                    selectedYear = v!;
                                    isLoading = true;
                                    fetchReports();
                                  }),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Metrics
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isMobile ? 2 : 4,
                      shrinkWrap: true,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _metricCard(
                          'Total Sales',
                          totalSales,
                          const Color(0xFFFFDDEE),
                        ),
                        _metricCard(
                          'Orders This Month',
                          '$ordersThisMonth',
                          const Color(0xFFEEF0FF),
                        ),
                        _metricCard(
                          'Top Product',
                          topProduct,
                          const Color(0xFFE5FFF1),
                        ),
                        _metricCard(
                          'New Customers',
                          '$newCustomers',
                          const Color(0xFFFFF6DD),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Monthly Sales Chart
                    const Text(
                      'Monthly Sales Trends',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AspectRatio(
                      aspectRatio: 1.7,
                      child: BarChart(
                        BarChartData(
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget:
                                    (value, _) => Text('W${value.toInt() + 1}'),
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          barGroups: getBarGroups(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Recent Orders
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Orders',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/orders/management'),
                          child: const Text(
                            'View All',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...recentOrders.map(
                      (o) => _orderTile(
                        o['customer'] ?? 'Unknown',
                        o['id'],
                        o['status'],
                        o['amount'],
                        timeAgo(DateTime.parse(o['createdAt'])),
                        o['status'] == 'Completed'
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Partners
                    const Text(
                      'Our Key Partners',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: isMobile ? 2 : 4,
                      shrinkWrap: true,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.5,
                      children:
                          partners.map((p) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.network(
                                p['logo'],
                                fit: BoxFit.contain,
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _metricCard(String title, String value, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _orderTile(
    String name,
    String orderId,
    String status,
    String amount,
    String timeAgo,
    Color statusColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '$orderId · $status',
                  style: TextStyle(color: statusColor),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(timeAgo, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    return '${diff.inDays} days ago';
  }
}
