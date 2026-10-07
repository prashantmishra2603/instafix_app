class DeviceCategory {
  final String id;
  final String name;
  final String icon;

  DeviceCategory({required this.id, required this.name, required this.icon});
}

class Brand {
  final int id;
  final String category;
  final String name;
  final String logo;

  Brand({required this.id, required this.category, required this.name, required this.logo});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      category: json['category'] ?? 'smartphone',
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
    );
  }
}

class DeviceModel {
  final int id;
  final int brandId;
  final String category;
  final String name;
  final String image;

  DeviceModel({
    required this.id,
    required this.brandId,
    required this.category,
    required this.name,
    required this.image,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      brandId: json['brand_id'] is int ? json['brand_id'] : int.parse((json['brand_id'] ?? 1).toString()),
      category: json['category'] ?? 'smartphone',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
