import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import 'signup_screen.dart';
import '../technician/technician_main_layout.dart';

class LoginScreen extends StatefulWidget {
  final String? lockedRole;
  const LoginScreen({super.key, this.lockedRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).setSelectedRole('technician');
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Brand Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.35)),
                    ),
                    child: const Icon(
                      Icons.handyman_rounded,
                      color: AppTheme.primary,
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                const Text(
                  'InstaFix Partner',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Technician & Workshop Portal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 36),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.darkBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Enter your registered email and password.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                      ),

                      const SizedBox(height: 24),

                      _inputLabel('EMAIL ADDRESS'),
                      _inputField(
                        controller: _emailController,
                        hint: 'partner@instafix.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      _inputLabel('PASSWORD'),
                      _inputField(
                        controller: _passwordController,
                        hint: 'Enter your password',
                        icon: Icons.lock_outline_rounded,
                        obscure: _obscurePassword,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppTheme.textMuted,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Error Display
                      if (authProvider.lastError != null && !authProvider.isLoading) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  color: AppTheme.error, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authProvider.lastError!,
                                  style: const TextStyle(
                                      color: AppTheme.error, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Server wake-up banner
                      if (authProvider.isWakingServer) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppTheme.warning),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Connecting to server (${authProvider.wakeUpElapsed}s)...',
                                  style: const TextStyle(
                                      color: AppTheme.warning,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed:
                              (authProvider.isLoading || authProvider.isWakingServer)
                                  ? null
                                  : _onLoginPressed,
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have a partner account? ",
                      style:
                          TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const SignupScreen(initialRole: 'technician'),
                        ),
                      ),
                      child: const Text(
                        'Register Workshop',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          fontSize: 11,
          color: AppTheme.textMuted,
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
      decoration: InputDecoration(
        prefixIcon:
            icon != null ? Icon(icon, color: AppTheme.textMuted, size: 20) : null,
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppTheme.darkElevated,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
      ),
    );
  }

  Future<void> _onLoginPressed() async {
    final authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (_emailController.text.trim().isEmpty ||
        !_emailController.text.contains('@')) {
      messenger.showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid email address')),
      );
      return;
    }
    if (_passwordController.text.isEmpty) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Please enter your password')));
      return;
    }

    bool loggedIn = await authProvider.loginWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
      'technician',
    );
    if (!mounted) return;
    if (loggedIn) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TechnicianMainLayout()),
        (route) => false,
      );
    }
  }
}
