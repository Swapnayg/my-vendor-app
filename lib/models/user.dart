import 'review.dart';
import 'notification.dart';

enum UserRole { CUSTOMER, VENDOR, ADMIN }

class User {
  final int id;
  final String email;
  final String username;
  final String password;
  final String? avatarUrl;
  final String? tempPassword;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations (optional or lists)
  final List<Review>? reviews;
  final List<NotificationModel>? notifications;

  // Stub placeholders for referenced models
  // You can replace these with real classes once available
  final dynamic vendor;
  final dynamic customer;
  final dynamic admin;
  final List<dynamic>? tickets;
  final List<dynamic>? messages;
  final List<dynamic>? apiKeys;
  final List<dynamic>? auditLogs;
  final List<dynamic>? passwordReset;
  final List<dynamic>? usages;
  final List<dynamic>? pages;

  User({
    required this.id,
    this.avatarUrl,
    required this.email,
    required this.username,
    required this.password,
    this.tempPassword,
    this.role = UserRole.CUSTOMER,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.vendor,
    this.customer,
    this.admin,
    this.reviews,
    this.notifications,
    this.tickets,
    this.messages,
    this.apiKeys,
    this.auditLogs,
    this.passwordReset,
    this.usages,
    this.pages,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      password: json['password'],
      tempPassword: json['tempPassword'],
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.CUSTOMER,
      ),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      reviews:
          json['reviews'] != null
              ? List<Review>.from(
                json['reviews'].map((x) => Review.fromJson(x)),
              )
              : null,
      notifications:
          json['notification'] != null
              ? List<NotificationModel>.from(
                json['notification'].map((x) => NotificationModel.fromJson(x)),
              )
              : null,
      vendor: json['vendor'],
      customer: json['customer'],
      admin: json['admin'],
      tickets: json['tickets'],
      messages: json['messages'],
      apiKeys: json['apiKeys'],
      auditLogs: json['auditLogs'],
      passwordReset: json['passwordReset'],
      usages: json['usages'],
      pages: json['pages'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'password': password,
    'tempPassword': tempPassword,
    'role': role.name,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'reviews': reviews?.map((x) => x.toJson()).toList(),
    'notification': notifications?.map((x) => x.toJson()).toList(),
    'vendor': vendor,
    'customer': customer,
    'admin': admin,
    'tickets': tickets,
    'messages': messages,
    'apiKeys': apiKeys,
    'auditLogs': auditLogs,
    'passwordReset': passwordReset,
    'usages': usages,
    'pages': pages,
  };
}
