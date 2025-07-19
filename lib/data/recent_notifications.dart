// lib/models/recent_notifications.dart

import 'package:flutter/material.dart';

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
  });
}

final List<NotificationItem> recentNotifications = [
  NotificationItem(
    title: "New Order Received",
    message: "Order #7890 for John Doe is ready",
    time: "Just now",
    iconName: Icon(Icons.mark_email_unread),
    isNew: true,
  ),
  NotificationItem(
    title: "Order Shipped",
    message: "Order #7885 for Jane Smith has been shipped",
    time: "5 min ago",
    iconName: Icon(Icons.local_shipping),
  ),
  NotificationItem(
    title: "New Message",
    message: "You have a new message for Order #7870",
    time: "1 hour ago",
    iconName: Icon(Icons.message),
    isNew: true,
  ),
  NotificationItem(
    title: "Payment Processed",
    message: "Payment for Order #7860 successfully processed",
    time: "3 hours ago",
    iconName: Icon(Icons.payment),
  ),
];
