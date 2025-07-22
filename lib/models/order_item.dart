import 'product.dart'; // Make sure this import points to your actual Product model

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double basePrice;
  final double taxRate;
  final double taxAmount;
  final double price;
  final double? commissionPct;
  final double? commissionAmt;
  final Product? product; // Included product details

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.basePrice,
    required this.taxRate,
    required this.taxAmount,
    required this.price,
    this.commissionPct,
    this.commissionAmt,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['orderId'],
      productId: json['productId'],
      quantity: json['quantity'],
      basePrice: (json['basePrice'] as num).toDouble(),
      taxRate: (json['taxRate'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      commissionPct:
          json['commissionPct'] != null
              ? (json['commissionPct'] as num).toDouble()
              : null,
      commissionAmt:
          json['commissionAmt'] != null
              ? (json['commissionAmt'] as num).toDouble()
              : null,
      product:
          json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'quantity': quantity,
      'basePrice': basePrice,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'price': price,
      'commissionPct': commissionPct,
      'commissionAmt': commissionAmt,
      'product': product?.toJson(),
    };
  }
}
