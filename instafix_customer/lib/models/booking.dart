import 'diagnostic.dart';

class Booking {
  final int id;
  final String bookingNumber;
  final int customerId;
  final String customerName;
  final String customerPhone;
  final int? technicianId;
  final String? technicianName;
  final String? technicianPhone;
  final String deviceCategory;
  final String brandName;
  final String modelName;
  final String serviceName;
  final String partOptionName;
  final String addressLine;
  final String scheduledSlot;
  final String status; // PENDING, CONFIRMED, TECHNICIAN_ASSIGNED, TECHNICIAN_ON_WAY, ARRIVED, DIAGNOSIS, WAITING_FOR_APPROVAL, REPAIRING, QC, COMPLETED, CANCELLED, REJECTED
  final double estimateAmount;
  final double? additionalAmount;
  final double finalAmount;
  final String paymentStatus; // 'PENDING', 'PAID'
  final String createdAt;
  final DiagnosticData? diagnostic;

  Booking({
    required this.id,
    required this.bookingNumber,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    this.technicianId,
    this.technicianName,
    this.technicianPhone,
    required this.deviceCategory,
    required this.brandName,
    required this.modelName,
    required this.serviceName,
    required this.partOptionName,
    required this.addressLine,
    required this.scheduledSlot,
    required this.status,
    required this.estimateAmount,
    this.additionalAmount,
    required this.finalAmount,
    required this.paymentStatus,
    required this.createdAt,
    this.diagnostic,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    String custName = json['customer_name'] ??
        json['customer']?['name'] ??
        json['user']?['name'] ??
        json['client_name'] ??
        'Customer';

    String custPhone = json['customer_phone'] ??
        json['customer']?['phone'] ??
        json['user']?['phone'] ??
        json['phone'] ??
        '';

    String techName = json['technician_name'] ??
        json['technician']?['name'] ??
        json['tech']?['name'] ??
        '';

    String techPhone = json['technician_phone'] ??
        json['technician']?['phone'] ??
        json['tech']?['phone'] ??
        '';

    double parseAmount(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    final double estCost = parseAmount(json['estimated_cost'] ?? json['estimate_amount']);
    final double finCost = parseAmount(json['final_cost'] ?? json['final_amount'] ?? estCost);
    final double? addCost = json['additional_amount'] != null ? parseAmount(json['additional_amount']) : null;

    final rawStatus = (json['status']?.toString() ?? 'PENDING').toUpperCase();

    return Booking(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 1001,
      bookingNumber: json['booking_code'] ?? json['booking_number'] ?? 'IFX-${json['id'] ?? '0000'}',
      customerId: json['customer_id'] is int ? json['customer_id'] : int.tryParse((json['customer_id'] ?? 0).toString()) ?? 0,
      customerName: custName,
      customerPhone: custPhone,
      technicianId: json['technician_id'] != null
          ? (json['technician_id'] is int ? json['technician_id'] : int.tryParse(json['technician_id'].toString()))
          : null,
      technicianName: techName.isNotEmpty ? techName : null,
      technicianPhone: techPhone.isNotEmpty ? techPhone : null,
      deviceCategory: json['device_category'] ?? json['category'] ?? 'smartphone',
      brandName: json['brand_name'] ?? json['brand']?['name'] ?? 'Apple',
      modelName: json['model_name'] ?? json['device_model']?['name'] ?? 'iPhone 15 Pro',
      serviceName: json['service_name'] ?? json['service']?['name'] ?? 'Screen Replacement',
      partOptionName: json['part_option_name'] ?? json['part_name'] ?? 'Original OEM Display',
      addressLine: json['customer_address'] ?? json['address_line'] ?? json['address'] ?? '123 Tech Park, Suite 400',
      scheduledSlot: json['time_slot'] ?? json['scheduled_slot'] ?? json['slot'] ?? 'Today, 2:00 PM - 4:00 PM',
      status: rawStatus,
      estimateAmount: estCost,
      additionalAmount: addCost,
      finalAmount: finCost > 0 ? finCost : estCost,
      paymentStatus: (json['payment_status']?.toString() ?? 'PENDING').toUpperCase(),
      createdAt: json['created_at']?.toString() ?? 'Just now',
      diagnostic: json['diagnostic'] != null ? DiagnosticData.fromJson(json['diagnostic']) : null,
    );
  }

  Booking copyWith({
    String? status,
    String? technicianName,
    String? technicianPhone,
    int? technicianId,
    double? additionalAmount,
    double? finalAmount,
    String? paymentStatus,
    DiagnosticData? diagnostic,
  }) {
    return Booking(
      id: id,
      bookingNumber: bookingNumber,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      technicianId: technicianId ?? this.technicianId,
      technicianName: technicianName ?? this.technicianName,
      technicianPhone: technicianPhone ?? this.technicianPhone,
      deviceCategory: deviceCategory,
      brandName: brandName,
      modelName: modelName,
      serviceName: serviceName,
      partOptionName: partOptionName,
      addressLine: addressLine,
      scheduledSlot: scheduledSlot,
      status: status ?? this.status,
      estimateAmount: estimateAmount,
      additionalAmount: additionalAmount ?? this.additionalAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt,
      diagnostic: diagnostic ?? this.diagnostic,
    );
  }

  // Display status helpers
  String get statusDisplay {
    switch (status) {
      case 'PENDING':
        return 'Booking Submitted';
      case 'CONFIRMED':
        return 'Booking Confirmed';
      case 'TECHNICIAN_ASSIGNED':
        return 'Technician Assigned';
      case 'TECHNICIAN_ON_WAY':
        return 'Technician En Route';
      case 'ARRIVED':
        return 'Technician Arrived';
      case 'DIAGNOSIS':
        return 'Pre-Repair Inspection';
      case 'WAITING_FOR_APPROVAL':
        return 'Approval Required';
      case 'REPAIRING':
        return 'Repair in Progress';
      case 'QC':
        return 'Quality Check (QC)';
      case 'COMPLETED':
        return 'Repair Completed';
      case 'CANCELLED':
        return 'Cancelled';
      case 'REJECTED':
        return 'Rejected';
      default:
        return status;
    }
  }

  int get statusStepIndex {
    switch (status) {
      case 'PENDING':
      case 'CONFIRMED':
        return 0;
      case 'TECHNICIAN_ASSIGNED':
      case 'TECHNICIAN_ON_WAY':
        return 1;
      case 'ARRIVED':
      case 'DIAGNOSIS':
      case 'WAITING_FOR_APPROVAL':
        return 2;
      case 'REPAIRING':
        return 3;
      case 'QC':
        return 4;
      case 'COMPLETED':
        return 5;
      default:
        return 0;
    }
  }
}
