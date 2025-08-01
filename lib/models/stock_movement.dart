class StockMovement {
  final int id;
  final int productId;
  final int vendorId;
  final int quantity;
  final DateTime createdAt;

  StockMovement({
    required this.id,
    required this.productId,
    required this.vendorId,
    required this.quantity,
    required this.createdAt,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'],
      productId: json['productId'],
      vendorId: json['vendorId'],
      quantity: json['quantity'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'vendorId': vendorId,
      'quantity': quantity,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
