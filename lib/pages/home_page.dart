import 'package:flutter/material.dart';
import '../common/common_layout.dart';
import '../theme/colors.dart';
import '../widgets/chart_widgets.dart';
import '../data/overview_stats.dart';
import '../data/recent_notifications.dart';
import '../data/latest_orders.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final crossAxisCount = isMobile ? 2 : 4;
    final itemWidth = (MediaQuery.of(context).size.width - 48) / crossAxisCount;

    return CommonLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Overview",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(overviewStats.length, (index) {
                final stat = overviewStats[index];
                final color = _cardColors[index % _cardColors.length];
                return _overviewCard(
                  stat.icon,
                  stat.label,
                  stat.value,
                  stat.growth,
                  color,
                  width: itemWidth,
                );
              }),
            ),

            const SizedBox(height: 24),
            const Text(
              "Performance Analytics",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            const SalesOverviewChart(),
            const SizedBox(height: 16),
            const TopProductsChart(),
            const SizedBox(height: 16),
            const RevenueBreakdownPie(),
            const SizedBox(height: 16),
            const UserGrowthChart(),
            const SizedBox(height: 24),
            const Text(
              "Recent Notifications",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...recentNotifications.map((n) {
              try {
                return _notificationTile(
                  n.iconName,
                  n.title,
                  n.message,
                  n.time,
                  isNew: n.isNew,
                );
              } catch (e) {
                print("❌ Error mapping notification: $e");
                return const ListTile(
                  title: Text("Error loading notification"),
                );
              }
            }),

            const SizedBox(height: 24),
            const Text(
              "Latest Orders",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            ...latestOrders.map((o) {
              try {
                return _orderTile(
                  o.initials,
                  o.orderId,
                  o.customerName,
                  o.amount.toStringAsFixed(2),
                  o.status,
                  o.date,
                );
              } catch (e, stackTrace) {
                print('❌ Error rendering order ${o.orderId}: $e');
                print(stackTrace);
                return const ListTile(
                  title: Text("⚠️ Error loading order"),
                  subtitle: Text("This order could not be displayed."),
                );
              }
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
    Icon icon,
    String label,
    String value,
    String growth,
    Color color, {
    required double width,
  }) {
    print('🟡 Building Overview Card: label=$label');

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
          Icon(icon.icon, color: Colors.black54),
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
    Icon icon,
    String title,
    String subtitle,
    String time, {
    bool isNew = false,
  }) {
    print('🔵 Rendering Notification: title=$title, isNew=$isNew');

    try {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: Icon(icon.icon, color: Colors.blue),
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
                Text(time, style: const TextStyle(fontSize: 12)),
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
                      elevation: 0,
                      shadowColor: Colors.transparent,
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
    } catch (e) {
      print('🔴 Error in _notificationTile for "$title": $e');
      return const ListTile(title: Text("Error rendering notification"));
    }
  }

  Widget _orderTile(
    String initials,
    String orderId,
    String name,
    String amount,
    String status,
    String date,
  ) {
    print('🟢 Rendering OrderTile: orderId=$orderId, status=$status');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color.fromARGB(255, 238, 31, 145),
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
}
