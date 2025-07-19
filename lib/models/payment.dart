enum PaymentStatus { PAID, REFUNDED, FAILED }

class Payment {
  final int id;
  final int orderId;
  final double amount;
  final PaymentStatus status;
  final String method;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.status,
    required this.method,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      orderId: json['orderId'],
      amount: (json['amount'] as num).toDouble(),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => PaymentStatus.PAID,
      ),
      method: json['method'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'amount': amount,
      'status': status.toString().split('.').last,
      'method': method,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
