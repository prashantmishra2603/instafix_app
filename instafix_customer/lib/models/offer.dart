class Offer {
  final int id;
  final String title;
  final String? subtitle;
  final String? code;
  final int discountPercentage;
  final double? discountAmount;
  final String? imageUrl;
  final String bgColor;
  final bool isActive;
  final String? validUntil;

  Offer({
    required this.id,
    required this.title,
    this.subtitle,
    this.code,
    this.discountPercentage = 0,
    this.discountAmount,
    this.imageUrl,
    this.bgColor = '#4f46e5',
    this.isActive = true,
    this.validUntil,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      code: json['code'],
      discountPercentage: json['discount_percentage'] is int
          ? json['discount_percentage']
          : int.tryParse(json['discount_percentage']?.toString() ?? '0') ?? 0,
      discountAmount: json['discount_amount'] != null
          ? double.tryParse(json['discount_amount'].toString())
          : null,
      imageUrl: json['image_url'],
      bgColor: json['bg_color'] ?? '#4f46e5',
      isActive: json['is_active'] == true || json['is_active'] == 1,
      validUntil: json['valid_until'],
    );
  }
}
