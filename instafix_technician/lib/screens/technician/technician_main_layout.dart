import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import 'technician_dashboard_screen.dart';
import 'technician_invoices_screen.dart';
import '../shared/profile_screen.dart';

class TechnicianMainLayout extends StatefulWidget {
  const TechnicianMainLayout({super.key});

  @override
  State<TechnicianMainLayout> createState() => _TechnicianMainLayoutState();
}

class _TechnicianMainLayoutState extends State<TechnicianMainLayout> {
  int _idx = 0;

  final _screens = const [
    TechnicianDashboardScreen(),
    TechnicianInvoicesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.darkNav,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: IndexedStack(index: _idx, children: _screens),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppTheme.darkNav,
            border: Border(top: BorderSide(color: AppTheme.darkBorder)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, -4)),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  _navItem(0, Icons.home_repair_service_outlined, Icons.home_repair_service_rounded, 'Jobs'),
                  _navItem(1, Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Earnings'),
                  _navItem(2, Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final selected = _idx == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _idx = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selected ? activeIcon : icon,
                  color: selected ? AppTheme.primary : AppTheme.textMuted,
                  size: 22),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? AppTheme.primary : AppTheme.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}
