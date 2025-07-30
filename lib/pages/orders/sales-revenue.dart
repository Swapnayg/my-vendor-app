import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/common/common_layout.dart';

class SalesRevenuePage extends StatefulWidget {
  const SalesRevenuePage({super.key});

  @override
  State<SalesRevenuePage> createState() => _SalesRevenuePageState();
}

class _SalesRevenuePageState extends State<SalesRevenuePage> {
  DateTime selectedDate = DateTime.now();
  final dateFormatter = DateFormat('MMM dd, yyyy');
  List<Map<String, dynamic>> salesData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSalesData();
  }

  Future<void> fetchSalesData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token not found');
      }

      final uri = Uri.parse(
        'http://localhost:3000/api/MobileApp/vendor/sales-revenue',
      );

      final res = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List<dynamic> rawData = body['data'] ?? [];

        setState(() {
          salesData =
              rawData.map<Map<String, dynamic>>((item) {
                return {
                  'date': DateTime.parse(item['date']),
                  'ordered': item['ordered'] ?? 0,
                  'cancelled': item['cancelled'] ?? 0,
                  'returned': item['returned'] ?? 0,
                  'delivered': item['delivered'] ?? 0,
                };
              }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data: ${res.body}');
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => isLoading = false);
    }
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
                    // Filters Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              dateFormatter.format(selectedDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime(2023),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() => selectedDate = picked);
                                  await fetchSalesData();
                                }
                              },
                              icon: const Icon(Icons.edit_calendar),
                              label: const Text("Apply Filter"),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Revenue Cards
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _revenueCard(
                          "Total Sales",
                          "₹24,000",
                          Colors.blue.shade50,
                          Colors.blue,
                        ),
                        _revenueCard(
                          "Commission",
                          "₹4,000",
                          Colors.pink.shade50,
                          Colors.pink,
                        ),
                        _revenueCard(
                          "Top Product",
                          "Smart Watch",
                          Colors.green.shade50,
                          Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        _LegendItem(color: Colors.blue, label: "Ordered"),
                        SizedBox(width: 12),
                        _LegendItem(color: Colors.orange, label: "Cancelled"),
                        SizedBox(width: 12),
                        _LegendItem(color: Colors.red, label: "Returned"),
                        SizedBox(width: 12),
                        _LegendItem(color: Colors.green, label: "Delivered"),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Chart
                    AspectRatio(
                      aspectRatio: 1.6,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < salesData.length) {
                                    final date =
                                        salesData[index]['date'] as DateTime;
                                    return Text(
                                      DateFormat('E').format(date),
                                      style: const TextStyle(fontSize: 12),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    "${(value / 1000).toStringAsFixed(0)}k",
                                    style: const TextStyle(fontSize: 12),
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
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: false),
                          barGroups: List.generate(salesData.length, (index) {
                            final day = salesData[index];
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: (day['ordered'] as num).toDouble(),
                                  color: Colors.blue,
                                  width: 8,
                                ),
                                BarChartRodData(
                                  toY: (day['cancelled'] as num).toDouble(),
                                  color: Colors.orange,
                                  width: 8,
                                ),
                                BarChartRodData(
                                  toY: (day['returned'] as num).toDouble(),
                                  color: Colors.red,
                                  width: 8,
                                ),
                                BarChartRodData(
                                  toY: (day['delivered'] as num).toDouble(),
                                  color: Colors.green,
                                  width: 8,
                                ),
                              ],
                              barsSpace: 4,
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _revenueCard(
    String title,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14, color: textColor)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 14, height: 14, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
