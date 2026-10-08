import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking.dart';
import 'booking_tracking_screen.dart';
import 'invoice_warranty_screen.dart';
import 'customer_approval_screen.dart';

import '../../providers/auth_provider.dart';

class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});
  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      final p = Provider.of<BookingProvider>(context, listen: false);
      p.fetchBookings(user: user);
      p.startPolling(user: user);
    });
  }

  @override
  void dispose() {
    Provider.of<BookingProvider>(context, listen: false).stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final bookings = Provider.of<BookingProvider>(context).getBookingsForUser(user);
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: bookings.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.build_circle_outlined, size: 72, color: AppTheme.border),
              SizedBox(height: 16),
              Text('No repair bookings yet.',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (_, i) => _BookingCard(booking: bookings[i]),
            ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  const _BookingCard({required this.booking});

  IconData get _icon {
    switch (booking.deviceCategory) {
      case 'tablet':     return Icons.tablet_mac_rounded;
      case 'laptop':     return Icons.laptop_mac_rounded;
      case 'smartwatch': return Icons.watch_rounded;
      default:           return Icons.phone_iphone_rounded;
    }
  }

  Color get _statusColor {
    switch (booking.status) {
      case 'COMPLETED':            return AppTheme.success;
      case 'WAITING_FOR_APPROVAL': return AppTheme.warning;
      case 'CANCELLED':
      case 'REJECTED':             return AppTheme.error;
      default:                     return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _statusColor.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            border: Border(bottom: BorderSide(color: AppTheme.border)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(booking.bookingNumber,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(booking.statusDisplay,
                  style: TextStyle(color: _statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)),
                child: Icon(_icon, color: AppTheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${booking.brandName} ${booking.modelName}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark)),
                Text(booking.serviceName,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('₹${booking.finalAmount.toInt()}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.textDark)),
                Text(booking.paymentStatus,
                    style: TextStyle(fontSize: 11,
                        color: booking.paymentStatus == 'PAID' ? AppTheme.success : AppTheme.warning,
                        fontWeight: FontWeight.w600)),
              ]),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.calendar_today_rounded, size: 13, color: AppTheme.textMuted),
              const SizedBox(width: 5),
              Text(booking.scheduledSlot, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            ]),
            if (booking.technicianName != null && booking.technicianName!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.engineering_rounded, size: 13, color: AppTheme.primary),
                const SizedBox(width: 5),
                Text('Assigned to ${booking.technicianName}', style: const TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w600)),
              ]),
            ],
            const SizedBox(height: 14),
            _ActionButton(booking: booking),
          ]),
        ),
      ]),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Booking booking;
  const _ActionButton({required this.booking});

  @override
  Widget build(BuildContext context) {
    if (booking.status == 'WAITING_FOR_APPROVAL') {
      return SizedBox(width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warning),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => CustomerApprovalScreen(booking: booking))),
          icon: const Icon(Icons.warning_amber_rounded, size: 18),
          label: const Text('Review & Approve'),
        ),
      );
    }
    if (booking.status == 'COMPLETED') {
      return SizedBox(width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.success)),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const InvoiceWarrantyScreen())),
          icon: const Icon(Icons.receipt_long_rounded, size: 18, color: AppTheme.success),
          label: const Text('Invoice & Warranty', style: TextStyle(color: AppTheme.success)),
        ),
      );
    }
    if (booking.status == 'CANCELLED' || booking.status == 'REJECTED') {
      return const SizedBox.shrink();
    }
    return SizedBox(width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const BookingTrackingScreen())),
        icon: const Icon(Icons.radar_rounded, size: 18),
        label: const Text('Track Live'),
      ),
    );
  }
}
