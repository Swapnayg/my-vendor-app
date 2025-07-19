class Vendor {
  final int id;
  final String businessName;
  final String phone;
  final String address;
  final String? gstNumber;
  final String status;

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
      status: json['status'],
    );
  }
}
