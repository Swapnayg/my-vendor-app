enum NotificationType {
  ORDER_UPDATE,
  PRODUCT_STATUS,
  VENDOR_APPROVAL,
  VENDOR_REGISTRATION,
  ADMIN_ALERT,
  GENERAL,
}

class Notification {
  final int id;
  final String title;
  final String message;
  final bool read;
  final NotificationType type;
  final DateTime createdAt;

  final int? userId;
  final int? vendorId;
  final int? adminId;
  final int? customerId;
  final int? orderId;
  final int? productId;

  // Optional related models (stub as dynamic for now)
  final dynamic user;
  final dynamic vendor;
  final dynamic admin;
  final dynamic customer;
  final dynamic order;
  final dynamic product;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    this.read = false,
    required this.type,
    required this.createdAt,
    this.userId,
    this.vendorId,
    this.adminId,
    this.customerId,
    this.orderId,
    this.productId,
    this.user,
    this.vendor,
    this.admin,
    this.customer,
    this.order,
    this.product,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      read: json['read'] ?? false,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.GENERAL,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      userId: json['userId'],
      vendorId: json['vendorId'],
      adminId: json['adminId'],
      customerId: json['customerId'],
      orderId: json['orderId'],
      productId: json['productId'],
      user: json['user'],
      vendor: json['vendor'],
      admin: json['admin'],
      customer: json['customer'],
      order: json['order'],
      product: json['product'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'read': read,
    'type': type.name,
    'createdAt': createdAt.toIso8601String(),
    'userId': userId,
    'vendorId': vendorId,
    'adminId': adminId,
    'customerId': customerId,
    'orderId': orderId,
    'productId': productId,
    'user': user,
    'vendor': vendor,
    'admin': admin,
    'customer': customer,
    'order': order,
    'product': product,
  };
}
