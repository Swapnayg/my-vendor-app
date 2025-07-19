import 'product.dart';

class ProductCategory {
  final int id;
  final String name;
  final String? description;
  final List<Product> products;

  ProductCategory({
    required this.id,
    required this.name,
    this.description,
    this.products = const [],
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      products:
          (json['products'] as List<dynamic>?)
              ?.map((e) => Product.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'products': products.map((e) => e.toJson()).toList(),
  };
}
