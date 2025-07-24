class BankAccount {
  final int id;
  final int vendorId;
  final String accountHolder;
  final String accountNumber;
  final String ifscCode;
  final String bankName;
  final String? branchName;
  final String? upiId;
  final String? upiQrUrl;
  final DateTime createdAt;

  BankAccount({
    required this.id,
    required this.vendorId,
    required this.accountHolder,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
    this.branchName,
    this.upiId,
    this.upiQrUrl,
    required this.createdAt,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'],
      vendorId: json['vendorId'],
      accountHolder: json['accountHolder'],
      accountNumber: json['accountNumber'],
      ifscCode: json['ifscCode'],
      bankName: json['bankName'],
      branchName: json['branchName'],
      upiId: json['upiId'],
      upiQrUrl: json['upiQrUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendorId': vendorId,
      'accountHolder': accountHolder,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'bankName': bankName,
      'branchName': branchName,
      'upiId': upiId,
      'upiQrUrl': upiQrUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
