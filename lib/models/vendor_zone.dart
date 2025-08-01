import 'package:my_vendor_app/models/location_zone.dart';

class VendorZone {
  final int? id;
  final int vendorId;
  final int? zoneId; // make this nullable
  final LocationZone zone;

  VendorZone({
    this.id,
    required this.vendorId,
    this.zoneId,
    required this.zone,
  });

  factory VendorZone.fromJson(Map<String, dynamic> json) {
    return VendorZone(
      id: json['id'],
      vendorId: json['vendorId'],
      zoneId: json['zoneId'],
      zone: LocationZone.fromJson(json['zone']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendorId': vendorId,
      'zoneId': zoneId,
      'zone': zone.toJson(),
    };
  }
}
