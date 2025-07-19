import 'package:flutter/material.dart';

class OverviewStat {
  final Icon icon;
  final String label;
  final String value;
  final String growth;

  OverviewStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.growth,
  });
}

final List<OverviewStat> overviewStats = [
  OverviewStat(
    icon: Icon(Icons.shopping_cart),
    label: "Total Orders",
    value: "2,150",
    growth: "12.5%",
  ),
  OverviewStat(
    icon: Icon(Icons.pie_chart),
    label: "Sales Revenue",
    value: "₹1.2L",
    growth: "9.3%",
  ),
  OverviewStat(
    icon: Icon(Icons.person),
    label: "New Customers",
    value: "320",
    growth: "5.1%",
  ),
  OverviewStat(
    icon: Icon(Icons.category),
    label: "Total Products",
    value: "840",
    growth: "5.2%",
  ),
  OverviewStat(
    icon: Icon(Icons.attach_money),
    label: "Commission Earned",
    value: "\$12,450",
    growth: "18.0%",
  ),
  OverviewStat(
    icon: Icon(Icons.bar_chart),
    label: "Total Revenue",
    value: "\$85,700",
    growth: "9.3%",
  ),
  // Add more if needed
];
