import 'dart:convert';
import 'order_item.dart';
import 'payment.dart';

enum OrderStatus { PENDING, SHIPPED, DELIVERED, RETURNED, CANCELLED }

OrderStatus orderStatusFromString(String status) {
  return OrderStatus.values.firstWhere(
    (e) => e.toString().split('.').last.toUpperCase() == status.toUpperCase(),
    orElse: () => OrderStatus.PENDING,
  );
}

String orderStatusToString(OrderStatus status) {
  return status.toString().split('.').last;
}

class Order {
  final int id;
  final int customerId;
  final int vendorId;
  final Map<String, dynamic>? shippingSnapshot;
  final OrderStatus status;

  final double subTotal;
  final double taxTotal;
  final double shippingCharge;
  final double? shippingTax;
  final double? discount;
  final double total;

  final DateTime createdAt;

  final List<OrderItem>? items;
  final Payment? payment;

  // ✅ Newly added fields
  final Map<String, dynamic>? vendor;
  final Map<String, dynamic>? customer;
  final Map<String, dynamic>? user;

  Order({
    required this.id,
    required this.customerId,
    required this.vendorId,
    this.shippingSnapshot,
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
    this.vendor,
    this.customer,
    this.user,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerId: json['customerId'],
      vendorId: json['vendorId'],
      shippingSnapshot:
          json['shippingSnapshot'] != null
              ? jsonDecode(json['shippingSnapshot'])
              : null,
      status: orderStatusFromString(json['status']),
      subTotal: (json['subTotal'] as num).toDouble(),
      taxTotal: (json['taxTotal'] as num).toDouble(),
      shippingCharge: (json['shippingCharge'] as num).toDouble(),
      shippingTax:
          json['shippingTax'] != null
              ? (json['shippingTax'] as num).toDouble()
              : null,
      discount:
          json['discount'] != null
              ? (json['discount'] as num).toDouble()
              : null,
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      items:
          json['items'] != null
              ? List<OrderItem>.from(
                json['items'].map((x) => OrderItem.fromJson(x)),
              )
              : null,
      payment:
          json['payment'] != null ? Payment.fromJson(json['payment']) : null,

      // ✅ Decode new fields
      vendor:
          json['vendor'] != null
              ? Map<String, dynamic>.from(json['vendor'])
              : null,
      customer:
          json['customer'] != null
              ? Map<String, dynamic>.from(json['customer'])
              : null,
      user:
          json['user'] != null ? Map<String, dynamic>.from(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'vendorId': vendorId,
      'shippingSnapshot':
          shippingSnapshot != null ? jsonEncode(shippingSnapshot) : null,
      'status': orderStatusToString(status),
      'subTotal': subTotal,
      'taxTotal': taxTotal,
      'shippingCharge': shippingCharge,
      'shippingTax': shippingTax,
      'discount': discount,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'items': items?.map((x) => x.toJson()).toList(),
      'payment': payment?.toJson(),

      // ✅ Encode new fields
      'vendor': vendor,
      'customer': customer,
      'user': user,
    };
  }
}
