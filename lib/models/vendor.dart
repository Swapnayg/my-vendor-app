import 'package:my_vendor_app/models/location_zone.dart';
import 'package:my_vendor_app/models/vendor_zone.dart';
import 'package:my_vendor_app/models/kyc.dart';
import 'package:my_vendor_app/models/product.dart';
import 'package:my_vendor_app/models/order.dart';
import 'package:my_vendor_app/models/payout.dart';
import 'package:my_vendor_app/models/ticket.dart';
import 'package:my_vendor_app/models/notification.dart';
import 'package:my_vendor_app/models/bank_account.dart';
import 'package:my_vendor_app/models/stock_movement.dart';
import 'package:my_vendor_app/models/vendor_category.dart'; // <-- import this

enum VendorStatus {
  PENDING,
  APPROVED,
  REJECTED,
  SUSPENDED;

  static VendorStatus fromString(String status) {
    return VendorStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == status.toUpperCase(),
      orElse: () => VendorStatus.PENDING,
    );
  }

  String toJson() => name;
}

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
  final bool isActive;
  final DateTime? deactivatedAt;
  final int? categoryId;

  final VendorCategory? category; // <-- NEW
  final List<VendorZone> zones;
  final List<KYC> kycDocuments;
  final List<Product> products;
  final List<Order> orders;
  final List<Payout> payouts;
  final List<Ticket> tickets;
  final List<NotificationModel> notification;
  final BankAccount? bankAccount;
  final List<StockMovement> stockMovements;

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
    required this.isActive,
    this.deactivatedAt,
    this.categoryId,
    this.category,
    required this.zones,
    required this.kycDocuments,
    required this.products,
    required this.orders,
    required this.payouts,
    required this.tickets,
    required this.notification,
    this.bankAccount,
    required this.stockMovements,
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
      status: VendorStatus.fromString(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'],
      deactivatedAt:
          json['deactivatedAt'] != null
              ? DateTime.tryParse(json['deactivatedAt'])
              : null,
      categoryId: json['categoryId'],
      category:
          json['category'] != null
              ? VendorCategory.fromJson(json['category'])
              : null,
      zones:
          (json['zones'] as List<dynamic>?)
              ?.map((z) {
                final zoneMap = z as Map<String, dynamic>?;

                if (zoneMap == null) return null;

                return VendorZone(
                  id: null,
                  vendorId: json['id'],
                  zoneId: zoneMap['id'],
                  zone: LocationZone.fromJson(zoneMap),
                );
              })
              .whereType<VendorZone>()
              .toList() ??
          [],

      kycDocuments:
          json['kycDocuments'] != null
              ? List<KYC>.from(json['kycDocuments'].map((k) => KYC.fromJson(k)))
              : [],
      products:
          json['products'] != null
              ? List<Product>.from(
                json['products'].map((p) => Product.fromJson(p)),
              )
              : [],
      orders:
          json['orders'] != null
              ? List<Order>.from(json['orders'].map((o) => Order.fromJson(o)))
              : [],
      payouts:
          json['payouts'] != null
              ? List<Payout>.from(
                json['payouts'].map((p) => Payout.fromJson(p)),
              )
              : [],
      tickets:
          json['tickets'] != null
              ? List<Ticket>.from(
                json['tickets'].map((t) => Ticket.fromJson(t)),
              )
              : [],
      notification:
          json['notification'] != null
              ? List<NotificationModel>.from(
                json['notification'].map((n) => NotificationModel.fromJson(n)),
              )
              : [],
      bankAccount:
          json['bankAccount'] != null
              ? BankAccount.fromJson(json['bankAccount'])
              : null,
      stockMovements:
          json['stockMovements'] != null
              ? List<StockMovement>.from(
                json['stockMovements'].map((s) => StockMovement.fromJson(s)),
              )
              : [],
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
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'deactivatedAt': deactivatedAt?.toIso8601String(),
      'categoryId': categoryId,
      'category': category?.toJson(), // <-- NEW
      'zones': zones.map((z) => z.toJson()).toList(),
      'kycDocuments': kycDocuments.map((k) => k.toJson()).toList(),
      'products': products.map((p) => p.toJson()).toList(),
      'orders': orders.map((o) => o.toJson()).toList(),
      'payouts': payouts.map((p) => p.toJson()).toList(),
      'tickets': tickets.map((t) => t.toJson()).toList(),
      'notification': notification.map((n) => n.toJson()).toList(),
      'bankAccount': bankAccount?.toJson(),
      'stockMovements': stockMovements.map((s) => s.toJson()).toList(),
    };
  }
}
