class OrderTracking {
  final int id;
  final String status;
  final String? message;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  OrderTracking({
    required this.id,
    required this.status,
    this.message,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    return OrderTracking(
      id: json['id'],
      status: json['status'],
      message: json['message'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
