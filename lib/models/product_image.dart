class ProductImage {
  final int id;
  final String url;
  final int productId;
  final DateTime createdAt;

  ProductImage({
    required this.id,
    required this.url,
    required this.productId,
    required this.createdAt,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'],
      url: json['url'],
      productId: json['productId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'productId': productId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
