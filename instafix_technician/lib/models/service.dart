class PartOption {
  final int id;
  final int serviceId;
  final String name;
  final double price;
  final String warrantyPeriod;
  final bool isPopular;

  PartOption({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.price,
    required this.warrantyPeriod,
    this.isPopular = false,
  });

  factory PartOption.fromJson(Map<String, dynamic> json) {
    return PartOption(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      serviceId: json['service_id'] is int ? json['service_id'] : int.parse((json['service_id'] ?? 1).toString()),
      name: json['name'] ?? 'Standard Part',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      warrantyPeriod: json['warranty_period'] ?? '3 Months',
      isPopular: json['is_popular'] == true || json['is_popular'] == 1,
    );
  }
}

class RepairService {
  final int id;
  final String deviceCategory;
  final int? brandId;
  final int? modelId;
  final String name;
  final String description;
  final double basePrice;
  final int warrantyDays;
  final String icon;
  final List<PartOption> partOptions;

  RepairService({
    required this.id,
    required this.deviceCategory,
    this.brandId,
    this.modelId,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.warrantyDays,
    required this.icon,
    this.partOptions = const [],
  });

  factory RepairService.fromJson(Map<String, dynamic> json) {
    var partOptsJson = json['part_options'] as List? ?? [];
    List<PartOption> opts = partOptsJson.map((x) => PartOption.fromJson(x)).toList();

    return RepairService(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      deviceCategory: json['device_category'] ?? 'smartphone',
      brandId: json['brand_id'] != null ? (json['brand_id'] is int ? json['brand_id'] : int.parse(json['brand_id'].toString())) : null,
      modelId: json['model_id'] != null ? (json['model_id'] is int ? json['model_id'] : int.parse(json['model_id'].toString())) : null,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      warrantyDays: json['warranty_days'] is int ? json['warranty_days'] : int.parse((json['warranty_days'] ?? 90).toString()),
      icon: json['icon'] ?? 'build',
      partOptions: opts,
    );
  }
}
