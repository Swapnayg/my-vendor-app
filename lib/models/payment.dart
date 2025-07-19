class Payment {
  final int id;
  final double amount;
  final String method;
  final String status;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      amount: json['amount'].toDouble(),
      method: json['method'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
