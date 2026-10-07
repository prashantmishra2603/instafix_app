import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking.dart';

class TechnicianInvoicesScreen extends StatefulWidget {
  const TechnicianInvoicesScreen({super.key});

  @override
  State<TechnicianInvoicesScreen> createState() =>
      _TechnicianInvoicesScreenState();
}

class _TechnicianInvoicesScreenState extends State<TechnicianInvoicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchBookings();
    });
  }

  // ── Earnings calculation from real DB bookings ─────────────────────────
  double _calcEarnings(List<Booking> completed, String period) {
    final now = DateTime.now();
    return completed.where((b) {
      // Parse createdAt – backend sends ISO string e.g. "2026-10-04T12:00:00.000Z"
      DateTime? dt;
      try {
        dt = DateTime.parse(b.createdAt);
      } catch (_) {}
      if (dt == null) return false;

      switch (period) {
        case 'today':
          return dt.year == now.year &&
              dt.month == now.month &&
              dt.day == now.day;
        case 'week':
          final startOfWeek =
              now.subtract(Duration(days: now.weekday - 1)); // Monday
          final start = DateTime(
              startOfWeek.year, startOfWeek.month, startOfWeek.day);
          return dt.isAfter(start.subtract(const Duration(seconds: 1)));
        case 'month':
          return dt.year == now.year && dt.month == now.month;
        default:
          return true;
      }
    }).fold<double>(0, (sum, b) => sum + b.finalAmount);
  }

  int _countPeriod(List<Booking> completed, String period) {
    final now = DateTime.now();
    return completed.where((b) {
      DateTime? dt;
      try {
        dt = DateTime.parse(b.createdAt);
      } catch (_) {}
      if (dt == null) return false;
      switch (period) {
        case 'today':
          return dt.year == now.year &&
              dt.month == now.month &&
              dt.day == now.day;
        case 'week':
          final startOfWeek =
              now.subtract(Duration(days: now.weekday - 1));
          final start = DateTime(
              startOfWeek.year, startOfWeek.month, startOfWeek.day);
          return dt.isAfter(start.subtract(const Duration(seconds: 1)));
        case 'month':
          return dt.year == now.year && dt.month == now.month;
        default:
          return true;
      }
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final bp = context.watch<BookingProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    final completed = bp.bookings
        .where((b) => b.status == 'COMPLETED')
        .toList();
    final active = bp.bookings
        .where((b) =>
            b.status != 'COMPLETED' &&
            b.status != 'CANCELLED' &&
            b.status != 'REJECTED')
        .toList();

    final totalRevenue =
        completed.fold<double>(0, (s, b) => s + b.finalAmount);
    final todayEarnings = _calcEarnings(completed, 'today');
    final weekEarnings = _calcEarnings(completed, 'week');
    final monthEarnings = _calcEarnings(completed, 'month');
    final todayCount = _countPeriod(completed, 'today');
    final weekCount = _countPeriod(completed, 'week');
    final monthCount = _countPeriod(completed, 'month');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.darkBg,
        appBar: AppBar(
          backgroundColor: AppTheme.darkNav,
          elevation: 0,
          title: const Text('Earnings & Invoices',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 19)),
          actions: [
            IconButton(
              onPressed: () => bp.fetchBookings(),
              icon: const Icon(Icons.sync_rounded,
                  color: AppTheme.primary, size: 22),
              tooltip: 'Refresh',
            ),
          ],
          bottom: TabBar(
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textMuted,
            indicatorColor: AppTheme.primary,
            indicatorWeight: 3,
            dividerColor: AppTheme.darkBorder,
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 13),
            tabs: const [
              Tab(text: 'Completed Jobs'),
              Tab(text: 'Earnings Report'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ── TAB 1: Completed Jobs from DB ────────────────────────────
            bp.isFetching
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primary))
                : completed.isEmpty
                    ? _emptyState()
                    : RefreshIndicator(
                        color: AppTheme.primary,
                        backgroundColor: AppTheme.darkCard,
                        onRefresh: bp.fetchBookings,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(18),
                          itemCount: completed.length,
                          itemBuilder: (context, idx) =>
                              _completedJobCard(completed[idx]),
                        ),
                      ),

            // ── TAB 2: Real Earnings Report ───────────────────────────────
            RefreshIndicator(
              color: AppTheme.primary,
              backgroundColor: AppTheme.darkCard,
              onRefresh: bp.fetchBookings,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Partner Info
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.darkBorder),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              AppTheme.primary.withValues(alpha: 0.15),
                          child: const Icon(Icons.person_rounded,
                              color: AppTheme.primary, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'Partner',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15),
                              ),
                              if (user?.shopName != null)
                                Text(
                                  user!.shopName!,
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('VERIFIED',
                                  style: TextStyle(
                                      color: AppTheme.success,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Total Revenue Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TOTAL LIFETIME REVENUE',
                            style: TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8)),
                        const SizedBox(height: 6),
                        Text(
                          '₹${totalRevenue.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${completed.length} completed jobs · ${active.length} active',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Period Breakdown
                  const Text('Period Breakdown',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                  const SizedBox(height: 12),

                  _periodCard(
                    icon: Icons.today_rounded,
                    label: 'Today',
                    amount: todayEarnings,
                    count: todayCount,
                    color: AppTheme.info,
                  ),
                  const SizedBox(height: 10),
                  _periodCard(
                    icon: Icons.date_range_rounded,
                    label: 'This Week',
                    amount: weekEarnings,
                    count: weekCount,
                    color: AppTheme.accent,
                  ),
                  const SizedBox(height: 10),
                  _periodCard(
                    icon: Icons.calendar_month_rounded,
                    label: 'This Month',
                    amount: monthEarnings,
                    count: monthCount,
                    color: AppTheme.primary,
                  ),

                  const SizedBox(height: 24),

                  // Payout Info
                  const Text('Settlement Policy',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                  const SizedBox(height: 12),
                  _infoTile(Icons.account_balance_rounded,
                      'Direct Bank Settlement',
                      'Weekly payout every Monday to registered bank account'),
                  _infoTile(Icons.receipt_long_rounded,
                      'GST Compliant Invoicing',
                      'Digital tax invoices auto-generated for every closed job'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _periodCard({
    required IconData icon,
    required String label,
    required double amount,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('$count job${count == 1 ? '' : 's'} completed',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
                color: color, fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _completedJobCard(Booking job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                job.bookingNumber,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppTheme.primary),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppTheme.success.withValues(alpha: 0.3)),
                ),
                child: const Text('COMPLETED',
                    style: TextStyle(
                        color: AppTheme.success,
                        fontWeight: FontWeight.w800,
                        fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: AppTheme.darkBorder),
          const SizedBox(height: 12),
          Text('${job.brandName} ${job.modelName}',
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text(job.serviceName,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded,
                  size: 13, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Text('Customer: ${job.customerName}',
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payout Amount',
                      style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    '₹${job.finalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: AppTheme.primary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: job.paymentStatus == 'PAID'
                      ? AppTheme.success.withValues(alpha: 0.15)
                      : AppTheme.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: job.paymentStatus == 'PAID'
                          ? AppTheme.success.withValues(alpha: 0.3)
                          : AppTheme.warning.withValues(alpha: 0.3)),
                ),
                child: Text(
                  job.paymentStatus == 'PAID' ? 'PAID' : 'PENDING',
                  style: TextStyle(
                    color: job.paymentStatus == 'PAID'
                        ? AppTheme.success
                        : AppTheme.warning,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: const Icon(Icons.receipt_long_outlined,
                  size: 40, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 14),
            const Text('No Completed Jobs Yet',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Completed repair jobs will appear here.',
                style:
                    TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          ],
        ),
      );

  Widget _infoTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
