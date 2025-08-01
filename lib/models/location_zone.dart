class LocationZone {
  final int id;
  final String name;
  final String? country;
  final String? region;

  LocationZone({
    required this.id,
    required this.name,
    this.country,
    this.region,
  });

  factory LocationZone.fromJson(Map<String, dynamic> json) {
    return LocationZone(
      id: json['id'],
      name: json['name'],
      country: json['country'],
      region: json['region'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'country': country, 'region': region};
  }
}
