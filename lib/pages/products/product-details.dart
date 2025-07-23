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

  List<FlSpot> get dummySpots {
    int daysInMonth = DateUtils.getDaysInMonth(selectedYear, selectedMonth);
    return List.generate(
      daysInMonth,
      (i) => FlSpot(i.toDouble(), (i * 2.3 % 20 + 5).toDouble()),
    );
  }

  List<String> get dayLabels {
    int daysInMonth = DateUtils.getDaysInMonth(selectedYear, selectedMonth);
    return List.generate(
      daysInMonth,
      (i) =>
          DateFormat('d').format(DateTime(selectedYear, selectedMonth, i + 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rating =
        widget.product.reviews.isEmpty
            ? "0"
            : (widget.product.reviews.fold(0, (sum, r) => sum + r.rating) /
                    widget.product.reviews.length)
                .toStringAsFixed(1);

    final imageUrl =
        widget.product.images.isNotEmpty
            ? widget.product.images.first.url
            : 'https://via.placeholder.com/150?text=No+Image';

    final imageWidget =
        imageUrl.startsWith('http')
            ? Image.network(imageUrl, fit: BoxFit.cover)
            : Image.asset(imageUrl, fit: BoxFit.cover);

    return CommonLayout(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Custom AppBar Row ---
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
                  child: SizedBox(height: 120, width: 120, child: imageWidget),
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
              const SizedBox(height: 4),
              Text(
                'Rating: $rating ⭐ (${widget.product.reviews.length} reviews)',
              ),
              const SizedBox(height: 4),
              Text('Stock: ${widget.product.stock} units'),
              const SizedBox(height: 24),

              // --- Month/Year Dropdowns ---
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
              const SizedBox(height: 16),

              // --- Growth Line Chart ---
              const Text(
                "Sales Growth",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(
                          bottom: BorderSide(color: Colors.grey),
                          left: BorderSide(color: Colors.grey),
                          top: BorderSide(color: Colors.transparent),
                          right: BorderSide(color: Colors.transparent),
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 5,
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
                            interval: (dummySpots.length ~/ 6).toDouble(),
                            getTitlesWidget: (value, _) {
                              final index = value.toInt();
                              if (index < 0 || index >= dayLabels.length) {
                                return const SizedBox.shrink();
                              }
                              return Text(
                                dayLabels[index],
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: dummySpots,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(show: false),
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, _, __, ___) {
                              return FlDotCirclePainter(
                                radius: 3,
                                color: Colors.pink,
                                strokeWidth: 1,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.show_chart, size: 16, color: Colors.blue),
                    SizedBox(width: 4),
                    Text("Sales Growth", style: TextStyle(color: Colors.blue)),
                  ],
                ),
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

                      // --- Review Images Preview ---
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
                              final imageUrl = review.images![index];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl as String,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => Container(
                                        color: Colors.grey[200],
                                        width: 100,
                                        height: 100,
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
