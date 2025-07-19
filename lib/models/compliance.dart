class Compliance {
  final int id;
  final int productId;
  final String? fssaiNumber;
  final String? gstNumber;
  final String? hsnCode;
  final String? foodType; // veg, non-veg, vegan, etc.

  Compliance({
    required this.id,
    required this.productId,
    this.fssaiNumber,
    this.gstNumber,
    this.hsnCode,
    this.foodType,
  });

  factory Compliance.fromJson(Map<String, dynamic> json) => Compliance(
    id: json['id'],
    productId: json['productId'],
    fssaiNumber: json['fssaiNumber'],
    gstNumber: json['gstNumber'],
    hsnCode: json['hsnCode'],
    foodType: json['foodType'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'fssaiNumber': fssaiNumber,
    'gstNumber': gstNumber,
    'hsnCode': hsnCode,
    'foodType': foodType,
  };
}
