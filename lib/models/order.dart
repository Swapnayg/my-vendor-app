import 'package:my_vendor_app/models/order_item.dart';
import 'package:my_vendor_app/models/order_tracking.dart';
import 'package:my_vendor_app/models/payment.dart';

class Order {
  final int id;
  final int customerId;
  final int vendorId;
  final String status;
  final double subTotal;
  final double taxTotal;
  final double shippingCharge;
  final double? shippingTax;
  final double? discount;
  final double total;
  final DateTime createdAt;
  final List<OrderItem>? items;
  final Payment? payment;
  final List<OrderTracking>? tracking;

  Order({
    required this.id,
    required this.customerId,
    required this.vendorId,
    required this.status,
    required this.subTotal,
    required this.taxTotal,
    required this.shippingCharge,
    this.shippingTax,
    this.discount,
    required this.total,
    required this.createdAt,
    this.items,
    this.payment,
    this.tracking,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerId: json['customerId'],
      vendorId: json['vendorId'],
      status: json['status'],
      subTotal: json['subTotal'].toDouble(),
      taxTotal: json['taxTotal'].toDouble(),
      shippingCharge: json['shippingCharge'].toDouble(),
      shippingTax: json['shippingTax']?.toDouble(),
      discount: json['discount']?.toDouble(),
      total: json['total'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      items:
          json['items'] != null
              ? (json['items'] as List)
                  .map((e) => OrderItem.fromJson(e))
                  .toList()
              : null,
      payment:
          json['payment'] != null ? Payment.fromJson(json['payment']) : null,
      tracking:
          json['trackingEvents'] != null
              ? (json['trackingEvents'] as List)
                  .map((e) => OrderTracking.fromJson(e))
                  .toList()
              : null,
    );
  }
}
