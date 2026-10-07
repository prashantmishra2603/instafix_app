import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/booking_provider.dart';
import 'customer_approval_screen.dart';
import 'invoice_warranty_screen.dart';

import '../../providers/auth_provider.dart';

class BookingTrackingScreen extends StatefulWidget {
  /// When set, shows a booking-confirmed snackbar on first load from this
  /// screen's own Scaffold (safe — avoids deactivated-ancestor crash).
  final String? confirmedBookingNumber;
  const BookingTrackingScreen({super.key, this.confirmedBookingNumber});
  @override
  State<BookingTrackingScreen> createState() => _BookingTrackingScreenState();
}

class _BookingTrackingScreenState extends State<BookingTrackingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
        Provider.of<BookingProvider>(context, listen: false).fetchBookings(user: user);
      }
    });
    // Show confirmation snackbar safely from THIS screen's own active Scaffold.
    if (widget.confirmedBookingNumber != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Booking ${widget.confirmedBookingNumber} confirmed! ✅',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
      });
    }
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final bp = Provider.of<BookingProvider>(context);
    final userBookings = bp.getBookingsForUser(user);
    final booking = bp.getActiveBookingForUser(user) ?? (userBookings.isNotEmpty ? userBookings.first : null);

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Track Booking')),
        body: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.border),
          SizedBox(height: 16),
          Text('No active bookings found.', style: TextStyle(color: AppTheme.textMuted)),
        ])),
      );
    }

    final isApproval  = booking.status == 'WAITING_FOR_APPROVAL';
    final isCompleted = booking.status == 'COMPLETED';

    return Scaffold(
      appBar: AppBar(
        title: Text('Booking #${booking.bookingNumber}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(children: [
              Container(width: 8, height: 8,
                  decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              const Text('Live', style: TextStyle(fontSize: 12, color: AppTheme.success, fontWeight: FontWeight.bold)),
            ]),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isApproval ? AppTheme.warning.withValues(alpha: 0.1)
                    : isCompleted ? AppTheme.success.withValues(alpha: 0.1)
                    : AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isApproval ? AppTheme.warning
                      : isCompleted ? AppTheme.success
                      : AppTheme.primary,
                ),
              ),
              child: Row(children: [
                Icon(
                  isApproval ? Icons.warning_amber_rounded
                      : isCompleted ? Icons.verified_rounded
                      : Icons.radar_rounded,
                  color: isApproval ? AppTheme.warning
                      : isCompleted ? AppTheme.success
                      : AppTheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('CURRENT STATUS',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                          letterSpacing: 1.1, color: AppTheme.textMuted)),
                  const SizedBox(height: 2),
                  Text(booking.statusDisplay,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                          color: isApproval ? AppTheme.warning : AppTheme.textDark)),
                ])),
              ]),
            ),

            // Approval Prompt
            if (isApproval) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.warning.withValues(alpha: 0.4)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [
                    Icon(Icons.notification_important_rounded, color: AppTheme.warning, size: 20),
                    SizedBox(width: 8),
                    Text('Extra Repair Work Requested',
                        style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 15)),
                  ]),
                  const SizedBox(height: 6),
                  const Text('Technician found an additional issue. Please review & approve to continue.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                  const SizedBox(height: 14),
                  SizedBox(width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => CustomerApprovalScreen(booking: booking))),
                      child: const Text('Review Inspection & Approve'),
                    ),
                  ),
                ]),
              ),
            ],

            // Completed Prompt
            if (isCompleted) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.success),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Repair Successfully Completed! 🎉',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.success)),
                  const SizedBox(height: 4),
                  const Text('Your digital invoice and warranty card have been generated.',
                      style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.success)),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const InvoiceWarrantyScreen())),
                    icon: const Icon(Icons.receipt_long_rounded, color: AppTheme.success),
                    label: const Text('View Invoice & Warranty', style: TextStyle(color: AppTheme.success)),
                  ),
                ]),
              ),
            ],

            const SizedBox(height: 24),

            // Booking Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(children: [
                _infoRow(Icons.devices_rounded, 'Device', '${booking.brandName} ${booking.modelName}'),
                Divider(height: 20, color: AppTheme.border),
                _infoRow(Icons.build_rounded, 'Service', booking.serviceName),
                Divider(height: 20, color: AppTheme.border),
                _infoRow(Icons.location_on_rounded, 'Address', booking.addressLine),
                Divider(height: 20, color: AppTheme.border),
                _infoRow(Icons.schedule_rounded, 'Slot', booking.scheduledSlot),
                Divider(height: 20, color: AppTheme.border),
                _infoRow(Icons.currency_rupee_rounded, 'Amount',
                    '₹${booking.finalAmount.toInt()} (${booking.paymentStatus})'),
              ]),
            ),

            const SizedBox(height: 24),

            // Technician Card
            const Text('Assigned Technician',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppTheme.primaryLight,
                  child: const Icon(Icons.person_rounded, color: AppTheme.primary, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(booking.technicianName ?? 'Awaiting Assignment',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark)),
                  const SizedBox(height: 2),
                  booking.technicianName != null
                      ? const Row(children: [
                          Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text('Certified Instafix Technician',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                        ])
                      : const Text('Will be assigned shortly',
                          style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                ])),
                if (booking.technicianPhone != null)
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(backgroundColor: AppTheme.primaryLight),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Calling ${booking.technicianPhone}...'))),
                    icon: const Icon(Icons.call_rounded, color: AppTheme.primary),
                  ),
              ]),
            ),

            const SizedBox(height: 28),

            // Timeline
            const Text('Repair Progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            const SizedBox(height: 16),

            _step('Booking Confirmed', 'Order received & scheduled', booking.statusStepIndex >= 0),
            _step('Technician En Route', 'Expert traveling to doorstep', booking.statusStepIndex >= 1),
            _step('Arrived & Pre-Diagnosis', '10-point hardware checklist', booking.statusStepIndex >= 2),
            _step('Repair in Progress', 'Replacing parts with precision tools', booking.statusStepIndex >= 3),
            _step('Quality Check (QC)', 'Post-repair verification', booking.statusStepIndex >= 4),
            _step('Completed & Handover', 'Invoice & warranty issued', booking.statusStepIndex >= 5, last: true),
          ]),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 18, color: AppTheme.primary),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
      ])),
    ],
  );

  Widget _step(String title, String subtitle, bool done, {bool last = false}) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(children: [
        Container(
          width: 22, height: 22,
          decoration: BoxDecoration(
            color: done ? AppTheme.primary : AppTheme.border,
            shape: BoxShape.circle,
          ),
          child: Icon(done ? Icons.check : Icons.circle, size: 14, color: Colors.white),
        ),
        if (!last) Container(width: 2, height: 36, color: done ? AppTheme.primary : AppTheme.border),
      ]),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(
            fontWeight: done ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
            color: done ? AppTheme.textDark : AppTheme.textMuted)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        const SizedBox(height: 18),
      ])),
    ],
  );
}
