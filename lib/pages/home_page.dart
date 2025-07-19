import 'package:flutter/material.dart';
import 'package:my_vendor_app/models/order_item.dart';
import '../common/common_layout.dart';
import '../theme/colors.dart';
import '../models/dashboard_models.dart' as dashboard;
import '../widgets/chart_widgets.dart'; // ⬅️ Chart Widgets
import '../widgets/notification_widget.dart'; // Notification model if needed

// Mock data imported
import '../data/overview_stats.dart';
import '../data/recent_notifications.dart';
import '../data/latest_orders.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
              children:
                  overviewStats
                      .map(
                        (stat) => _overviewCard(
                          stat.icon,
                          stat.label,
                          stat.value,
                          stat.growth,
                        ),
                      )
                      .toList(),
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
            ...recentNotifications.map(
              (n) => _notificationTile(
                n.iconName,
                n.title,
                n.message,
                n.time,
                isNew: n.isNew,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Latest Orders",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...latestOrders.map(
              (o) => _orderTile(
                o.initials,
                o.orderId,
                o.customerName,
                o.amount as String,
                o.status,
                o.date,
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _overviewCard(Icon icon, String label, String value, String growth) {
    print('🟡 Building Overview Card: label=$label');

    return SizedBox(
      width: 160,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon.icon, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text("↑ $growth", style: const TextStyle(color: Colors.green)),
            ],
          ),
        ),
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
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(icon.icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(time, style: const TextStyle(fontSize: 12)),
            if (isNew)
              const Chip(
                label: Text("New"),
                backgroundColor: Colors.orange,
                visualDensity: VisualDensity.compact,
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

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(child: Text(initials)),
      title: Text(orderId),
      subtitle: Text(name),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
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
    );
  }
}
