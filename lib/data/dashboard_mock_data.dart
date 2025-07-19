// lib/mock/dashboard_mock_data.dart
import 'package:flutter/material.dart';
import 'package:my_vendor_app/models/order_item.dart';
import '../models/dashboard_models.dart';

final List<OverviewStat> overviewStats = [
  OverviewStat(
    icon: Icons.shopping_cart,
    label: "Orders",
    value: "1,250",
    growth: "8.2%",
    title: '',
    iconName: '',
  ),
  OverviewStat(
    icon: Icons.attach_money,
    label: "Revenue",
    value: "₹75K",
    growth: "12.5%",
    title: '',
    iconName: '',
  ),
  OverviewStat(
    icon: Icons.person_add,
    label: "New Users",
    value: "320",
    growth: "5.4%",
    title: '',
    iconName: '',
  ),
  OverviewStat(
    icon: Icons.local_shipping,
    label: "Deliveries",
    value: "980",
    growth: "3.1%",
    title: '',
    iconName: '',
  ),
];

final List<NotificationItem> recentNotifications = [
  NotificationItem(
    icon: Icons.notifications,
    title: "Order Shipped",
    subtitle: "Order #12345 has been shipped.",
    time: "2h ago",
    isNew: true,
    message: '',
    iconName: '',
  ),
  NotificationItem(
    icon: Icons.person_add,
    title: "New User Registered",
    subtitle: "John Doe joined the platform.",
    time: "5h ago",
    message: '',
    iconName: '',
  ),
  NotificationItem(
    icon: Icons.star,
    title: "Positive Review",
    subtitle: "Product X received a 5-star rating.",
    time: "1d ago",
    message: '',
    iconName: '',
  ),
];

final List<OrderItem> latestOrders = [
  OrderItem(
    id: 1,
    productId: "P001",
    quantity: 2,
    basePrice: 1200.0,
    taxRate: 0.18,
    taxAmount: 216.0,
    price: 1500.0,
    initials: "JD",
    orderId: "#12345",
    name: "John Doe",
    amount: "₹1,500",
    status: "Completed",
    date: "July 15",
  ),
  OrderItem(
    id: 2,
    productId: "P002",
    quantity: 1,
    basePrice: 1700.0,
    taxRate: 0.18,
    taxAmount: 306.0,
    price: 2000.0,
    initials: "SM",
    orderId: "#12346",
    name: "Sarah Miller",
    amount: "₹2,000",
    status: "Pending",
    date: "July 16",
  ),
  OrderItem(
    id: 3,
    productId: "P003",
    quantity: 3,
    basePrice: 2750.0,
    taxRate: 0.18,
    taxAmount: 495.0,
    price: 3250.0,
    initials: "AK",
    orderId: "#12347",
    name: "Arjun Kapoor",
    amount: "₹3,250",
    status: "Delivered",
    date: "July 17",
  ),
];
