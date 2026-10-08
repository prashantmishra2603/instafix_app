import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/technician_provider.dart';
import '../../models/booking.dart';
import 'technician_job_detail_screen.dart';

class TechnicianDashboardScreen extends StatefulWidget {
  const TechnicianDashboardScreen({super.key});

  @override
  State<TechnicianDashboardScreen> createState() =>
      _TechnicianDashboardScreenState();
}

class _TechnicianDashboardScreenState
    extends State<TechnicianDashboardScreen>
    with SingleTickerProviderStateMixin {
  String _filter = 'All';
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bp = context.read<BookingProvider>();
      bp.fetchBookings();
      bp.startPolling();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  List<Booking> _filtered(List<Booking> all) {
    switch (_filter) {
      case 'Pending':
        return all
            .where((b) =>
                b.status == 'PENDING' || b.status == 'CONFIRMED')
            .toList();
      case 'Active':
        return all
            .where((b) => [
                  'TECHNICIAN_ASSIGNED',
                  'TECHNICIAN_ON_WAY',
                  'ARRIVED',
                  'DIAGNOSIS',
                  'WAITING_FOR_APPROVAL',
                  'REPAIRING',
                  'QC'
                ].contains(b.status))
            .toList();
      case 'Completed':
        return all.where((b) => b.status == 'COMPLETED').toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bp = context.watch<BookingProvider>();
    final tech = context.watch<TechnicianProvider>();
    final jobs = _filtered(bp.bookings);
    final name =
        auth.currentUser?.name.split(' ').first ?? 'Partner';

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: RefreshIndicator(
        color: AppTheme.primary,
        backgroundColor: AppTheme.darkCard,
        onRefresh: bp.fetchBookings,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Sliver AppBar ────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: AppTheme.darkBg,
              floating: true,
              snap: true,
              elevation: 0,
              automaticallyImplyLeading: false,
              titleSpacing: 20,
              title: Row(
                children: [
                  // Animated wrench icon
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, child) => Transform.scale(
                      scale: _pulseAnim.value,
                      child: child,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary
                                .withValues(alpha: 0.35),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.build_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_greeting()}, $name 👋',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(
                          'Repair Console',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Sync button
                  GestureDetector(
                    onTap: () => bp.fetchBookings(),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppTheme.darkCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.darkBorder),
                      ),
                      child: const Icon(Icons.sync_rounded,
                          color: AppTheme.primary, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Earnings Hero Card
                    _earningsHeroCard(tech, bp),
                    const SizedBox(height: 16),

                    // Quick Stats Row
                    _statsRow(bp),
                    const SizedBox(height: 20),

                    // Section header with tools icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                              Icons.home_repair_service_rounded,
                              color: AppTheme.primary,
                              size: 16),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Repair Jobs',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        if (bp.isFetching)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primary,
                            ),
                          ),
                        if (!bp.isFetching)
                          Text(
                            '${jobs.length} jobs',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Filter chips
                    _filterRow(),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // Jobs List
            if (bp.isFetching && jobs.isEmpty)
              SliverFillRemaining(child: _loadingState())
            else if (jobs.isEmpty)
              SliverFillRemaining(child: _emptyState(bp))
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _JobCard(booking: jobs[i]),
                    childCount: jobs.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _earningsHeroCard(TechnicianProvider tech, BookingProvider bp) {
    final allBookings = bp.bookings;
    final todayEarnings = tech.todaysEarningsFrom(allBookings);
    final todayCompleted = tech.completedTodayCountFrom(allBookings);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D1FB3), Color(0xFF6C5CE7), Color(0xFF4834DF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background tools pattern
          Positioned(
            right: -10,
            top: -10,
            child: Icon(Icons.settings_rounded,
                size: 90,
                color: Colors.white.withValues(alpha: 0.05)),
          ),
          Positioned(
            right: 40,
            bottom: -5,
            child: Icon(Icons.build_rounded,
                size: 60,
                color: Colors.white.withValues(alpha: 0.04)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.currency_rupee_rounded,
                          color: Colors.white70, size: 14),
                      SizedBox(width: 4),
                      Text(
                        "TODAY'S EARNINGS",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$todayCompleted Fixed Today',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '₹${todayEarnings.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.15)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _earningsStat(
                    'This Week',
                    '₹${tech.weeklyEarningsFrom(allBookings).toStringAsFixed(0)}',
                    Icons.date_range_rounded,
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: Colors.white.withValues(alpha: 0.2),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  _earningsStat(
                    'This Month',
                    '₹${tech.monthlyEarningsFrom(allBookings).toStringAsFixed(0)}',
                    Icons.calendar_month_rounded,
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: Colors.white.withValues(alpha: 0.2),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  _earningsStat(
                    'Total Done',
                    '${allBookings.where((b) => b.status == 'COMPLETED').length}',
                    Icons.check_circle_rounded,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _earningsStat(String label, String value, IconData icon) =>
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 11, color: Colors.white60),
                const SizedBox(width: 3),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 3),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      );

  Widget _statsRow(BookingProvider bp) {
    final active = bp.bookings
        .where((b) => [
              'TECHNICIAN_ASSIGNED',
              'TECHNICIAN_ON_WAY',
              'ARRIVED',
              'DIAGNOSIS',
              'WAITING_FOR_APPROVAL',
              'REPAIRING',
              'QC'
            ].contains(b.status))
        .length;
    final pending = bp.bookings
        .where((b) =>
            b.status == 'PENDING' || b.status == 'CONFIRMED')
        .length;
    final completed =
        bp.bookings.where((b) => b.status == 'COMPLETED').length;

    return Row(
      children: [
        _statChip(Icons.pending_actions_rounded, '$pending',
            'New Jobs', AppTheme.warning),
        const SizedBox(width: 8),
        _statChip(Icons.construction_rounded, '$active',
            'In Progress', AppTheme.info),
        const SizedBox(width: 8),
        _statChip(Icons.task_alt_rounded, '$completed',
            'Completed', AppTheme.success),
      ],
    );
  }

  Widget _statChip(
          IconData icon, String count, String label, Color color) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(count,
                  style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              Text(label,
                  style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );

  Widget _filterRow() {
    final filters = [
      ('All', Icons.grid_view_rounded),
      ('Pending', Icons.hourglass_empty_rounded),
      ('Active', Icons.construction_rounded),
      ('Completed', Icons.task_alt_rounded),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final sel = _filter == f.$1;
          return GestureDetector(
            onTap: () => setState(() => _filter = f.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: sel ? AppTheme.primaryGradient : null,
                color: sel ? null : AppTheme.darkCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: sel
                        ? AppTheme.primary
                        : AppTheme.darkBorder),
                boxShadow: sel
                    ? [
                        BoxShadow(
                          color: AppTheme.primary
                              .withValues(alpha: 0.25),
                          blurRadius: 8,
                        )
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(f.$2,
                      size: 14,
                      color: sel
                          ? Colors.white
                          : AppTheme.textSecondary),
                  const SizedBox(width: 5),
                  Text(
                    f.$1,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: sel
                          ? Colors.white
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _loadingState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                  color: AppTheme.primary, strokeWidth: 3),
            ),
            const SizedBox(height: 16),
            const Text('Fetching repair jobs...',
                style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 14)),
          ],
        ),
      );

  Widget _emptyState(BookingProvider bp) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: const Icon(Icons.home_repair_service_rounded,
                  size: 40, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Repair Jobs Yet',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                'Customer bookings will appear here in real-time once assigned.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppTheme.textMuted, fontSize: 13),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => bp.fetchBookings(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded,
                        color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('Refresh Jobs',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

// ── Job Card Widget ──────────────────────────────────────────────────────────
class _JobCard extends StatelessWidget {
  final Booking booking;
  const _JobCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final statusMeta = _statusMeta(booking.status);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                TechnicianJobDetailScreen(booking: booking)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.darkBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Status Header ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: statusMeta.color.withValues(alpha: 0.07),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18)),
                border: Border(
                    bottom: BorderSide(
                        color: statusMeta.color
                            .withValues(alpha: 0.15))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: statusMeta.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusMeta.icon,
                        color: statusMeta.color, size: 13),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusMeta.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: statusMeta.color
                              .withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      booking.statusDisplay.toUpperCase(),
                      style: TextStyle(
                        color: statusMeta.color,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    booking.bookingNumber,
                    style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            // ── Card Body ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Device icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.darkElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.darkBorder),
                        ),
                        child: Icon(
                          _deviceIcon(booking.deviceCategory),
                          color: AppTheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${booking.brandName} ${booking.modelName}',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(Icons.build_circle_rounded,
                                    size: 12,
                                    color: AppTheme.accent),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    booking.serviceName,
                                    style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12.5),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Amount
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${booking.finalAmount.toInt()}',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: booking.paymentStatus == 'PAID'
                                  ? AppTheme.success
                                      .withValues(alpha: 0.12)
                                  : AppTheme.warning
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              booking.paymentStatus == 'PAID'
                                  ? 'PAID'
                                  : 'PENDING',
                              style: TextStyle(
                                color: booking.paymentStatus == 'PAID'
                                    ? AppTheme.success
                                    : AppTheme.warning,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Divider(
                      height: 1,
                      color: AppTheme.darkBorder
                          .withValues(alpha: 0.6)),
                  const SizedBox(height: 10),

                  // Customer + location
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded,
                          size: 13, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        booking.customerName,
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      const Icon(Icons.schedule_rounded,
                          size: 13, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        booking.scheduledSlot,
                        style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          booking.addressLine,
                          style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // CTA Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      gradient: booking.status == 'COMPLETED'
                          ? null
                          : _ctaGradient(booking.status),
                      color: booking.status == 'COMPLETED'
                          ? AppTheme.darkElevated
                          : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _ctaIcon(booking.status),
                          size: 15,
                          color: booking.status == 'COMPLETED'
                              ? AppTheme.textSecondary
                              : Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _ctaLabel(booking.status),
                          style: TextStyle(
                            color: booking.status == 'COMPLETED'
                                ? AppTheme.textSecondary
                                : Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: booking.status == 'COMPLETED'
                              ? AppTheme.textSecondary
                              : Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _deviceIcon(String category) {
    final c = category.toLowerCase();
    if (c.contains('laptop') || c.contains('computer')) {
      return Icons.laptop_rounded;
    }
    if (c.contains('tablet') || c.contains('ipad')) {
      return Icons.tablet_rounded;
    }
    return Icons.smartphone_rounded;
  }

  LinearGradient _ctaGradient(String status) {
    if (status == 'REPAIRING') {
      return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)]);
    }
    if (status == 'WAITING_FOR_APPROVAL') {
      return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)]);
    }
    return AppTheme.primaryGradient;
  }

  IconData _ctaIcon(String status) {
    switch (status) {
      case 'PENDING':
      case 'CONFIRMED':
        return Icons.check_circle_outline_rounded;
      case 'TECHNICIAN_ASSIGNED':
        return Icons.directions_run_rounded;
      case 'TECHNICIAN_ON_WAY':
        return Icons.location_on_rounded;
      case 'ARRIVED':
        return Icons.search_rounded;
      case 'REPAIRING':
        return Icons.build_circle_rounded;
      case 'COMPLETED':
        return Icons.verified_rounded;
      default:
        return Icons.arrow_forward_rounded;
    }
  }

  String _ctaLabel(String status) {
    switch (status) {
      case 'PENDING':
      case 'CONFIRMED':
        return 'Accept Job';
      case 'TECHNICIAN_ASSIGNED':
        return 'Mark On The Way';
      case 'TECHNICIAN_ON_WAY':
        return 'Mark Arrived';
      case 'ARRIVED':
        return 'Start Inspection';
      case 'REPAIRING':
        return 'Repair Done → QC';
      case 'COMPLETED':
        return 'View Summary';
      default:
        return 'Manage Job';
    }
  }

  _StatusMeta _statusMeta(String status) {
    switch (status) {
      case 'COMPLETED':
        return _StatusMeta(AppTheme.success, Icons.task_alt_rounded);
      case 'WAITING_FOR_APPROVAL':
        return _StatusMeta(
            AppTheme.warning, Icons.hourglass_top_rounded);
      case 'PENDING':
      case 'CONFIRMED':
        return _StatusMeta(AppTheme.info, Icons.inbox_rounded);
      case 'REPAIRING':
        return _StatusMeta(
            AppTheme.accent, Icons.construction_rounded);
      case 'TECHNICIAN_ON_WAY':
      case 'TECHNICIAN_ASSIGNED':
        return _StatusMeta(
            AppTheme.primary, Icons.directions_run_rounded);
      default:
        return _StatusMeta(
            AppTheme.primary, Icons.home_repair_service_rounded);
    }
  }
}

class _StatusMeta {
  final Color color;
  final IconData icon;
  const _StatusMeta(this.color, this.icon);
}
