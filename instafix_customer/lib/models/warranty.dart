class Warranty {
  final int id;
  final int bookingId;
  final int customerId;
  final String serviceName;
  final String deviceModelName;
  final String startDate;
  final String endDate;
  final int daysRemaining;
  final String status; // 'active', 'expired', 'claimed'

  Warranty({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.serviceName,
    required this.deviceModelName,
    required this.startDate,
    required this.endDate,
    required this.daysRemaining,
    required this.status,
  });

  factory Warranty.fromJson(Map<String, dynamic> json) {
    return Warranty(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      bookingId: json['booking_id'] is int ? json['booking_id'] : int.parse(json['booking_id'].toString()),
      customerId: json['customer_id'] is int ? json['customer_id'] : int.parse(json['customer_id'].toString()),
      serviceName: json['service_name'] ?? 'Device Repair Warranty',
      deviceModelName: json['device_model_name'] ?? 'Mobile Device',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      daysRemaining: json['days_remaining'] is int ? json['days_remaining'] : int.parse((json['days_remaining'] ?? 90).toString()),
      status: json['status'] ?? 'active',
    );
  }
}

class WarrantyClaim {
  final int id;
  final int warrantyId;
  final String description;
  final String status; // 'pending', 'approved', 'rejected', 'resolved'
  final String createdAt;

  WarrantyClaim({
    required this.id,
    required this.warrantyId,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory WarrantyClaim.fromJson(Map<String, dynamic> json) {
    return WarrantyClaim(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      warrantyId: json['warranty_id'] is int ? json['warranty_id'] : int.parse(json['warranty_id'].toString()),
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
    );
  }
}
