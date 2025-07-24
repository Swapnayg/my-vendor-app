import 'user.dart';
import 'vendor_category.dart';
import 'location_zone.dart';
import 'kyc.dart';
import 'product.dart';
import 'order.dart';
import 'payout.dart';
import 'ticket.dart';
import 'notification.dart';
import 'bank_account.dart';

enum VendorStatus { PENDING, APPROVED, REJECTED }

class Vendor {
  final int id;
  final int userId;
  final String businessName;
  final String? gstNumber;
  final String phone;
  final String address;
  final String? city;
  final String? state;
  final String? zipcode;
  final String? website;
  final String? contactName;
  final String? contactEmail;
  final String? contactPhone;
  final String? designation;
  final VendorStatus status;
  final DateTime createdAt;

  final int? categoryId;
  final int? zoneId;

  final User? user;
  final VendorCategory? category;
  final LocationZone? zone;

  final List<KYC> kycDocuments;
  final List<Product> products;
  final List<Order> orders;
  final List<Payout> payouts;
  final List<Ticket> tickets;
  final List<NotificationModel> notification;

  final BankAccount? bankAccount;

  Vendor({
    required this.id,
    required this.userId,
    required this.businessName,
    this.gstNumber,
    required this.phone,
    required this.address,
    this.city,
    this.state,
    this.zipcode,
    this.website,
    this.contactName,
    this.contactEmail,
    this.contactPhone,
    this.designation,
    required this.status,
    required this.createdAt,
    this.categoryId,
    this.zoneId,
    this.user,
    this.category,
    this.zone,
    this.kycDocuments = const [],
    this.products = const [],
    this.orders = const [],
    this.payouts = const [],
    this.tickets = const [],
    this.notification = const [],
    this.bankAccount,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'],
      userId: json['userId'],
      businessName: json['businessName'],
      gstNumber: json['gstNumber'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zipcode: json['zipcode'],
      website: json['website'],
      contactName: json['contactName'],
      contactEmail: json['contactEmail'],
      contactPhone: json['contactPhone'],
      designation: json['designation'],
      status: VendorStatus.values.firstWhere((e) => e.name == json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      categoryId: json['categoryId'],
      zoneId: json['zoneId'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      category:
          json['category'] != null
              ? VendorCategory.fromJson(json['category'])
              : null,
      zone: json['zone'] != null ? LocationZone.fromJson(json['zone']) : null,
      kycDocuments:
          (json['kycDocuments'] as List<dynamic>?)
              ?.map((e) => KYC.fromJson(e))
              .toList() ??
          [],
      products:
          (json['products'] as List<dynamic>?)
              ?.map((e) => Product.fromJson(e))
              .toList() ??
          [],
      orders:
          (json['orders'] as List<dynamic>?)
              ?.map((e) => Order.fromJson(e))
              .toList() ??
          [],
      payouts:
          (json['payouts'] as List<dynamic>?)
              ?.map((e) => Payout.fromJson(e))
              .toList() ??
          [],
      tickets:
          (json['tickets'] as List<dynamic>?)
              ?.map((e) => Ticket.fromJson(e))
              .toList() ??
          [],
      notification:
          (json['notification'] as List<dynamic>?)
              ?.map((e) => NotificationModel.fromJson(e))
              .toList() ??
          [],
      bankAccount:
          json['bankAccount'] != null
              ? BankAccount.fromJson(json['bankAccount'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'businessName': businessName,
      'gstNumber': gstNumber,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'zipcode': zipcode,
      'website': website,
      'contactName': contactName,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'designation': designation,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'categoryId': categoryId,
      'zoneId': zoneId,
      'user': user?.toJson(),
      'category': category?.toJson(),
      'zone': zone?.toJson(),
      'kycDocuments': kycDocuments.map((e) => e.toJson()).toList(),
      'products': products.map((e) => e.toJson()).toList(),
      'orders': orders.map((e) => e.toJson()).toList(),
      'payouts': payouts.map((e) => e.toJson()).toList(),
      'tickets': tickets.map((e) => e.toJson()).toList(),
      'notification': notification.map((e) => e.toJson()).toList(),
      'bankAccount': bankAccount?.toJson(),
    };
  }
}
