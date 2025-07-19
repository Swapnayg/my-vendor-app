import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../data/chart_mock_data.dart'; // ✅ Import mock data

class SalesOverviewChart extends StatelessWidget {
  const SalesOverviewChart({super.key});

  @override
  Widget build(BuildContext context) {
    final spots =
        mockOrders.asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.amount);
        }).toList();

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
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,
                      color: AppColors.primary,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TopProductsChart extends StatelessWidget {
  const TopProductsChart({super.key});

  @override
  Widget build(BuildContext context) {
    final barGroups =
        mockProducts.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.sales.toDouble(),
                color: AppColors.primary,
              ),
            ],
          );
        }).toList();

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
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(show: false),
                  gridData: FlGridData(show: false),
                  barGroups: barGroups,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RevenueBreakdownPie extends StatelessWidget {
  const RevenueBreakdownPie({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Revenue Breakdown",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 40,
                      color: Colors.blue,
                      title: "Products",
                      radius: 60,
                    ),
                    PieChartSectionData(
                      value: 25,
                      color: Colors.green,
                      title: "Services",
                      radius: 60,
                    ),
                    PieChartSectionData(
                      value: 20,
                      color: Colors.orange,
                      title: "Delivery",
                      radius: 60,
                    ),
                    PieChartSectionData(
                      value: 15,
                      color: Colors.purple,
                      title: "Others",
                      radius: 60,
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserGrowthChart extends StatelessWidget {
  const UserGrowthChart({super.key});

  @override
  Widget build(BuildContext context) {
    final dailyCounts = List.generate(7, (i) {
      final day = DateTime.now().subtract(Duration(days: 6 - i));
      return mockUsers
          .where(
            (u) =>
                u.joinedDate.year == day.year &&
                u.joinedDate.month == day.month &&
                u.joinedDate.day == day.day,
          )
          .length
          .toDouble();
    });

    final spots = List.generate(7, (i) => FlSpot(i.toDouble(), dailyCounts[i]));

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
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.teal,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
