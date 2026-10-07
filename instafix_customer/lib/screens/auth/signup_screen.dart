import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'otp_screen.dart';

class SignupScreen extends StatefulWidget {
  final String initialRole;
  const SignupScreen({super.key, this.initialRole = 'customer'});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _addressCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final busy = auth.isLoading || auth.isWakingServer;

    return Scaffold(
      backgroundColor: const Color(0xFF090A10),
      body: Stack(
        children: [
          // ── Ambient Glows ───────────────────────────────────────────────────
          Positioned(
            top: -100,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.2),
                    const Color(0xFF6366F1).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.12),
                    const Color(0xFF10B981).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  // ── Top Navigation Bar ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFF131626),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF232742), width: 1),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.shield_outlined,
                                    size: 14,
                                    color: Color(0xFF818CF8),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'CUSTOMER REGISTRATION',
                                    style: GoogleFonts.dmSans(
                                      color: const Color(0xFFA5B4FC),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Form Area ────────────────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Create Account',
                              style: GoogleFonts.outfit(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Join Instafix to book fast doorstep repairs in 30 minutes.',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: const Color(0xFF94A3B8),
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 28),

                            // ── Full Name ─────────────────────────────────────────
                            _buildFieldHeader('FULL NAME'),
                            const SizedBox(height: 8),
                            _buildInputField(
                              controller: _nameCtrl,
                              hint: 'e.g. Rahul Sharma',
                              icon: Icons.person_outline_rounded,
                              textCapitalization: TextCapitalization.words,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Full name is required';
                                }
                                if (v.trim().length < 2) {
                                  return 'Please enter your complete name';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 18),

                            // ── Phone Number (CRITICAL FOR BACKEND) ───────────────
                            _buildFieldHeader('PHONE NUMBER'),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF131626),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF22263F),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        right: BorderSide(color: Color(0xFF22263F), width: 1.2),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                                        const SizedBox(width: 6),
                                        Text(
                                          '+91',
                                          style: GoogleFonts.dmSans(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _phoneCtrl,
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(10),
                                      ],
                                      style: GoogleFonts.dmSans(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF6366F1),
                                            width: 1.6,
                                          ),
                                        ),
                                        hintText: '9876543210',
                                        hintStyle: GoogleFonts.dmSans(
                                          color: const Color(0xFF475569),
                                          fontSize: 14,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Phone number is required';
                                        }
                                        if (v.trim().length < 10) {
                                          return 'Enter 10-digit mobile number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),

                            // ── Email Address ─────────────────────────────────────
                            _buildFieldHeader('EMAIL ADDRESS'),
                            const SizedBox(height: 8),
                            _buildInputField(
                              controller: _emailCtrl,
                              hint: 'name@example.com',
                              icon: Icons.alternate_email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!v.contains('@') || !v.contains('.')) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 18),

                            // ── Password ──────────────────────────────────────────
                            _buildFieldHeader('PASSWORD'),
                            const SizedBox(height: 8),
                            _buildInputField(
                              controller: _passwordCtrl,
                              hint: 'Min 6 characters',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF64748B),
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Password is required';
                                }
                                if (v.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 18),

                            // ── Doorstep Service Address ──────────────────────────
                            _buildFieldHeader('DOORSTEP SERVICE ADDRESS'),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF131626),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF22263F),
                                  width: 1.2,
                                ),
                              ),
                              child: TextFormField(
                                controller: _addressCtrl,
                                maxLines: 2,
                                style: GoogleFonts.dmSans(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF6366F1),
                                      width: 1.6,
                                    ),
                                  ),
                                  hintText: 'Flat / House No., Landmark, City, Pincode',
                                  hintStyle: GoogleFonts.dmSans(
                                    color: const Color(0xFF475569),
                                    fontSize: 13,
                                  ),
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.only(bottom: 24),
                                    child: Icon(
                                      Icons.location_on_outlined,
                                      color: Color(0xFF818CF8),
                                      size: 20,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Address is required for doorstep repairs';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(height: 28),

                            // ── Server Wake-Up Feedback ───────────────────────────
                            if (auth.isWakingServer) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF151829),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF818CF8)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Connecting to cloud server (${auth.wakeUpElapsed}s)...',
                                        style: GoogleFonts.dmSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // ── Submit Button ─────────────────────────────────────
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6366F1).withValues(alpha: busy ? 0.2 : 0.45),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: busy ? null : _handleSignup,
                                  child: Center(
                                    child: busy
                                        ? Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                auth.isWakingServer
                                                    ? 'Connecting...'
                                                    : 'Creating Account...',
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Complete Registration',
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  letterSpacing: 0.2,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 19,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ── Switch to Login ───────────────────────────────────
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: GoogleFonts.dmSans(
                                      color: const Color(0xFF94A3B8),
                                      fontSize: 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Text(
                                      'Sign In',
                                      style: GoogleFonts.dmSans(
                                        color: const Color(0xFF818CF8),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF94A3B8),
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131626),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF22263F),
          width: 1.2,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        style: GoogleFonts.dmSans(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF6366F1),
              width: 1.6,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFEF4444),
              width: 1.4,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFEF4444),
              width: 1.6,
            ),
          ),
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(
            color: const Color(0xFF475569),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF818CF8),
            size: 20,
          ),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
        validator: validator,
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    // Store the signup data in the provider (no API call yet).
    // The OTP screen will validate the code and then call the backend.
    auth.setPendingSignupData(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      password: _passwordCtrl.text,
      address: _addressCtrl.text.trim(),
      role: 'customer',
    );

    // Navigate to OTP screen for verification.
    navigator.push(
      PageRouteBuilder(
        pageBuilder: (context, anim, secAnim) => const OtpScreen(),
        transitionsBuilder: (context, anim, secAnim, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
