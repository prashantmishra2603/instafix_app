import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/technician_provider.dart';
import '../../models/booking.dart';
import 'pre_inspection_screen.dart';
import 'post_qc_screen.dart';

class TechnicianJobDetailScreen extends StatelessWidget {
  final Booking booking;
  const TechnicianJobDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final bp  = context.watch<BookingProvider>();
    final tech = context.watch<TechnicianProvider>();
    final b   = bp.bookings.firstWhere((x) => x.id == booking.id, orElse: () => booking);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(b.bookingNumber),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _statusColor(b.status).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _statusColor(b.status).withValues(alpha: 0.3)),
            ),
            child: Text(b.statusDisplay,
                style: TextStyle(
                    color: _statusColor(b.status),
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Amount Banner ───────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 20, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('JOB AMOUNT',
                                  style: TextStyle(color: Colors.white60, fontSize: 10,
                                      fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                              const SizedBox(height: 6),
                              Text('₹${b.finalAmount.toInt()}',
                                  style: const TextStyle(color: Colors.white,
                                      fontSize: 30, fontWeight: FontWeight.w800)),
                              if ((b.additionalAmount ?? 0) > 0)
                                Text('+₹${b.additionalAmount!.toInt()} extra work',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _pill(b.paymentStatus == 'PAID' ? 'PAID' : 'PENDING',
                                b.paymentStatus == 'PAID' ? AppTheme.success : AppTheme.warning),
                            const SizedBox(height: 8),
                            Text(b.createdAt,
                                style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Customer ────────────────────────────────────────────
                  _sectionLabel('Customer'),
                  const SizedBox(height: 10),
                  _card(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                          child: Text(b.customerName.isNotEmpty ? b.customerName[0].toUpperCase() : 'C',
                              style: const TextStyle(color: AppTheme.primary,
                                  fontSize: 18, fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(b.customerName,
                                  style: const TextStyle(color: AppTheme.textPrimary,
                                      fontSize: 16, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 3),
                              Text(b.customerPhone,
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                            ],
                          ),
                        ),
                        _iconBtn(Icons.call_rounded, AppTheme.success, () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Calling ${b.customerPhone}...')));
                        }),
                        const SizedBox(width: 8),
                        _iconBtn(Icons.near_me_rounded, AppTheme.info, () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening Maps...')));
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  _card(
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(b.addressLine,
                              style: const TextStyle(color: AppTheme.textSecondary,
                                  fontSize: 13, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Device & Repair ─────────────────────────────────────
                  _sectionLabel('Repair Details'),
                  const SizedBox(height: 10),
                  _card(
                    child: Column(
                      children: [
                        _detailRow(Icons.phone_android_rounded, 'Device',
                            '${b.brandName} ${b.modelName}'),
                        _divider(),
                        _detailRow(Icons.build_rounded, 'Service', b.serviceName),
                        _divider(),
                        _detailRow(Icons.inventory_2_rounded, 'Part', b.partOptionName),
                        _divider(),
                        _detailRow(Icons.schedule_rounded, 'Slot', b.scheduledSlot),
                        _divider(),
                        _detailRow(Icons.currency_rupee_rounded, 'Estimate',
                            '₹${b.estimateAmount.toInt()}'),
                      ],
                    ),
                  ),

                  // ── Diagnostic ──────────────────────────────────────────
                  if (b.diagnostic != null) ...[
                    const SizedBox(height: 24),
                    _sectionLabel('Inspection Record'),
                    const SizedBox(height: 10),
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.diagnostic!.preNotes ?? 'Pre-check completed.',
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                          if (b.diagnostic!.additionalTitle != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.warning.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.warning.withValues(alpha: 0.25)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded,
                                      color: AppTheme.warning, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${b.diagnostic!.additionalTitle} · +₹${b.diagnostic!.additionalAmount?.toInt()}',
                                      style: const TextStyle(color: AppTheme.warning,
                                          fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── Action Bar ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: AppTheme.darkNav,
              border: Border(top: BorderSide(color: AppTheme.darkBorder)),
            ),
            child: SafeArea(
              top: false,
              child: _actionButton(context, bp, tech, b),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext ctx, BookingProvider bp, TechnicianProvider tech, Booking b) {
    switch (b.status) {
      case 'PENDING':
      case 'CONFIRMED':
        return _btn('Accept Job Assignment', AppTheme.primaryGradient, () {
          final user = ctx.read<AuthProvider>().currentUser;
          tech.acceptJob(bp, b, technicianName: user?.name, technicianPhone: user?.phone, technicianId: user?.id);
          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('✅ Job accepted!')));
        });
      case 'TECHNICIAN_ASSIGNED':
        return _btn('Mark "On The Way"', AppTheme.primaryGradient, () {
          tech.markOnTheWay(bp, b);
          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('🚗 Status updated')));
        });
      case 'TECHNICIAN_ON_WAY':
        return _btn('Mark "Arrived at Doorstep"', AppTheme.primaryGradient, () {
          tech.markArrived(bp, b);
          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('📍 Arrived!')));
        });
      case 'ARRIVED':
        return _btn('Start Pre-Repair Inspection', AppTheme.primaryGradient, () {
          Navigator.push(ctx, MaterialPageRoute(builder: (_) => PreInspectionScreen(booking: b)));
        });
      case 'WAITING_FOR_APPROVAL':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_top_rounded, color: AppTheme.warning, size: 18),
              const SizedBox(width: 8),
              const Text('Waiting for Customer Approval...',
                  style: TextStyle(color: AppTheme.warning, fontWeight: FontWeight.w700)),
            ],
          ),
        );
      case 'REPAIRING':
        return _btn('Repair Done → Post-QC Check',
            const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF16A34A)]), () {
          Navigator.push(ctx, MaterialPageRoute(builder: (_) => PostQcScreen(booking: b)));
        });
      default:
        return _btn('Back to Console',
            const LinearGradient(colors: [AppTheme.darkElevated, AppTheme.darkElevated]), () {
          Navigator.pop(ctx);
        });
    }
  }

  Widget _btn(String label, LinearGradient gradient, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: AppTheme.primary.withValues(alpha: 0.25),
                  blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
      );

  Widget _sectionLabel(String t) => Text(t,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w700));

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: child,
      );

  Widget _detailRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 15, color: AppTheme.textMuted),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
            const Spacer(),
            Flexible(
              child: Text(value,
                  style: const TextStyle(color: AppTheme.textPrimary,
                      fontSize: 13, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.end),
            ),
          ],
        ),
      );

  Widget _divider() => Divider(height: 1, color: AppTheme.darkBorder.withValues(alpha: 0.6));

  Widget _pill(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
      );

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      );

  Color _statusColor(String status) {
    if (status == 'COMPLETED') return AppTheme.success;
    if (status == 'WAITING_FOR_APPROVAL') return AppTheme.warning;
    if (status == 'PENDING' || status == 'CONFIRMED') return AppTheme.info;
    return AppTheme.primary;
  }
}
