enum VendorStatus { PENDING, APPROVED, REJECTED, SUSPENDED }

class Vendor {
  final int id;
  final String businessName;
  final String phone;
  final String address;
  final String? gstNumber;
  final VendorStatus status;

  Vendor({
    required this.id,
    required this.businessName,
    required this.phone,
    required this.address,
    this.gstNumber,
    required this.status,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'],
      businessName: json['businessName'],
      phone: json['phone'],
      address: json['address'],
      gstNumber: json['gstNumber'],
      status: VendorStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => VendorStatus.PENDING,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessName': businessName,
      'phone': phone,
      'address': address,
      'gstNumber': gstNumber,
      'status': status.name,
    };
  }
}
