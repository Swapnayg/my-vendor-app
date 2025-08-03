import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../common/common_layout.dart';
import '../theme/colors.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> overviewStats = [];
  List<dynamic> recentNotifications = [];
  List<dynamic> latestOrders = [];
  bool isLoading = true;

  List<double> weeklySales = [];
  List<double> weeklySecondarySales = [];
  List<Map<String, dynamic>> topProducts = [];
  List<int> userGrowth = [];

  final List<String> weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  void initState() {
    super.initState();
    fetchHomeData();
    fetchChartData();
  }

  Future<void> fetchChartData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final uri = Uri.parse(
      'http://localhost:3000/api/MobileApp/vendor/chart-data',
    );

    try {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final sales = List<Map<String, dynamic>>.from(data['weeklySales']);
        final products = List<Map<String, dynamic>>.from(data['topProducts']);
        final users = List<int>.from(data['userGrowth'] ?? []);

        setState(() {
          weeklySales =
              sales.map((e) => (e['amount'] as num).toDouble()).toList();

          // If no secondary sales data, just make it zero-filled to preserve bar chart structure
          weeklySecondarySales = List.filled(weeklySales.length, 0);

          topProducts = products;
          userGrowth = users;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load chart data');
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> fetchHomeData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse(
      "http://localhost:3000/api/MobileApp/vendor/main-details",
    );

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        overviewStats = data['data']['overviewStats'] ?? [];
        recentNotifications = data['data']['recentNotifications'] ?? [];
        latestOrders = data['data']['latestOrders'] ?? [];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      debugPrint('Error fetching home data: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final crossAxisCount = isMobile ? 2 : 4;
    final itemWidth = (MediaQuery.of(context).size.width - 48) / crossAxisCount;

    return CommonLayout(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Overview",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(overviewStats.length, (index) {
                        final stat = overviewStats[index];
                        final color = _cardColors[index % _cardColors.length];
                        return _overviewCard(
                          stat['icon'],
                          stat['label'],
                          stat['value'],
                          stat['growth'],
                          color,
                          width: itemWidth,
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // CHARTS SECTION
                    _buildWeeklySalesChart(),
                    const SizedBox(height: 24),
                    _buildTopProductsChart(),
                    const SizedBox(height: 24),
                    _buildUserGrowthChart(),
                    const SizedBox(height: 24),

                    const Text(
                      "Recent Notifications",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...recentNotifications.map((n) {
                      return _notificationTile(
                        n['iconName'],
                        n['title'],
                        n['message'],
                        n['time'],
                        isNew: n['isNew'] ?? false,
                      );
                    }),
                    const SizedBox(height: 24),
                    const Text(
                      "Latest Orders",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...latestOrders.map((o) {
                      return _orderTile(
                        o['initials'],
                        o['orderId'],
                        o['customerName'],
                        o['amount'].toString(),
                        o['status'],
                        o['date'],
                      );
                    }),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
    );
  }

  static final List<Color> _cardColors = [
    AppColors.primary.withOpacity(0.1),
    AppColors.pink.withOpacity(0.1),
    AppColors.yellow.withOpacity(0.1),
    AppColors.orange.withOpacity(0.1),
    AppColors.green.withOpacity(0.1),
  ];

  Widget _overviewCard(
    String iconName,
    String label,
    String value,
    String growth,
    Color color, {
    required double width,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shopping_cart, color: Colors.black54), // Adjust if needed
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text("↑ $growth", style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _notificationTile(
    String iconName,
    String title,
    String subtitle,
    String time, {
    bool isNew = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Icon(Icons.notifications, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time.split('T')[0], style: const TextStyle(fontSize: 12)),
              if (isNew)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Chip(
                    label: Text(
                      "New",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Colors.orange,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    shape: StadiumBorder(side: BorderSide.none),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _orderTile(
    String initials,
    String orderId,
    String name,
    String amount,
    String status,
    String date,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.pink,
            child: Text(initials, style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderId,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(name, style: const TextStyle(color: Colors.black87)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 16,
                ),
              ),
              Text(
                status,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                date,
                style: const TextStyle(fontSize: 11, color: Colors.black38),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySalesChart() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Weekly Sales Overview",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  barGroups: List.generate(weeklySales.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: weeklySales[i],
                          color: Colors.blue,
                          width: 10,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        BarChartRodData(
                          toY: weeklySecondarySales[i],
                          color: Colors.orange,
                          width: 10,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    );
                  }),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.black87,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          "${rodIndex == 0 ? 'Primary' : 'Secondary'}: ₹${rod.toY.toStringAsFixed(0)}",
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              weekDays[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductsChart() {
    final productSpots = List.generate(
      topProducts.length,
      (i) => FlSpot(i.toDouble(), (topProducts[i]['sales'] as num).toDouble()),
    );
    final productNames = topProducts.map((e) => e['name'].toString()).toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Top 5 Products",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: productSpots,
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.cyan,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.cyan.withOpacity(0.4),
                      ),
                    ),
                  ],
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < productNames.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                productNames[index],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserGrowthChart() {
    final spots = List.generate(
      userGrowth.length,
      (i) => FlSpot(i.toDouble(), userGrowth[i].toDouble()),
    );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "User Growth",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,
                      color: const Color(0xFF20B2AA),
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF20B2AA).withOpacity(0.2),
                      ),
                    ),
                  ],
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              weekDays[index],
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget:
                            (value, meta) => Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            ),
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
