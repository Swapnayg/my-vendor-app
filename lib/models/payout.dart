enum PayoutStatus { PENDING, APPROVED, REJECTED }

class Payout {
  final int id;
  final int vendorId;
  final double amount;
  final double commissionAmount;
  final PayoutStatus status;
  final DateTime requestedAt;

  Payout({
    required this.id,
    required this.vendorId,
    required this.amount,
    required this.commissionAmount,
    required this.status,
    required this.requestedAt,
  });

  factory Payout.fromJson(Map<String, dynamic> json) {
    return Payout(
      id: json['id'],
      vendorId: json['vendorId'],
      amount: (json['amount'] as num).toDouble(),
      commissionAmount: (json['commissionAmount'] as num).toDouble(),
      status: PayoutStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => PayoutStatus.PENDING,
      ),
      requestedAt: DateTime.parse(json['requestedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendorId': vendorId,
      'amount': amount,
      'commissionAmount': commissionAmount,
      'status': status.toString().split('.').last,
      'requestedAt': requestedAt.toIso8601String(),
    };
  }
}
