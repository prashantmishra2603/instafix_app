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
  State<TechnicianDashboardScreen> createState() => _TechnicianDashboardScreenState();
}

class _TechnicianDashboardScreenState extends State<TechnicianDashboardScreen> {
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bp = context.read<BookingProvider>();
      bp.fetchBookings();
      bp.startPolling();
    });
  }

  List<Booking> _filtered(List<Booking> all) {
    switch (_filter) {
      case 'Pending':
        return all.where((b) => b.status == 'PENDING' || b.status == 'CONFIRMED').toList();
      case 'Active':
        return all.where((b) => [
          'TECHNICIAN_ASSIGNED', 'TECHNICIAN_ON_WAY', 'ARRIVED',
          'DIAGNOSIS', 'WAITING_FOR_APPROVAL', 'REPAIRING', 'QC'
        ].contains(b.status)).toList();
      case 'Completed':
        return all.where((b) => b.status == 'COMPLETED').toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bp   = context.watch<BookingProvider>();
    final tech = context.watch<TechnicianProvider>();
    final jobs = _filtered(bp.bookings);
    final name = auth.currentUser?.name.split(' ').first ?? 'Partner';

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: RefreshIndicator(
        color: AppTheme.primary,
        backgroundColor: AppTheme.darkCard,
        onRefresh: bp.fetchBookings,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: AppTheme.darkBg,
              floating: true,
              snap: true,
              elevation: 0,
              automaticallyImplyLeading: false,
              titleSpacing: 20,
              title: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good ${_greeting()}, $name 👋',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Technician Console',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => bp.fetchBookings(),
                    icon: const Icon(Icons.sync_rounded, color: AppTheme.primary, size: 22),
                    tooltip: 'Refresh Customer Bookings',
                  ),
                ],
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Earnings Card
                    _earningsHeroCard(tech, bp),
                    const SizedBox(height: 20),

                    // Stats Row
                    _statsRow(bp),
                    const SizedBox(height: 24),

                    // Filter Tabs
                    _filterRow(),
                    const SizedBox(height: 18),

                    // Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${jobs.length} Customer Booking${jobs.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (bp.isFetching)
                          const Row(
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primary,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Syncing...',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // Customer Bookings List
            if (bp.isFetching && jobs.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
              )
            else if (jobs.isEmpty)
              SliverFillRemaining(child: _emptyState(bp))
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
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
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _earningsHeroCard(TechnicianProvider tech, BookingProvider bp) {
    final allBookings = bp.bookings;

    // Real today's earnings — computed dynamically from actual backend data
    final todayEarnings = tech.todaysEarningsFrom(allBookings);
    final todayCompleted = tech.completedTodayCountFrom(allBookings);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "TODAY'S EARNINGS",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$todayCompleted Completed Today',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '₹${todayEarnings.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 14),
          Row(
            children: [
              _earningsStat('This Week', '₹${tech.weeklyEarningsFrom(allBookings).toStringAsFixed(0)}'),
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withValues(alpha: 0.2),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              _earningsStat('This Month', '₹${tech.monthlyEarningsFrom(allBookings).toStringAsFixed(0)}'),
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withValues(alpha: 0.2),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              _earningsStat(
                'Completed',
                '${allBookings.where((b) => b.status == 'COMPLETED').length}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _earningsStat(String label, String value) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );

  Widget _statsRow(BookingProvider bp) {
    final active = bp.bookings.where((b) => [
      'TECHNICIAN_ASSIGNED', 'TECHNICIAN_ON_WAY', 'ARRIVED',
      'DIAGNOSIS', 'WAITING_FOR_APPROVAL', 'REPAIRING', 'QC'
    ].contains(b.status)).length;
    final pending = bp.bookings.where((b) => b.status == 'PENDING' || b.status == 'CONFIRMED').length;

    return Row(
      children: [
        _statChip(Icons.pending_actions_rounded, '$pending', 'Pending', AppTheme.warning),
        const SizedBox(width: 10),
        _statChip(Icons.build_circle_rounded, '$active', 'Active', AppTheme.info),
        const SizedBox(width: 10),
        _statChip(
          Icons.check_circle_rounded,
          '${bp.bookings.where((b) => b.status == 'COMPLETED').length}',
          'Completed',
          AppTheme.success,
        ),
      ],
    );
  }

  Widget _statChip(IconData icon, String count, String label, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _filterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['All', 'Pending', 'Active', 'Completed'].map((f) {
          final sel = _filter == f;
          return GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: sel ? AppTheme.primary : AppTheme.darkCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? AppTheme.primary : AppTheme.darkBorder),
              ),
              child: Text(
                f,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: sel ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _emptyState(BookingProvider bp) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: const Icon(Icons.inbox_rounded, size: 36, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Customer Bookings Yet',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'New repair bookings submitted by customers will appear here in real time.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => bp.fetchBookings(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Refresh Database'),
            ),
          ],
        ),
      );
}

// Job Card Widget
class _JobCard extends StatelessWidget {
  final Booking booking;
  const _JobCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final statusMeta = _statusMeta(booking.status);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TechnicianJobDetailScreen(booking: booking)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: Column(
          children: [
            // Top Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: statusMeta.color.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                border: Border(bottom: BorderSide(color: statusMeta.color.withValues(alpha: 0.15))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusMeta.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      booking.statusDisplay.toUpperCase(),
                      style: TextStyle(
                        color: statusMeta.color,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    booking.bookingNumber,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.darkElevated,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(statusMeta.icon, color: statusMeta.color, size: 20),
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
                            Text(
                              booking.serviceName,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${booking.finalAmount.toInt()}',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  Container(height: 1, color: AppTheme.darkBorder),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 5),
                      Text(
                        booking.customerName,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.schedule_rounded, size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 5),
                      Text(
                        booking.scheduledSlot,
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          booking.addressLine,
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Action Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: booking.status == 'COMPLETED'
                          ? AppTheme.darkElevated
                          : AppTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                          size: 15,
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

  String _ctaLabel(String status) {
    switch (status) {
      case 'PENDING':
      case 'CONFIRMED':       return 'Accept Job';
      case 'TECHNICIAN_ASSIGNED': return 'Mark On The Way';
      case 'TECHNICIAN_ON_WAY':   return 'Mark Arrived';
      case 'ARRIVED':             return 'Start Inspection';
      case 'COMPLETED':           return 'View Summary';
      default:                    return 'Manage Job';
    }
  }

  _StatusMeta _statusMeta(String status) {
    switch (status) {
      case 'COMPLETED':           return _StatusMeta(AppTheme.success, Icons.check_circle_rounded);
      case 'WAITING_FOR_APPROVAL':return _StatusMeta(AppTheme.warning, Icons.hourglass_top_rounded);
      case 'PENDING':
      case 'CONFIRMED':           return _StatusMeta(AppTheme.info, Icons.bookmark_added_rounded);
      case 'REPAIRING':           return _StatusMeta(AppTheme.accent, Icons.build_rounded);
      default:                    return _StatusMeta(AppTheme.primary, Icons.engineering_rounded);
    }
  }
}

class _StatusMeta {
  final Color color;
  final IconData icon;
  const _StatusMeta(this.color, this.icon);
}
