// lib/models/latest_orders.dart

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

final List<OrderSummary> latestOrders = [
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
