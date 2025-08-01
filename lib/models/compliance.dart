class Compliance {
  final int id;
  int productId;
  String? type; // veg, non-veg, vegan, etc.
  String? fileUrl; // New field for compliance document

  Compliance({
    required this.id,
    required this.productId,
    this.type,
    this.fileUrl,
  });

  factory Compliance.fromJson(Map<String, dynamic> json) => Compliance(
    id: json['id'],
    productId: json['productId'],
    type: json['type'],
    fileUrl: json['fileUrl'], // Read from JSON
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'type': type,
    'fileUrl': fileUrl, // Include in JSON
  };
}
