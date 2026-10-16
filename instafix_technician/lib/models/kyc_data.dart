import 'package:flutter/material.dart';

class KycData {
  final String status; // 'NOT_SUBMITTED', 'PENDING', 'VERIFIED', 'REJECTED'
  final String aadhaarNumber;
  final String aadhaarFrontUrl;
  final String aadhaarBackUrl;
  final String panNumber;
  final String panCardUrl;
  final String bikeNumber;
  final String bikeRcUrl;
  final String? paymentScreenshotUrl;
  final bool paymentVerified;
  final String? submittedAt;
  final String? verifiedAt;
  final String? rejectionReason;
  final String? adminNotes;

  const KycData({
    required this.status,
    required this.aadhaarNumber,
    required this.aadhaarFrontUrl,
    required this.aadhaarBackUrl,
    required this.panNumber,
    required this.panCardUrl,
    required this.bikeNumber,
    required this.bikeRcUrl,
    this.paymentScreenshotUrl,
    this.paymentVerified = false,
    this.submittedAt,
    this.verifiedAt,
    this.rejectionReason,
    this.adminNotes,
  });

  factory KycData.initial() {
    return const KycData(
      status: 'NOT_SUBMITTED',
      aadhaarNumber: '',
      aadhaarFrontUrl: '',
      aadhaarBackUrl: '',
      panNumber: '',
      panCardUrl: '',
      bikeNumber: '',
      bikeRcUrl: '',
      paymentScreenshotUrl: null,
      paymentVerified: false,
    );
  }

  bool get isVerified => status == 'VERIFIED';
  bool get isPending => status == 'PENDING';
  bool get isNotSubmitted => status == 'NOT_SUBMITTED';
  bool get isRejected => status == 'REJECTED';

  String get statusDisplay {
    switch (status) {
      case 'VERIFIED':
        return 'KYC Verified';
      case 'PENDING':
        return 'Under Admin Review';
      case 'REJECTED':
        return 'KYC Rejected';
      default:
        return 'Not Submitted';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'VERIFIED':
        return const Color(0xFF10B981); // Green
      case 'PENDING':
        return const Color(0xFFF59E0B); // Amber / Yellow
      case 'REJECTED':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray / Muted
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'VERIFIED':
        return Icons.verified_rounded;
      case 'PENDING':
        return Icons.hourglass_top_rounded;
      case 'REJECTED':
        return Icons.cancel_rounded;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  KycData copyWith({
    String? status,
    String? aadhaarNumber,
    String? aadhaarFrontUrl,
    String? aadhaarBackUrl,
    String? panNumber,
    String? panCardUrl,
    String? bikeNumber,
    String? bikeRcUrl,
    String? paymentScreenshotUrl,
    bool? paymentVerified,
    String? submittedAt,
    String? verifiedAt,
    String? rejectionReason,
    String? adminNotes,
  }) {
    return KycData(
      status: status ?? this.status,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      aadhaarFrontUrl: aadhaarFrontUrl ?? this.aadhaarFrontUrl,
      aadhaarBackUrl: aadhaarBackUrl ?? this.aadhaarBackUrl,
      panNumber: panNumber ?? this.panNumber,
      panCardUrl: panCardUrl ?? this.panCardUrl,
      bikeNumber: bikeNumber ?? this.bikeNumber,
      bikeRcUrl: bikeRcUrl ?? this.bikeRcUrl,
      paymentScreenshotUrl: paymentScreenshotUrl ?? this.paymentScreenshotUrl,
      paymentVerified: paymentVerified ?? this.paymentVerified,
      submittedAt: submittedAt ?? this.submittedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'aadhaar_number': aadhaarNumber,
      'aadhaar_front_url': aadhaarFrontUrl,
      'aadhaar_back_url': aadhaarBackUrl,
      'pan_number': panNumber,
      'pan_card_url': panCardUrl,
      'bike_number': bikeNumber,
      'bike_rc_url': bikeRcUrl,
      'payment_screenshot_url': paymentScreenshotUrl,
      'payment_verified': paymentVerified,
      'submitted_at': submittedAt,
      'verified_at': verifiedAt,
      'rejection_reason': rejectionReason,
      'admin_notes': adminNotes,
    };
  }

  factory KycData.fromJson(Map<String, dynamic> json) {
    return KycData(
      status: json['status'] ?? 'NOT_SUBMITTED',
      aadhaarNumber: json['aadhaar_number'] ?? '',
      aadhaarFrontUrl: json['aadhaar_front_url'] ?? '',
      aadhaarBackUrl: json['aadhaar_back_url'] ?? '',
      panNumber: json['pan_number'] ?? '',
      panCardUrl: json['pan_card_url'] ?? '',
      bikeNumber: json['bike_number'] ?? '',
      bikeRcUrl: json['bike_rc_url'] ?? '',
      paymentScreenshotUrl: json['payment_screenshot_url'],
      paymentVerified: json['payment_verified'] == true || json['payment_verified'] == 1,
      submittedAt: json['submitted_at'],
      verifiedAt: json['verified_at'],
      rejectionReason: json['rejection_reason'],
      adminNotes: json['admin_notes'],
    );
  }
}
