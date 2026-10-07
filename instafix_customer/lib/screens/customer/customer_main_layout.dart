import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import 'customer_home_screen.dart';
import 'bookings_list_screen.dart';
import 'invoice_warranty_screen.dart';
import '../shared/profile_screen.dart';

class CustomerMainLayout extends StatefulWidget {
  /// When true, a welcome snackbar is shown once the Scaffold is ready.
  final bool showWelcome;
  const CustomerMainLayout({super.key, this.showWelcome = false});

  @override
  State<CustomerMainLayout> createState() => _CustomerMainLayoutState();
}

class _CustomerMainLayoutState extends State<CustomerMainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const CustomerHomeScreen(),
    const BookingsListScreen(),
    const InvoiceWarrantyScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      // Fetch real bookings from backend for current logged-in user
      Provider.of<BookingProvider>(context, listen: false).fetchBookings(user: user);

      // Show welcome snackbar safely from THIS screen's own Scaffold context
      if (widget.showWelcome) {
        final userName =
            Provider.of<AuthProvider>(context, listen: false).currentUser?.name ??
                'Customer';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Welcome back, $userName! 👋',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        indicatorColor: AppTheme.primaryLight,
        backgroundColor: AppTheme.surface,
        elevation: 8,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt_rounded, color: AppTheme.primary),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield_rounded, color: AppTheme.primary),
            label: 'Warranty',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
