// lib/models/dashboard_models.dart

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/icon_data.dart';

class OverviewStat {
  final String title;
  final String value;
  final String growth;
  final String iconName;

  OverviewStat({
    required this.title,
    required this.value,
    required this.growth,
    required this.iconName,
    required String label,
    required IconData icon,
  });
}

class NotificationItem {
  final String title;
  final String message;
  final String time;
  final Icon iconName;
  final bool isNew;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.iconName,
    this.isNew = false,
    required String subtitle,
    required IconData icon,
  });
}

class OrderSummary {
  final String initials;
  final String orderId;
  final String customerName;
  final double amount;
  final String status;
  final String date;

  OrderSummary({
    required this.initials,
    required this.orderId,
    required this.customerName,
    required this.amount,
    required this.status,
    required this.date,
  });
}

// Dummy Data
final List<OverviewStat> overviewStats = [
  OverviewStat(
    title: "Total Orders",
    value: "2,150",
    growth: "+12.5%",
    iconName: "shopping_cart",
    label: '',
    icon: IconData(
      0xe8cc,
      fontFamily: 'MaterialIcons',
    ), // Example: shopping_cart icon
  ),
  OverviewStat(
    title: "Total Products",
    value: "840",
    growth: "+5.2%",
    iconName: "inventory",
    label: '',
    icon: IconData(0xe8cc, fontFamily: 'MaterialIcons'), //
  ),
  OverviewStat(
    title: "Commission Earned",
    value: "\$12,450",
    growth: "+18.0%",
    iconName: "attach_money",
    label: '',
    icon: IconData(0xe8cc, fontFamily: 'MaterialIcons'), //
  ),
  OverviewStat(
    title: "Total Revenue",
    value: "\$85,700",
    growth: "+9.3%",
    iconName: "bar_chart",
    label: '',
    icon: IconData(0xe8cc, fontFamily: 'MaterialIcons'), //
  ),
];

final List<NotificationItem> notifications = [
  NotificationItem(
    title: "New Order Received",
    message: "Order #7890 for John Doe is ready",
    time: "Just now",
    iconName: Icon(Icons.mark_email_unread),
    isNew: true,
    subtitle: '',
    icon: IconData(0xe8cc, fontFamily: 'MaterialIcons'), //
  ),
  NotificationItem(
    title: "Order Shipped",
    message: "Order #7885 for Jane Smith has been shipped",
    time: "5 min ago",
    iconName: Icon(Icons.mark_email_unread),
    subtitle: '',
    icon: IconData(0xe8cc, fontFamily: 'MaterialIcons'), //
  ),
  NotificationItem(
    title: "New Message",
    message: "You have a new message for Order #7870",
    time: "1 hour ago",
    iconName: Icon(Icons.mark_email_unread),
    isNew: true,
    subtitle: '',
    icon: IconData(0xe8cc, fontFamily: 'MaterialIcons'), //
  ),
  NotificationItem(
    title: "Payment Processed",
    message: "Payment for Order #7860 successfully processed",
    time: "3 hours ago",
    iconName: Icon(Icons.mark_email_unread),
    subtitle: '',
    icon: IconData(0xe8cc, fontFamily: 'MaterialIcons'), //
  ),
];

final List<OrderSummary> recentOrders = [
  OrderSummary(
    initials: "JD",
    orderId: "Order #7890",
    customerName: "John Doe",
    amount: 150.0,
    status: "Pending",
    date: "2024-07-28",
  ),
  OrderSummary(
    initials: "👩",
    orderId: "Order #7885",
    customerName: "Jane Smith",
    amount: 230.5,
    status: "Shipped",
    date: "2024-07-27",
  ),
  OrderSummary(
    initials: "RJ",
    orderId: "Order #7880",
    customerName: "Robert Johnson",
    amount: 75.0,
    status: "Delivered",
    date: "2024-07-26",
  ),
  OrderSummary(
    initials: "👩",
    orderId: "Order #7875",
    customerName: "Emily White",
    amount: 420.25,
    status: "Pending",
    date: "2024-07-25",
  ),
];
