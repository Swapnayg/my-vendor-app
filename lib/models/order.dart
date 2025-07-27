import 'package:my_vendor_app/models/order_item.dart';
import 'package:my_vendor_app/models/order_tracking.dart';

enum OrderStatus { PENDING, SHIPPED, DELIVERED, RETURNED, CANCELLED }

OrderStatus orderStatusFromString(String status) {
  return OrderStatus.values.firstWhere(
    (e) => e.toString().split('.').last == status,
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
  final Map<String, dynamic>? customer; // 👈 Add this line
  final Map<String, dynamic>? shippingSnapshot;
  final OrderStatus status;

  final int? shiprocketOrderId;
  final int? shiprocketShipmentId;
  final String? shiprocketLabelUrl;
  final String? shiprocketManifestUrl;
  final String? trackingPartner;
  final String? trackingNumber;

  final double subTotal;
  final double taxTotal;
  final double shippingCharge;
  final double? shippingTax;
  final double? discount;
  final double total;

  final DateTime createdAt;

  final List<OrderItem> items;
  final List<OrderTracking> trackingEvents;

  Order({
    required this.id,
    required this.customerId,
    required this.vendorId,
    this.customer, // 👈 Add to constructor
    required this.shippingSnapshot,
    required this.status,
    this.shiprocketOrderId,
    this.shiprocketShipmentId,
    this.shiprocketLabelUrl,
    this.shiprocketManifestUrl,
    this.trackingPartner,
    this.trackingNumber,
    required this.subTotal,
    required this.taxTotal,
    required this.shippingCharge,
    this.shippingTax,
    this.discount,
    required this.total,
    required this.createdAt,
    required this.items,
    required this.trackingEvents,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerId: json['customerId'],
      vendorId: json['vendorId'],
      customer: json['customer'], // 👈 Deserialize from API
      shippingSnapshot: json['shippingSnapshot'],
      status: orderStatusFromString(json['status']),
      shiprocketOrderId: json['shiprocketOrderId'],
      shiprocketShipmentId: json['shiprocketShipmentId'],
      shiprocketLabelUrl: json['shiprocketLabelUrl'],
      shiprocketManifestUrl: json['shiprocketManifestUrl'],
      trackingPartner: json['trackingPartner'],
      trackingNumber: json['trackingNumber'],
      subTotal: (json['subTotal'] ?? 0).toDouble(),
      taxTotal: (json['taxTotal'] ?? 0).toDouble(),
      shippingCharge: (json['shippingCharge'] ?? 0).toDouble(),
      shippingTax:
          json['shippingTax'] != null ? (json['shippingTax']).toDouble() : null,
      discount: json['discount'] != null ? (json['discount']).toDouble() : null,
      total: (json['total'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      items:
          (json['items'] as List<dynamic>)
              .map((e) => OrderItem.fromJson(e))
              .toList(),
      trackingEvents:
          (json['trackingEvents'] as List<dynamic>)
              .map((e) => OrderTracking.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'vendorId': vendorId,
      'customer': customer, // 👈 Add to JSON
      'shippingSnapshot': shippingSnapshot,
      'status': status.name,
      'shiprocketOrderId': shiprocketOrderId,
      'shiprocketShipmentId': shiprocketShipmentId,
      'shiprocketLabelUrl': shiprocketLabelUrl,
      'shiprocketManifestUrl': shiprocketManifestUrl,
      'trackingPartner': trackingPartner,
      'trackingNumber': trackingNumber,
      'subTotal': subTotal,
      'taxTotal': taxTotal,
      'shippingCharge': shippingCharge,
      'shippingTax': shippingTax,
      'discount': discount,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
      'trackingEvents': trackingEvents.map((e) => e.toJson()).toList(),
    };
  }
}
