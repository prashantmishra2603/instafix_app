class DiagnosticData {
  final int? id;
  final int bookingId;
  final Map<String, bool> preRepairChecks;
  final String? preNotes;
  final List<String> prePhotos;
  
  // Additional Work Approval
  final String? additionalTitle;
  final String? additionalDescription;
  final double? additionalAmount;
  final String approvalStatus; // 'NONE', 'PENDING', 'APPROVED', 'REJECTED'

  final Map<String, bool> postRepairChecks;
  final String? postNotes;
  final List<String> postPhotos;

  DiagnosticData({
    this.id,
    required this.bookingId,
    required this.preRepairChecks,
    this.preNotes,
    this.prePhotos = const [],
    this.additionalTitle,
    this.additionalDescription,
    this.additionalAmount,
    this.approvalStatus = 'NONE',
    required this.postRepairChecks,
    this.postNotes,
    this.postPhotos = const [],
  });

  factory DiagnosticData.fromJson(Map<String, dynamic> json) {
    Map<String, bool> parseChecks(dynamic val) {
      if (val is Map) {
        return val.map((k, v) => MapEntry(k.toString(), v == true || v == 1 || v.toString() == 'true'));
      }
      return {
        'display': true,
        'touch': true,
        'battery': true,
        'camera': true,
        'speaker': true,
        'mic': true,
        'wifi': true,
        'charging': true,
        'buttons': true,
      };
    }

    List<String> parsePhotos(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return [];
    }

    return DiagnosticData(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.parse(json['id'].toString()) : null),
      bookingId: json['booking_id'] is int ? json['booking_id'] : int.parse(json['booking_id'].toString()),
      preRepairChecks: parseChecks(json['pre_repair_checks']),
      preNotes: json['pre_notes'],
      prePhotos: parsePhotos(json['pre_photos']),
      additionalTitle: json['additional_title'],
      additionalDescription: json['additional_description'],
      additionalAmount: json['additional_amount'] != null ? double.tryParse(json['additional_amount'].toString()) : null,
      approvalStatus: json['approval_status'] ?? 'NONE',
      postRepairChecks: parseChecks(json['post_repair_checks']),
      postNotes: json['post_notes'],
      postPhotos: parsePhotos(json['post_photos']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'pre_repair_checks': preRepairChecks,
      'pre_notes': preNotes,
      'pre_photos': prePhotos,
      'additional_title': additionalTitle,
      'additional_description': additionalDescription,
      'additional_amount': additionalAmount,
      'approval_status': approvalStatus,
      'post_repair_checks': postRepairChecks,
      'post_notes': postNotes,
      'post_photos': postPhotos,
    };
  }
}
