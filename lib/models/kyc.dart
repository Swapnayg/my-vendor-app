class KYC {
  final int id;
  final int vendorId;
  final String type;
  final String fileUrl;
  final bool verified;

  KYC({
    required this.id,
    required this.vendorId,
    required this.type,
    required this.fileUrl,
    required this.verified,
  });

  factory KYC.fromJson(Map<String, dynamic> json) {
    return KYC(
      id: json['id'],
      vendorId: json['vendorId'],
      type: json['type'],
      fileUrl: json['fileUrl'],
      verified: json['verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendorId': vendorId,
      'type': type,
      'fileUrl': fileUrl,
      'verified': verified,
    };
  }
}
