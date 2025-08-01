import 'package:my_vendor_app/models/message.dart';

enum TicketType {
  GENERAL,
  TECHNICAL_ISSUE,
  DOCUMENTS,
  ACCOUNT_CLEARANCE,
  REACTIVATE_ACCOUNT,
  REFUND_REQUEST,
  ORDER_NOT_RECEIVED,
  RETURN_ISSUE,
  PAYMENT_ISSUE,
  PRODUCT_LISTING_ISSUE,
  INVENTORY_UPDATE_ISSUE,
  SHIPPING_ISSUE,
  SUPPORT,
}

enum TicketStatus { OPEN, RESPONDED, CLOSED }

class Ticket {
  final int id;
  final String subject;
  final String message;
  final TicketType type;
  final TicketStatus status;
  final int? userId;
  final int? vendorId;
  final int? customerId;
  final String? name;
  final String? email;
  final String? fileUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Message> messages; // 👈 New field

  Ticket({
    required this.id,
    required this.subject,
    required this.message,
    required this.type,
    required this.status,
    this.userId,
    this.vendorId,
    this.customerId,
    this.name,
    this.email,
    this.fileUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      subject: json['subject'],
      message: json['message'],
      type: TicketType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => TicketType.GENERAL,
      ),
      status: TicketStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TicketStatus.OPEN,
      ),
      userId: json['userId'],
      vendorId: json['vendorId'],
      customerId: json['customerId'],
      name: json['name'],
      email: json['email'],
      fileUrl: json['fileUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((m) => Message.fromJson(m))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'message': message,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'userId': userId,
      'vendorId': vendorId,
      'customerId': customerId,
      'name': name,
      'email': email,
      'fileUrl': fileUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }
}
