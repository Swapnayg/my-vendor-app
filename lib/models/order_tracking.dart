enum OrderStatus { PENDING, SHIPPED, DELIVERED, RETURNED, CANCELLED }

class OrderTracking {
  final int id;
  final int orderId;
  final OrderStatus status;
  final String? message;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  OrderTracking({
    required this.id,
    required this.orderId,
    required this.status,
    this.message,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    return OrderTracking(
      id: json['id'],
      orderId: json['orderId'],
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => OrderStatus.PENDING,
      ),
      message: json['message'],
      latitude:
          json['latitude'] != null
              ? (json['latitude'] as num).toDouble()
              : null,
      longitude:
          json['longitude'] != null
              ? (json['longitude'] as num).toDouble()
              : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'status': status.toString().split('.').last,
      'message': message,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
