import 'compliance.dart';
import 'vendor.dart';
import 'product_category.dart';
import 'order_item.dart';
import 'notification.dart';
import 'product_image.dart';
import 'review.dart';

enum ProductStatus {
  pending,
  approved,
  rejected,
  suspended;

  static ProductStatus fromString(String value) {
    return ProductStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => ProductStatus.pending,
    );
  }

  String toJsonString() => name.toUpperCase();
}

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final double basePrice;
  final double taxRate;
  final int stock;
  final int vendorId;
  final int? categoryId;
  final ProductStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? defaultCommissionPct;

  // Relations
  final Vendor? vendor;
  final ProductCategory? category;
  final List<Compliance>? compliance;
  final List<OrderItem> orderItems;
  final List<NotificationModel> notifications;
  final List<ProductImage> images;
  final List<Review> reviews;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.basePrice,
    required this.taxRate,
    required this.stock,
    required this.vendorId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.categoryId,
    this.vendor,
    this.category,
    this.compliance = const [],
    this.orderItems = const [],
    this.notifications = const [],
    this.images = const [],
    this.reviews = const [],
    this.defaultCommissionPct,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    price: (json['price'] as num).toDouble(),
    basePrice: (json['basePrice'] as num).toDouble(),
    taxRate: (json['taxRate'] as num).toDouble(),
    stock: (json['stock']),
    vendorId: json['vendorId'],
    categoryId: json['categoryId'],
    status: ProductStatus.fromString(json['status']),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    vendor: json['vendor'] != null ? Vendor.fromJson(json['vendor']) : null,
    category:
        json['category'] != null
            ? ProductCategory.fromJson(json['category'])
            : null,
    compliance:
        (json['compliance'] as List<dynamic>?)
            ?.map((e) => Compliance.fromJson(e))
            .toList() ??
        [],
    orderItems:
        (json['orderItems'] as List<dynamic>?)
            ?.map((e) => OrderItem.fromJson(e))
            .toList() ??
        [],
    notifications:
        (json['notifications'] as List<dynamic>?)
            ?.map((e) => NotificationModel.fromJson(e))
            .toList() ??
        [],
    images:
        (json['images'] as List<dynamic>?)
            ?.map((e) => ProductImage.fromJson(e))
            .toList() ??
        [],
    reviews:
        (json['reviews'] as List<dynamic>?)
            ?.map((e) => Review.fromJson(e))
            .toList() ??
        [],
    defaultCommissionPct: (json['defaultCommissionPct'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'basePrice': basePrice,
    'taxRate': taxRate,
    'price': price,
    'vendorId': vendorId,
    'categoryId': categoryId,
    'status': status.toJsonString(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'vendor': vendor?.toJson(),
    'category': category?.toJson(),
    'compliance': compliance!.map((e) => e.toJson()).toList(),
    'orderItems': orderItems.map((e) => e.toJson()).toList(),
    'notifications': notifications.map((e) => e.toJson()).toList(),
    'images': images.map((e) => e.toJson()).toList(),
    'reviews': reviews.map((e) => e.toJson()).toList(),
    'defaultCommissionPct': defaultCommissionPct,
  };
}
