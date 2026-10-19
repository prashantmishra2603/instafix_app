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
    final parsedId = json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0;
    final parsedServiceId = json['service_id'] is int
        ? json['service_id'] as int
        : int.tryParse((json['service_id'] ?? 1).toString()) ?? 1;
    final parsedPrice = json['price'] is num
        ? (json['price'] as num).toDouble()
        : double.tryParse(json['price']?.toString() ?? '') ?? 0.0;

    return PartOption(
      id: parsedId,
      serviceId: parsedServiceId,
      name: json['name'] ?? 'Standard Part',
      price: parsedPrice,
      warrantyPeriod: json['warranty_period'] ?? '3 Months',
      isPopular: json['is_popular'] == true || json['is_popular'] == 1 || json['is_popular'] == '1',
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
  final String repairCategory;
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
    this.repairCategory = 'General',
    this.partOptions = const [],
  });

  factory RepairService.fromJson(Map<String, dynamic> json) {
    var partOptsJson = json['part_options'] as List? ?? [];
    List<PartOption> opts = partOptsJson.map((x) => PartOption.fromJson(x)).toList();
    
    final serviceId = json['id'] is int
        ? json['id'] as int
        : int.tryParse(json['id']?.toString() ?? '') ?? 0;
        
    final base = json['base_price'] is num
        ? (json['base_price'] as num).toDouble()
        : double.tryParse(json['base_price']?.toString() ?? '') ?? 0.0;

    if (opts.isEmpty && base > 0) {
      opts = [
        PartOption(
          id: serviceId * 10 + 1,
          serviceId: serviceId,
          name: 'Standard OEM Part',
          price: base,
          warrantyPeriod: '30 Days',
        ),
        PartOption(
          id: serviceId * 10 + 2,
          serviceId: serviceId,
          name: 'Premium Part',
          price: (base * 1.3).roundToDouble(),
          warrantyPeriod: '90 Days',
          isPopular: true,
        ),
      ];
    }

    final parsedWarranty = json['warranty_days'] is int
        ? json['warranty_days'] as int
        : int.tryParse((json['warranty_days'] ?? 90).toString()) ?? 90;

    final parsedBrandId = json['brand_id'] != null
        ? (json['brand_id'] is int ? json['brand_id'] as int : int.tryParse(json['brand_id'].toString()))
        : null;

    final parsedModelId = json['model_id'] != null
        ? (json['model_id'] is int ? json['model_id'] as int : int.tryParse(json['model_id'].toString()))
        : null;

    return RepairService(
      id: serviceId,
      deviceCategory: json['device_category'] ?? 'smartphone',
      brandId: parsedBrandId,
      modelId: parsedModelId,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      basePrice: base,
      warrantyDays: parsedWarranty,
      icon: json['icon'] ?? 'build',
      repairCategory: json['category']?.toString() ?? 'General',
      partOptions: opts,
    );
  }
}
