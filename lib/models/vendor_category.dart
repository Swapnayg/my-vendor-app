class VendorCategory {
  final int id;
  final String name;
  final String? description;

  VendorCategory({required this.id, required this.name, this.description});

  factory VendorCategory.fromJson(Map<String, dynamic> json) {
    return VendorCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }
}
