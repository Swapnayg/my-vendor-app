import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:my_vendor_app/models/product.dart';
import '/common/common_layout.dart';
import 'package:go_router/go_router.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;
  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  List<int> get yearOptions => [DateTime.now().year - 1, DateTime.now().year];

  Map<int, int> get dailyOrderCount {
    final map = <int, int>{};
    for (var item in widget.product.orderItems) {
      if (item.createdAt.year == selectedYear &&
          item.createdAt.month == selectedMonth) {
        map[item.createdAt.day] = (map[item.createdAt.day] ?? 0) + 1;
      }
    }
    return map;
  }

  Map<int, double> get dailyRevenue {
    final map = <int, double>{};
    for (var item in widget.product.orderItems) {
      if (item.createdAt.year == selectedYear &&
          item.createdAt.month == selectedMonth) {
        map[item.createdAt.day] = (map[item.createdAt.day] ?? 0) + item.price;
      }
    }
    return map;
  }

  List<FlSpot> get chartSpots {
    final orderMap = dailyOrderCount;
    int days = DateUtils.getDaysInMonth(selectedYear, selectedMonth);
    return List.generate(days, (i) {
      final day = i + 1;
      return FlSpot(i.toDouble(), (orderMap[day] ?? 0).toDouble());
    });
  }

  List<String> get dayLabels {
    int days = DateUtils.getDaysInMonth(selectedYear, selectedMonth);
    return List.generate(
      days,
      (i) =>
          DateFormat('d').format(DateTime(selectedYear, selectedMonth, i + 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        widget.product.images.isNotEmpty
            ? widget.product.images.first.url
            : 'https://via.placeholder.com/150?text=No+Image';
    final rating =
        widget.product.reviews.isEmpty
            ? "0"
            : (widget.product.reviews.fold(0, (sum, r) => sum + r.rating) /
                    widget.product.reviews.length)
                .toStringAsFixed(1);

    return CommonLayout(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go('/products/top'),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Product Details",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 120,
                    width: 120,
                    child:
                        imageUrl.startsWith('http')
                            ? Image.network(imageUrl, fit: BoxFit.cover)
                            : Image.asset(imageUrl, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.product.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '₹${widget.product.price}',
                style: const TextStyle(color: Colors.green, fontSize: 18),
              ),
              Text(
                'Rating: $rating ⭐ (${widget.product.reviews.length} reviews)',
              ),
              Text('Stock: ${widget.product.stock} units'),
              Text(
                'Commission: ${double.tryParse(widget.product.defaultCommissionPct.toString())?.toStringAsFixed(1) ?? "0"}%',
                style: const TextStyle(color: Colors.purple),
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  DropdownButton<int>(
                    value: selectedMonth,
                    onChanged: (val) => setState(() => selectedMonth = val!),
                    items: List.generate(
                      12,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text(
                          DateFormat.MMMM().format(DateTime(0, i + 1)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<int>(
                    value: selectedYear,
                    onChanged: (val) => setState(() => selectedYear = val!),
                    items:
                        yearOptions
                            .map(
                              (year) => DropdownMenuItem(
                                value: year,
                                child: Text(year.toString()),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Text(
                "Sales Growth",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    height: 240,
                    width: double.infinity,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(
                          show: true,
                          border: const Border(
                            bottom: BorderSide(color: Colors.grey),
                            left: BorderSide(color: Colors.grey),
                            top: BorderSide.none,
                            right: BorderSide.none,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              interval: 1,
                              getTitlesWidget:
                                  (value, _) => Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: (chartSpots.length / 6).ceilToDouble(),
                              getTitlesWidget: (value, _) {
                                final index = value.toInt();
                                if (index < 0 || index >= dayLabels.length) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: chartSpots,
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                        showingTooltipIndicators: List.generate(
                          chartSpots.length,
                          (i) => ShowingTooltipIndicators([
                            LineBarSpot(
                              LineChartBarData(spots: chartSpots),
                              0,
                              chartSpots[i],
                            ),
                          ]),
                        ),
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor: Colors.black87,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                final day = spot.x.toInt() + 1;
                                final orders = dailyOrderCount[day] ?? 0;
                                final revenue = dailyRevenue[day] ?? 0;
                                return LineTooltipItem(
                                  'Day $day\nOrders: $orders\n₹${revenue.toStringAsFixed(2)}',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              const Text(
                "Customer Reviews",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              ...widget.product.reviews.map((review) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            review.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat.yMMMd().format(review.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (review.comment.trim().isNotEmpty)
                        Text(
                          review.comment,
                          style: const TextStyle(fontSize: 14),
                        ),
                      if (review.images != null &&
                          review.images!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: review.images!.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final img = review.images![index];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  img as String,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.broken_image),
                                      ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
