class Product {
  final int id;
  final String name;
  final String description;
  final double basePrice;
  final double taxRate;
  final double price;
  final String status;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.taxRate,
    required this.price,
    required this.status,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      basePrice: json['basePrice'].toDouble(),
      taxRate: json['taxRate'].toDouble(),
      price: json['price'].toDouble(),
      status: json['status'],
      stock: json['stock'],
    );
  }
}
