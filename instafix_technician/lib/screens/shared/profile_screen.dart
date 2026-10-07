import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkNav,
        elevation: 0,
        title: const Text('Partner Account',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 19)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                      child: const Icon(Icons.person_rounded, size: 36, color: AppTheme.accent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Technician Partner',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user?.email ?? user?.phone ?? '',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  (user?.role ?? 'TECHNICIAN').toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.accent),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.success.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 12),
                                    SizedBox(width: 4),
                                    Text('Verified Partner',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.success)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (user?.shopName != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.darkBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront_rounded, color: AppTheme.accent, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('WORKSHOP', style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(user!.shopName!,
                                style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              _menuItem(Icons.location_on_outlined, 'Service Area & Workshop Address'),
              _menuItem(Icons.payment_outlined, 'Bank Account & UPI Payouts'),
              _menuItem(Icons.cloud_done_rounded, 'Backend API Connection Status (Render Live)'),
              _menuItem(Icons.help_outline_rounded, 'Partner Support & Help Center'),
              _menuItem(Icons.description_outlined, 'Terms & Service Guidelines'),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    side: const BorderSide(color: AppTheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
                  label: const Text('Log Out of Partner Account', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.textSecondary, size: 20),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
        onTap: () {},
      ),
    );
  }
}
