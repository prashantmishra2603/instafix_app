import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  // Edit controllers
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _shopCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        _nameCtrl.text = user.name;
        _phoneCtrl.text = user.phone;
        _shopCtrl.text = user.shopName ?? '';
        _skillsCtrl.text = user.skills ?? '';
        _addressCtrl.text = user.address ?? '';
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _shopCtrl.dispose();
    _skillsCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfile(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      shopName: _shopCtrl.text.trim(),
      skills: _skillsCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
    );
    setState(() {
      _isSaving = false;
      if (success) _isEditing = false;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            success ? '✅ Profile updated successfully!' : '❌ Update failed. Try again.'),
        backgroundColor: success ? AppTheme.success : AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bp = context.watch<BookingProvider>();
    final user = auth.currentUser;

    final completedJobs =
        bp.bookings.where((b) => b.status == 'COMPLETED').length;
    final totalEarnings = bp.bookings
        .where((b) => b.status == 'COMPLETED')
        .fold<double>(0.0, (s, b) => s + b.finalAmount);
    final activeJobs = bp.bookings
        .where((b) =>
            b.status != 'COMPLETED' &&
            b.status != 'CANCELLED' &&
            b.status != 'REJECTED')
        .length;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // ── Hero AppBar ──────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: AppTheme.darkNav,
              automaticallyImplyLeading: false,
              actions: [
                if (!_isEditing)
                  GestureDetector(
                    onTap: () => setState(() => _isEditing = true),
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.35)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_rounded,
                              color: AppTheme.primary, size: 14),
                          SizedBox(width: 5),
                          Text('Edit',
                              style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                if (_isEditing)
                  GestureDetector(
                    onTap: () {
                      final user2 = auth.currentUser;
                      setState(() {
                        _isEditing = false;
                        _nameCtrl.text = user2?.name ?? '';
                        _phoneCtrl.text = user2?.phone ?? '';
                        _shopCtrl.text = user2?.shopName ?? '';
                        _skillsCtrl.text = user2?.skills ?? '';
                        _addressCtrl.text = user2?.address ?? '';
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppTheme.darkElevated,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ),
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1A1040),
                        Color(0xFF0F1320),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Tool pattern background
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Icon(Icons.settings_rounded,
                            size: 160,
                            color:
                                AppTheme.primary.withValues(alpha: 0.04)),
                      ),
                      Positioned(
                        left: -30,
                        bottom: -30,
                        child: Icon(Icons.build_rounded,
                            size: 140,
                            color:
                                AppTheme.accent.withValues(alpha: 0.03)),
                      ),
                      // Profile Info
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Row(
                          children: [
                            // Avatar with repair icon overlay
                            Stack(
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primary
                                            .withValues(alpha: 0.4),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      (user?.name.isNotEmpty == true
                                          ? user!.name[0].toUpperCase()
                                          : 'T'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.success,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppTheme.darkBg,
                                          width: 2),
                                    ),
                                    child: const Icon(
                                        Icons.build_rounded,
                                        size: 10,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.name ?? 'Technician Partner',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user?.email ??
                                        user?.phone ??
                                        'Not set',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _heroBadge('⚙️ TECHNICIAN',
                                          AppTheme.primary),
                                      const SizedBox(width: 6),
                                      _heroBadge('✓ VERIFIED',
                                          AppTheme.success),
                                    ],
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
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Stats Row ─────────────────────────────────────────
                    Row(
                      children: [
                        _statCard(
                          Icons.check_circle_rounded,
                          '$completedJobs',
                          'Completed',
                          AppTheme.success,
                        ),
                        const SizedBox(width: 10),
                        _statCard(
                          Icons.bolt_rounded,
                          '$activeJobs',
                          'Active',
                          AppTheme.warning,
                        ),
                        const SizedBox(width: 10),
                        _statCard(
                          Icons.currency_rupee_rounded,
                          totalEarnings.toStringAsFixed(0),
                          'Earned',
                          AppTheme.accent,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Edit / View Form ──────────────────────────────────
                    if (_isEditing) ...[
                      _sectionLabel(
                          Icons.manage_accounts_rounded, 'Edit Profile'),
                      const SizedBox(height: 14),
                      _formCard([
                        _editField(
                          ctrl: _nameCtrl,
                          label: 'Full Name',
                          icon: Icons.person_rounded,
                          hint: 'Enter your full name',
                        ),
                        const SizedBox(height: 12),
                        _editField(
                          ctrl: _phoneCtrl,
                          label: 'Phone Number',
                          icon: Icons.phone_rounded,
                          hint: '+91 XXXXX XXXXX',
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                        const SizedBox(height: 12),
                        _editField(
                          ctrl: _shopCtrl,
                          label: 'Workshop / Shop Name',
                          icon: Icons.storefront_rounded,
                          hint: 'e.g. TechFix Solutions',
                        ),
                        const SizedBox(height: 12),
                        _editField(
                          ctrl: _skillsCtrl,
                          label: 'Skills (comma separated)',
                          icon: Icons.build_rounded,
                          hint:
                              'e.g. Screen Repair, Battery, Motherboard',
                        ),
                        const SizedBox(height: 12),
                        _editField(
                          ctrl: _addressCtrl,
                          label: 'Workshop Address',
                          icon: Icons.location_on_rounded,
                          hint: 'Full workshop address',
                          maxLines: 2,
                        ),
                      ]),
                      const SizedBox(height: 20),
                      // Note about email
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              AppTheme.info.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color:
                                  AppTheme.info.withValues(alpha: 0.2)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 16, color: AppTheme.info),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Email cannot be changed. Contact support if needed.',
                                style: TextStyle(
                                    color: AppTheme.info,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Save Button
                      GestureDetector(
                        onTap: _isSaving ? null : _saveProfile,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: _isSaving
                                ? null
                                : AppTheme.primaryGradient,
                            color: _isSaving
                                ? AppTheme.darkCard
                                : null,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _isSaving
                                ? []
                                : [
                                    BoxShadow(
                                      color: AppTheme.primary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                          ),
                          child: Center(
                            child: _isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white),
                                  )
                                : const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.save_rounded,
                                          color: Colors.white,
                                          size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Save Changes',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // ── View Mode ────────────────────────────────────────
                      _sectionLabel(Icons.badge_rounded, 'Profile Details'),
                      const SizedBox(height: 14),
                      _infoCard([
                        _infoRow(Icons.person_rounded, 'Name',
                            user?.name ?? '—'),
                        _divider(),
                        _infoRow(Icons.phone_rounded, 'Phone',
                            user?.phone.isNotEmpty == true
                                ? user!.phone
                                : '—'),
                        _divider(),
                        _infoRow(Icons.email_outlined, 'Email',
                            user?.email ?? '—',
                            badge: '🔒 Read only'),
                        if (user?.shopName?.isNotEmpty == true) ...[
                          _divider(),
                          _infoRow(Icons.storefront_rounded, 'Workshop',
                              user!.shopName!),
                        ],
                        if (user?.skills?.isNotEmpty == true) ...[
                          _divider(),
                          _infoRow(Icons.build_rounded, 'Skills',
                              user!.skills!),
                        ],
                        if (user?.address?.isNotEmpty == true) ...[
                          _divider(),
                          _infoRow(Icons.location_on_rounded, 'Address',
                              user!.address!),
                        ],
                      ]),

                    ],

                    const SizedBox(height: 24),

                    _sectionLabel(
                        Icons.settings_rounded, 'Account Settings'),
                    const SizedBox(height: 14),

                    _settingsTile(
                      Icons.notifications_outlined,
                      'Job Notifications',
                      'Push alerts for new assignments',
                      AppTheme.primary,
                      onTap: () => _openSettingsPage(context, 'Job Notifications'),
                    ),
                    _settingsTile(
                      Icons.account_balance_outlined,
                      'Bank Account & UPI Payouts',
                      'Manage your payout method',
                      AppTheme.success,
                      onTap: () => _openSettingsPage(context, 'Bank Account & UPI Payouts'),
                    ),
                    _settingsTile(
                      Icons.location_on_outlined,
                      'Service Area',
                      'Set your work zones & coverage',
                      AppTheme.info,
                      onTap: () => _openSettingsPage(context, 'Service Area'),
                    ),
                    _settingsTile(
                      Icons.help_outline_rounded,
                      'Partner Support',
                      'Help center & contact us',
                      AppTheme.warning,
                      onTap: () => _openSettingsPage(context, 'Partner Support'),
                    ),
                    _settingsTile(
                      Icons.description_outlined,
                      'Terms & Service Guidelines',
                      'Partner agreement & policies',
                      AppTheme.textMuted,
                      onTap: () => _openSettingsPage(context, 'Terms & Service Guidelines'),
                    ),

                    const SizedBox(height: 28),

                    // ── Logout ────────────────────────────────────────────
                    GestureDetector(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppTheme.darkCard,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            title: const Text('Log Out?',
                                style: TextStyle(color: Colors.white)),
                            content: const Text(
                                'Are you sure you want to log out of your partner account?',
                                style: TextStyle(
                                    color: AppTheme.textSecondary)),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, false),
                                  child: const Text('Cancel')),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, true),
                                style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.error),
                                child: const Text('Log Out'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && mounted) {
                          await auth.logout();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color:
                              AppTheme.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color:
                                  AppTheme.error.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_rounded,
                                color: AppTheme.error, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Log Out of Partner Account',
                              style: TextStyle(
                                  color: AppTheme.error,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSettingsPage(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SettingsDetailScreen(title: title)),
    );
  }

  Widget _heroBadge(String label, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Text(label,
            style: TextStyle(
                color: color,
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5)),
      );

  Widget _statCard(
          IconData icon, String value, String label, Color color) =>
      Expanded(
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              Text(label,
                  style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );

  Widget _sectionLabel(IconData icon, String label) => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 16),
          ),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
        ],
      );

  Widget _infoCard(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: children),
        ),
      );

  Widget _formCard(List<Widget> children) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: Column(children: children),
      );

  Widget _infoRow(IconData icon, String label, String value,
          {String? badge}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: AppTheme.primary),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            if (badge != null) ...[
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(badge,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 10)),
              ),
            ],
          ],
        ),
      );

  Widget _divider() =>
      Divider(height: 1, color: AppTheme.darkBorder.withValues(alpha: 0.6));

  Widget _editField({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 18, color: AppTheme.primary),
          filled: true,
          fillColor: AppTheme.darkElevated,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppTheme.primary, width: 1.5),
          ),
        ),
      );

  Widget _settingsTile(
    IconData icon,
    String title,
    String subtitle,
    Color color, {
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 13, color: AppTheme.textMuted),
            ],
          ),
        ),
      );
}

class SettingsDetailScreen extends StatefulWidget {
  final String title;
  
  const SettingsDetailScreen({super.key, required this.title});

  @override
  State<SettingsDetailScreen> createState() => _SettingsDetailScreenState();
}

class _SettingsDetailScreenState extends State<SettingsDetailScreen> {
  // Notification toggles
  bool _newJobAlerts = true;
  bool _statusUpdates = true;
  bool _earningsAlerts = true;
  bool _promotionalAlerts = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // Bank/UPI state
  final _bankNameCtrl = TextEditingController(text: '');
  final _accountCtrl = TextEditingController(text: '');
  final _ifscCtrl = TextEditingController(text: '');
  final _upiCtrl = TextEditingController(text: '');
  String _payoutMethod = 'Bank Transfer';

  // Service Area state
  final List<String> _selectedAreas = ['Koramangala', 'HSR Layout', 'Bellandur'];
  final List<String> _availableAreas = [
    'Koramangala', 'HSR Layout', 'Bellandur', 'Whitefield',
    'Indiranagar', 'Jayanagar', 'BTM Layout', 'Electronic City',
    'Marathahalli', 'Hebbal', 'Yelahanka', 'Rajajinagar',
    'MG Road', 'Banashankari', 'JP Nagar', 'Malleshwaram',
  ];
  double _serviceRadius = 10.0;

  @override
  void dispose() {
    _bankNameCtrl.dispose();
    _accountCtrl.dispose();
    _ifscCtrl.dispose();
    _upiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppTheme.darkNav,
        elevation: 0,
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (widget.title) {
      case 'Job Notifications':
        return _buildNotificationsPage();
      case 'Bank Account & UPI Payouts':
        return _buildBankPayoutsPage();
      case 'Service Area':
        return _buildServiceAreaPage();
      case 'Partner Support':
        return _buildPartnerSupportPage();
      case 'Terms & Service Guidelines':
        return _buildTermsPage();
      default:
        return _buildTermsPage();
    }
  }

  // ── Job Notifications Page ─────────────────────────────────────────────
  Widget _buildNotificationsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _settingsSection('Job Alerts', Icons.work_rounded, AppTheme.primary, [
            _toggleTile('New Job Assignments', 'Get notified when a new job is assigned', _newJobAlerts, (v) => setState(() => _newJobAlerts = v)),
            _toggleTile('Status Updates', 'Customer approval & booking changes', _statusUpdates, (v) => setState(() => _statusUpdates = v)),
            _toggleTile('Earnings Updates', 'Payment received notifications', _earningsAlerts, (v) => setState(() => _earningsAlerts = v)),
          ]),
          const SizedBox(height: 20),
          _settingsSection('Promotions', Icons.campaign_rounded, AppTheme.warning, [
            _toggleTile('Promotional Alerts', 'Offers, incentives & bonus updates', _promotionalAlerts, (v) => setState(() => _promotionalAlerts = v)),
          ]),
          const SizedBox(height: 20),
          _settingsSection('Preferences', Icons.tune_rounded, AppTheme.info, [
            _toggleTile('Sound', 'Play notification sound', _soundEnabled, (v) => setState(() => _soundEnabled = v)),
            _toggleTile('Vibration', 'Vibrate on notification', _vibrationEnabled, (v) => setState(() => _vibrationEnabled = v)),
          ]),
          const SizedBox(height: 24),
          _actionCard(
            icon: Icons.notifications_off_rounded,
            title: 'Quiet Hours',
            subtitle: 'Mute notifications from 11 PM to 7 AM',
            color: AppTheme.textMuted,
          ),
        ],
      ),
    );
  }

  // ── Bank Account & UPI Payouts Page ────────────────────────────────────
  Widget _buildBankPayoutsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payout Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('PAYOUT BALANCE', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('₹0.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('Next payout: Every Monday', style: TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Payout Method Selection
          _sectionLabel('Payout Method'),
          const SizedBox(height: 12),
          Row(
            children: [
              _payoutMethodChip('Bank Transfer', Icons.account_balance_rounded),
              const SizedBox(width: 10),
              _payoutMethodChip('UPI', Icons.qr_code_rounded),
            ],
          ),

          const SizedBox(height: 24),

          if (_payoutMethod == 'Bank Transfer') ...[
            _sectionLabel('Bank Account Details'),
            const SizedBox(height: 12),
            _formCard([
              _bankField(ctrl: _bankNameCtrl, label: 'Bank Name', icon: Icons.account_balance_rounded),
              const SizedBox(height: 12),
              _bankField(ctrl: _accountCtrl, label: 'Account Number', icon: Icons.credit_card_rounded),
              const SizedBox(height: 12),
              _bankField(ctrl: _ifscCtrl, label: 'IFSC Code', icon: Icons.pin_rounded),
            ]),
          ] else ...[
            _sectionLabel('UPI Details'),
            const SizedBox(height: 12),
            _formCard([
              _bankField(ctrl: _upiCtrl, label: 'UPI ID', icon: Icons.qr_code_rounded),
            ]),
          ],

          const SizedBox(height: 24),

          // Save Button
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('✅ Payout details saved successfully!'),
                  backgroundColor: AppTheme.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 4)),
                ],
              ),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.save_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Save Payout Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Payout History
          _sectionLabel('Recent Payouts'),
          const SizedBox(height: 12),
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No recent payouts',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Service Area Page ──────────────────────────────────────────────────
  Widget _buildServiceAreaPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Radius
          _sectionLabel('Service Radius'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Coverage Radius', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${_serviceRadius.toInt()} km', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppTheme.primary,
                    inactiveTrackColor: AppTheme.darkElevated,
                    thumbColor: AppTheme.primary,
                    overlayColor: AppTheme.primary.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: _serviceRadius,
                    min: 1,
                    max: 30,
                    divisions: 29,
                    onChanged: (v) => setState(() => _serviceRadius = v),
                  ),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('1 km', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    Text('30 km', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Selected Areas
          _sectionLabel('Selected Work Zones'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedAreas.map((area) => _areaChip(area, selected: true)).toList(),
          ),

          const SizedBox(height: 24),

          // Available Areas
          _sectionLabel('Available Zones'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableAreas
                .where((a) => !_selectedAreas.contains(a))
                .map((area) => _areaChip(area, selected: false))
                .toList(),
          ),

          const SizedBox(height: 24),

          // Save Button
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('✅ Service area updated!'),
                  backgroundColor: AppTheme.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('Save Service Area', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Partner Support Page ───────────────────────────────────────────────
  Widget _buildPartnerSupportPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Help
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1040), Color(0xFF0F1320)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.headset_mic_rounded, color: AppTheme.primary, size: 24),
                    SizedBox(width: 10),
                    Text('Need Help?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Our partner support team is available 24/7', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _supportActionBtn(Icons.call_rounded, 'Call Us', AppTheme.success, () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Calling InstaFix Support...')),
                        );
                      }),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _supportActionBtn(Icons.chat_rounded, 'Chat', AppTheme.info, () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Opening chat support...')),
                        );
                      }),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _supportActionBtn(Icons.email_rounded, 'Email', AppTheme.warning, () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Opening email...')),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _sectionLabel('Frequently Asked Questions'),
          const SizedBox(height: 12),
          _faqItem('How do I get paid?', 'Payouts are processed every Monday to your registered bank account or UPI ID. Minimum payout is ₹500.'),
          _faqItem('How to update my skills?', 'Go to Profile → Edit Profile and update your skills list. New skills will be verified within 24 hours.'),
          _faqItem('What if customer is not available?', 'Wait for 15 minutes at the location. If customer doesn\'t respond, mark as "Customer Not Available" and our support team will handle it.'),
          _faqItem('How is my rating calculated?', 'Your rating is based on customer reviews, job completion rate, punctuality, and quality of repairs.'),
          _faqItem('How do I reject a job?', 'You can decline a job from the job detail screen. However, frequent declines may affect your rating.'),
          _faqItem('Parts procurement support?', 'Contact our parts team via the support chat for OEM parts procurement at partner prices.'),

          const SizedBox(height: 24),

          // Contact Info
          _sectionLabel('Contact Information'),
          const SizedBox(height: 12),
          _contactTile(Icons.phone_rounded, 'Partner Helpline', '+91 1800-123-4567', AppTheme.success),
          _contactTile(Icons.email_rounded, 'Email Support', 'partners@instafix.in', AppTheme.info),
          _contactTile(Icons.access_time_rounded, 'Working Hours', '24/7 Support Available', AppTheme.warning),
        ],
      ),
    );
  }

  // ── Terms & Service Guidelines Page ────────────────────────────────────
  Widget _buildTermsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _termsSection('Partner Agreement', Icons.handshake_rounded, AppTheme.primary, [
            'You agree to provide professional repair services as an independent partner.',
            'All repairs must use genuine or approved OEM replacement parts.',
            'InstaFix reserves the right to reassign jobs in case of non-compliance.',
            'Partners must maintain a minimum 4.0 rating to remain active.',
          ]),
          const SizedBox(height: 16),
          _termsSection('Service Quality Standards', Icons.verified_rounded, AppTheme.success, [
            'Complete pre-repair inspection with photo documentation.',
            'Follow the 10-point quality checklist for every repair.',
            'Provide post-repair quality check results to customer.',
            'All repairs carry a 6-month warranty through InstaFix Shield.',
          ]),
          const SizedBox(height: 16),
          _termsSection('Payment & Commission', Icons.payments_rounded, AppTheme.warning, [
            'Platform commission: 15% of job value.',
            'Weekly payouts every Monday to registered account.',
            'Bonus incentives for 5-star rated jobs.',
            'Cancellation penalties apply for accepted then declined jobs.',
          ]),
          const SizedBox(height: 16),
          _termsSection('Code of Conduct', Icons.gavel_rounded, AppTheme.info, [
            'Maintain professional behavior with all customers.',
            'Arrive within the scheduled time slot.',
            'Do not charge customers directly; all payments go through InstaFix.',
            'Report any customer disputes to the support team immediately.',
          ]),
          const SizedBox(height: 16),
          _termsSection('Privacy & Data', Icons.security_rounded, AppTheme.error, [
            'Customer data is confidential and must not be shared.',
            'Location data is collected only during active jobs.',
            'You can request deletion of your data by contacting support.',
            'InstaFix complies with India\'s data protection regulations.',
          ]),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.textMuted.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.textMuted),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Last updated: October 1, 2026. Contact support for questions.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Helper Widgets ─────────────────────────────────────────────────────

  Widget _sectionLabel(String label) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.label_rounded, color: AppTheme.primary, size: 14),
      ),
      const SizedBox(width: 10),
      Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
    ],
  );

  Widget _settingsSection(String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _toggleTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
            activeTrackColor: AppTheme.primary.withValues(alpha: 0.3),
            inactiveTrackColor: AppTheme.darkElevated,
            inactiveThumbColor: AppTheme.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _actionCard({required IconData icon, required String title, required String subtitle, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppTheme.textMuted),
        ],
      ),
    );
  }

  Widget _payoutMethodChip(String label, IconData icon) {
    final selected = _payoutMethod == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _payoutMethod = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary.withValues(alpha: 0.15) : AppTheme.darkCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? AppTheme.primary : AppTheme.darkBorder),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppTheme.primary : AppTheme.textMuted, size: 22),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(
                color: selected ? AppTheme.primary : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formCard(List<Widget> children) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppTheme.darkCard,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppTheme.darkBorder),
    ),
    child: Column(children: children),
  );

  Widget _bankField({required TextEditingController ctrl, required String label, required IconData icon}) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppTheme.primary),
        filled: true,
        fillColor: AppTheme.darkElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.darkBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.darkBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
      ),
    );
  }

  Widget _payoutHistoryItem(String date, String amount, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(status, style: const TextStyle(color: AppTheme.success, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Text(amount, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _areaChip(String area, {required bool selected}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (selected) {
            _selectedAreas.remove(area);
          } else {
            _selectedAreas.add(area);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withValues(alpha: 0.15) : AppTheme.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.darkBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded, size: 14, color: AppTheme.primary),
              const SizedBox(width: 4),
            ],
            Text(area, style: TextStyle(
              color: selected ? AppTheme.primary : AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            )),
          ],
        ),
      ),
    );
  }

  Widget _supportActionBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        iconColor: AppTheme.primary,
        collapsedIconColor: AppTheme.textMuted,
        title: Text(question, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
        children: [
          Text(answer, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  Widget _contactTile(IconData icon, String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _termsSection(String title, IconData icon, Color color, List<String> items) {
    return Container(
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
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(item, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

