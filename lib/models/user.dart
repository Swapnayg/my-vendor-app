import 'review.dart';
import 'notification.dart';

enum UserRole { CUSTOMER, VENDOR, ADMIN }

class User {
  final int id;
  final String? email;
  final String? username;
  final String? password;
  final String? avatarUrl;
  final String? tempPassword;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int unreadCount;

  // Relations
  final List<Review>? reviews;
  final List<NotificationModel>? notifications;

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
    this.email,
    this.username,
    this.password,
    this.avatarUrl,
    this.tempPassword,
    this.role = UserRole.CUSTOMER,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.reviews,
    this.notifications,
    required this.unreadCount,
    this.vendor,
    this.customer,
    this.admin,
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
      id: json['id'] ?? 0,
      email: json['email']?.toString(),
      username: json['username']?.toString(),
      password: json['password']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      tempPassword: json['tempPassword']?.toString(),
      role: UserRole.values.firstWhere(
        (e) => e.name == (json['role'] ?? 'CUSTOMER'),
        orElse: () => UserRole.CUSTOMER,
      ),
      isActive: json['isActive'] ?? true,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      unreadCount: json['unreadCount'] ?? 0,
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
    'avatarUrl': avatarUrl,
    'role': role.name,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'unreadCount': unreadCount,
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
