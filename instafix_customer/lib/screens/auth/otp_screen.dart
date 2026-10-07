import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../customer/customer_main_layout.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isEmail = authProvider.isEmailOtp;
    final contact = authProvider.targetContact;
    final busy = authProvider.isLoading || authProvider.isWakingServer;

    return Scaffold(
      backgroundColor: const Color(0xFF090A10),
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.18),
                    const Color(0xFF6366F1).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
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

                  const SizedBox(height: 28),

                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      isEmail ? Icons.mark_email_read_rounded : Icons.sms_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                  const SizedBox(height: 22),

                  Text(
                    'Verify Code',
                    style: GoogleFonts.outfit(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isEmail
                        ? 'We sent a 4-digit verification code to:\n$contact'
                        : 'We sent a 4-digit verification code to:\n+91 $contact',
                    style: GoogleFonts.dmSans(
                      color: const Color(0xFF94A3B8),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // OTP Container
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131626),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF2E3456),
                        width: 1.4,
                      ),
                    ),
                    child: TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      autofocus: true,
                      style: GoogleFonts.dmSans(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 22,
                        color: const Color(0xFF818CF8),
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                        hintText: '••••',
                        hintStyle: GoogleFonts.dmSans(
                          color: const Color(0xFF475569),
                          letterSpacing: 22,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Verify CTA Button
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
                          color: const Color(0xFF6366F1).withValues(alpha: busy ? 0.2 : 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: busy ? null : _handleVerify,
                        child: Center(
                          child: busy
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  'Verify & Sign In',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
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

  Future<void> _handleVerify() async {
    final code = _otpController.text.trim();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 4-digit code'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    bool verified = await auth.verifyOtp(code);
    if (!mounted) return;

    if (verified) {
      // Navigate without calling showSnackBar first — pushAndRemoveUntil
      // deactivates this Scaffold immediately, causing the ancestor crash.
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (_) => const CustomerMainLayout(showWelcome: true)),
        (route) => false,
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(auth.lastError ?? 'Verification failed'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }
}
