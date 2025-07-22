class Compliance {
  final int id;
  int productId;
  String? type; // veg, non-veg, vegan, etc.
  String? documentUrl; // New field for compliance document

  Compliance({
    required this.id,
    required this.productId,
    this.type,
    this.documentUrl,
  });

  factory Compliance.fromJson(Map<String, dynamic> json) => Compliance(
    id: json['id'],
    productId: json['productId'],
    type: json['type'],
    documentUrl: json['documentUrl'], // Read from JSON
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'type': type,
    'documentUrl': documentUrl, // Include in JSON
  };
}
