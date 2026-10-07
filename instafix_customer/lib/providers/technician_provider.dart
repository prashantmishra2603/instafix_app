import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/diagnostic.dart';
import 'booking_provider.dart';

class TechnicianProvider extends ChangeNotifier {
  double todaysEarnings = 6498.0;
  int completedTodayCount = 2;

  void acceptJob(
    BookingProvider bookingProvider,
    Booking booking, {
    String? technicianName,
    String? technicianPhone,
    int? technicianId,
  }) {
    Booking updated = booking.copyWith(
      status: 'TECHNICIAN_ASSIGNED',
      technicianId: technicianId ?? 2,
      technicianName: (technicianName != null && technicianName.trim().isNotEmpty)
          ? '${technicianName.trim()} (You)'
          : (booking.technicianName ?? 'Technician (You)'),
      technicianPhone: technicianPhone ?? booking.technicianPhone ?? '+91 91234 56789',
    );
    bookingProvider.updateBooking(updated);
    notifyListeners();
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

    todaysEarnings += updated.finalAmount;
    completedTodayCount += 1;

    bookingProvider.updateBooking(updated);
    notifyListeners();
  }
}
