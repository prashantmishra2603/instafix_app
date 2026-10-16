import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking.dart';
import '../models/diagnostic.dart';
import '../models/kyc_data.dart';
import '../services/api_service.dart';
import 'booking_provider.dart';

class TechnicianProvider extends ChangeNotifier {
  // ── KYC State & Persistence ─────────────────────────────────────────────
  KycData _kyc = KycData.initial();
  bool _isKycLoading = true;

  KycData get kyc => _kyc;
  bool get isKycLoading => _isKycLoading;
  bool get isKycVerified => _kyc.isVerified;

  TechnicianProvider() {
    _loadSavedKyc();
  }

  Future<void> _loadSavedKyc() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final status = prefs.getString('kyc_status') ?? 'NOT_SUBMITTED';
      final aadhaar = prefs.getString('kyc_aadhaar') ?? '';
      final pan = prefs.getString('kyc_pan') ?? '';
      final bike = prefs.getString('kyc_bike') ?? '';
      final aadhaarFront = prefs.getString('kyc_aadhaar_front') ?? '';
      final aadhaarBack = prefs.getString('kyc_aadhaar_back') ?? '';
      final panCard = prefs.getString('kyc_pan_card') ?? '';
      final bikeRc = prefs.getString('kyc_bike_rc') ?? '';
      final paymentScreenshot = prefs.getString('kyc_payment_screenshot') ?? '';
      final paymentVerified = prefs.getBool('kyc_payment_verified') ?? false;
      final submittedAt = prefs.getString('kyc_submitted_at');
      final verifiedAt = prefs.getString('kyc_verified_at');
      final rejectionReason = prefs.getString('kyc_rejection_reason');
      final adminNotes = prefs.getString('kyc_admin_notes');

      _kyc = KycData(
        status: status,
        aadhaarNumber: aadhaar,
        aadhaarFrontUrl: aadhaarFront,
        aadhaarBackUrl: aadhaarBack,
        panNumber: pan,
        panCardUrl: panCard,
        bikeNumber: bike,
        bikeRcUrl: bikeRc,
        paymentScreenshotUrl: paymentScreenshot,
        paymentVerified: paymentVerified,
        submittedAt: submittedAt,
        verifiedAt: verifiedAt,
        rejectionReason: rejectionReason,
        adminNotes: adminNotes,
      );
    } catch (_) {}
    _isKycLoading = false;
    notifyListeners();
  }

  Future<bool> submitKyc({
    required String aadhaarNumber,
    required String panNumber,
    required String bikeNumber,
    String? aadhaarFrontUrl,
    String? aadhaarBackUrl,
    String? panCardUrl,
    String? bikeRcUrl,
    String? paymentScreenshotUrl,
    int? userId,
  }) async {
    final nowStr = DateTime.now().toIso8601String();
    _kyc = KycData(
      status: 'PENDING',
      aadhaarNumber: aadhaarNumber.trim(),
      aadhaarFrontUrl: aadhaarFrontUrl ?? '',
      aadhaarBackUrl: aadhaarBackUrl ?? '',
      panNumber: panNumber.trim().toUpperCase(),
      panCardUrl: panCardUrl ?? '',
      bikeNumber: bikeNumber.trim().toUpperCase(),
      bikeRcUrl: bikeRcUrl ?? '',
      paymentScreenshotUrl: paymentScreenshotUrl,
      paymentVerified: false,
      submittedAt: nowStr,
      verifiedAt: null,
      rejectionReason: null,
      adminNotes: null,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('kyc_status', _kyc.status);
      await prefs.setString('kyc_aadhaar', _kyc.aadhaarNumber);
      await prefs.setString('kyc_pan', _kyc.panNumber);
      await prefs.setString('kyc_bike', _kyc.bikeNumber);
      await prefs.setString('kyc_aadhaar_front', _kyc.aadhaarFrontUrl);
      await prefs.setString('kyc_aadhaar_back', _kyc.aadhaarBackUrl);
      await prefs.setString('kyc_pan_card', _kyc.panCardUrl);
      await prefs.setString('kyc_bike_rc', _kyc.bikeRcUrl);
      if (paymentScreenshotUrl != null) {
        await prefs.setString('kyc_payment_screenshot', paymentScreenshotUrl);
      }
      await prefs.setBool('kyc_payment_verified', false);
      await prefs.setString('kyc_submitted_at', nowStr);
      await prefs.remove('kyc_verified_at');
      await prefs.remove('kyc_rejection_reason');
      await prefs.remove('kyc_admin_notes');

      // Submit to backend API — wait for server response
      final effectiveUserId = userId ?? prefs.getInt('user_id') ?? 2;
      final res = await ApiService.submitKycRemote(
        userId: effectiveUserId,
        aadhaarNumber: _kyc.aadhaarNumber,
        panNumber: _kyc.panNumber,
        bikeNumber: _kyc.bikeNumber,
        aadhaarFrontUrl: _kyc.aadhaarFrontUrl,
        aadhaarBackUrl: _kyc.aadhaarBackUrl,
        panCardUrl: _kyc.panCardUrl,
        bikeRcUrl: _kyc.bikeRcUrl,
        paymentScreenshotUrl: paymentScreenshotUrl,
      );

      if (res['success'] == true) {
        _kyc = _kyc.copyWith(status: 'PENDING');
        await prefs.setString('kyc_status', 'PENDING');
      } else {
        print('submitKycRemote error: ${res['error']}');
      }
    } catch (e) {
      print('submitKyc exception: $e');
    }

    notifyListeners();
    return true;
  }

  /// Polls / checks current KYC verification status from backend API.
  /// Status only changes when Instafix Admin approves or rejects from admin panel.
  Future<void> fetchKycStatusFromApi(int userId) async {
    try {
      final res = await ApiService.fetchKycStatusRemote(userId);
      if (res != null && res['kyc_status'] != null) {
        final status = res['kyc_status'] as String;
        final paymentVerified = res['payment_verified'] == true || res['payment_verified'] == 1;
        final rejection = res['rejection_reason'] as String?;
        final verifiedAt = res['verified_at'] as String?;

        _kyc = _kyc.copyWith(
          status: status,
          paymentVerified: paymentVerified,
          rejectionReason: rejection,
          verifiedAt: verifiedAt,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('kyc_status', status);
        await prefs.setBool('kyc_payment_verified', paymentVerified);
        if (rejection != null) {
          await prefs.setString('kyc_rejection_reason', rejection);
        } else {
          await prefs.remove('kyc_rejection_reason');
        }
        if (verifiedAt != null) {
          await prefs.setString('kyc_verified_at', verifiedAt);
        }
        notifyListeners();
      }
    } catch (e) {
      print('fetchKycStatusFromApi error: $e');
    }
  }

  Future<void> resetKyc() async {
    _kyc = KycData.initial();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('kyc_status');
      await prefs.remove('kyc_aadhaar');
      await prefs.remove('kyc_pan');
      await prefs.remove('kyc_bike');
      await prefs.remove('kyc_aadhaar_front');
      await prefs.remove('kyc_aadhaar_back');
      await prefs.remove('kyc_pan_card');
      await prefs.remove('kyc_bike_rc');
      await prefs.remove('kyc_submitted_at');
      await prefs.remove('kyc_verified_at');
      await prefs.remove('kyc_rejection_reason');
      await prefs.remove('kyc_admin_notes');
    } catch (_) {}
    notifyListeners();
  }

  // ── Real earnings computed from actual booking data ──────────────────────
  // No hardcoded values — all derived from BookingProvider's real bookings list.

  /// Returns today's earnings from completed bookings (payment status does not matter).
  double todaysEarningsFrom(List<Booking> bookings) {
    final today = DateTime.now();
    return bookings
        .where((b) =>
            b.status == 'COMPLETED' &&
            _isToday(b.updatedAt ?? b.createdAt, today))
        .fold<double>(0.0, (sum, b) => sum + b.finalAmount);
  }

  /// Returns this week's earnings
  double weeklyEarningsFrom(List<Booking> bookings) {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    return bookings
        .where((b) =>
            b.status == 'COMPLETED' &&
            _isThisWeek(b.updatedAt ?? b.createdAt, startOfWeek, today))
        .fold<double>(0.0, (sum, b) => sum + b.finalAmount);
  }

  /// Returns this month's earnings
  double monthlyEarningsFrom(List<Booking> bookings) {
    final today = DateTime.now();
    return bookings
        .where((b) =>
            b.status == 'COMPLETED' &&
            _isThisMonth(b.updatedAt ?? b.createdAt, today))
        .fold<double>(0.0, (sum, b) => sum + b.finalAmount);
  }

  /// Returns count of bookings completed today.
  int completedTodayCountFrom(List<Booking> bookings) {
    final today = DateTime.now();
    return bookings
        .where((b) =>
            b.status == 'COMPLETED' && _isToday(b.updatedAt ?? b.createdAt, today))
        .length;
  }

  bool _isToday(String createdAt, DateTime today) {
    try {
      final dt = DateTime.parse(createdAt);
      return dt.year == today.year &&
          dt.month == today.month &&
          dt.day == today.day;
    } catch (_) {
      return createdAt == 'Just now' || createdAt.toLowerCase().contains('today');
    }
  }

  bool _isThisWeek(String createdAt, DateTime startOfWeek, DateTime today) {
    try {
      final dt = DateTime.parse(createdAt);
      return dt.isAfter(startOfWeek.subtract(const Duration(days: 1))) && dt.isBefore(today.add(const Duration(days: 1)));
    } catch (_) {
      return createdAt == 'Just now' || createdAt.toLowerCase().contains('today');
    }
  }

  bool _isThisMonth(String createdAt, DateTime today) {
    try {
      final dt = DateTime.parse(createdAt);
      return dt.year == today.year && dt.month == today.month;
    } catch (_) {
      return createdAt == 'Just now' || createdAt.toLowerCase().contains('today');
    }
  }

  bool acceptJob(
    BookingProvider bookingProvider,
    Booking booking, {
    String? technicianName,
    String? technicianPhone,
    int? technicianId,
  }) {
    if (!isKycVerified) {
      return false;
    }
    Booking updated = booking.copyWith(
      status: 'TECHNICIAN_ASSIGNED',
      technicianId: technicianId ?? 2,
      technicianName: (technicianName != null && technicianName.trim().isNotEmpty)
          ? technicianName.trim()
          : (booking.technicianName ?? 'Technician'),
      technicianPhone: technicianPhone ?? booking.technicianPhone ?? '+91 91234 56789',
    );
    bookingProvider.updateBooking(updated);
    notifyListeners();
    return true;
  }

  void markOnTheWay(BookingProvider bookingProvider, Booking booking) {
    Booking updated = booking.copyWith(status: 'TECHNICIAN_ON_WAY');
    bookingProvider.updateBooking(updated);
    notifyListeners();
  }

  void markArrived(BookingProvider bookingProvider, Booking booking) {
    Booking updated = booking.copyWith(status: 'ARRIVED');
    bookingProvider.updateBooking(updated);
    notifyListeners();
  }

  void submitPreDiagnosis({
    required BookingProvider bookingProvider,
    required Booking booking,
    required Map<String, bool> checks,
    required String notes,
    required List<String> photos,
    String? extraTitle,
    String? extraDesc,
    double? extraCost,
  }) {
    bool hasExtraWork = extraCost != null && extraCost > 0;
    String newStatus = hasExtraWork ? 'WAITING_FOR_APPROVAL' : 'REPAIRING';

    DiagnosticData diag = DiagnosticData(
      bookingId: booking.id,
      preRepairChecks: checks,
      preNotes: notes,
      prePhotos: photos.isEmpty
          ? ['https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=400']
          : photos,
      additionalTitle: extraTitle,
      additionalDescription: extraDesc,
      additionalAmount: extraCost,
      approvalStatus: hasExtraWork ? 'PENDING' : 'NONE',
      postRepairChecks: checks,
    );

    Booking updated = booking.copyWith(
      status: newStatus,
      additionalAmount: extraCost,
      diagnostic: diag,
    );

    bookingProvider.updateBooking(updated);
    notifyListeners();
  }

  void submitPostQC({
    required BookingProvider bookingProvider,
    required Booking booking,
    required Map<String, bool> postChecks,
    required String postNotes,
    required List<String> postPhotos,
  }) {
    DiagnosticData currentDiag = booking.diagnostic ??
        DiagnosticData(
          bookingId: booking.id,
          preRepairChecks: postChecks,
          postRepairChecks: postChecks,
        );

    DiagnosticData updatedDiag = DiagnosticData(
      id: currentDiag.id,
      bookingId: currentDiag.bookingId,
      preRepairChecks: currentDiag.preRepairChecks,
      preNotes: currentDiag.preNotes,
      prePhotos: currentDiag.prePhotos,
      additionalTitle: currentDiag.additionalTitle,
      additionalDescription: currentDiag.additionalDescription,
      additionalAmount: currentDiag.additionalAmount,
      approvalStatus: currentDiag.approvalStatus,
      postRepairChecks: postChecks,
      postNotes: postNotes,
      postPhotos: postPhotos.isEmpty
          ? ['https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=400']
          : postPhotos,
    );

    Booking updated = booking.copyWith(
      status: 'COMPLETED',
      paymentStatus: 'PAID',
      diagnostic: updatedDiag,
    );

    bookingProvider.updateBooking(updated);
    notifyListeners();
  }
}
