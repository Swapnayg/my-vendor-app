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

class OrderTracking {
  final int id;
  final int orderId;
  final OrderStatus status;
  final String? message;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final String? externalStatus;
  final String? provider;

  OrderTracking({
    required this.id,
    required this.orderId,
    required this.status,
    this.message,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.externalStatus,
    this.provider,
  });

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    return OrderTracking(
      id: json['id'],
      orderId: json['orderId'],
      status: orderStatusFromString(json['status']),
      message: json['message'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      externalStatus: json['externalStatus'],
      provider: json['provider'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'status': orderStatusToString(status),
      'message': message,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'externalStatus': externalStatus,
      'provider': provider,
    };
  }
}
