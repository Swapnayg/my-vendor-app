class OrderItem {
  final int id;
  final String productId;
  final int quantity;
  final double basePrice;
  final double taxRate;
  final double taxAmount;
  final double price;
  late String name;
  late String status;
  late String date;
  late String initials;
  late String orderId;
  late String amount;

  OrderItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.basePrice,
    required this.taxRate,
    required this.taxAmount,
    required this.price,
    required String initials,
    required String amount,
    required String orderId,
    required String name,
    required String status,
    required String date,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productId: json['productId'],
      quantity: json['quantity'],
      basePrice: json['basePrice'].toDouble(),
      taxRate: json['taxRate'].toDouble(),
      taxAmount: json['taxAmount'].toDouble(),
      price: json['price'].toDouble(),
      initials: '',
      amount: '',
      orderId: '',
      name: '',
      status: '',
      date: '',
    );
  }
}
