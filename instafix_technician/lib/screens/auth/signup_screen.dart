import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import 'otp_screen.dart';

class SignupScreen extends StatefulWidget {
  final String initialRole;
  const SignupScreen({super.key, this.initialRole = 'technician'});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _skillsController =
      TextEditingController(text: 'Screen Repair, Battery, Motherboard');
  final _addressController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _shopNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _skillsController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkNav,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Register Workshop',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Partner Registration',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create an account to start receiving repair orders from customers in your area.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),

                _label('FULL NAME'),
                _inputField(
                  controller: _nameController,
                  hint: 'e.g. Vikram Sharma',
                  icon: Icons.person_outline_rounded,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
                ),
                const SizedBox(height: 16),

                _label('WORKSHOP / SHOP NAME'),
                _inputField(
                  controller: _shopNameController,
                  hint: 'e.g. InstaFix Repair Hub',
                  icon: Icons.storefront_outlined,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Shop name is required' : null,
                ),
                const SizedBox(height: 16),

                _label('EMAIL ADDRESS'),
                _inputField(
                  controller: _emailController,
                  hint: 'partner@instafix.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _label('MOBILE NUMBER'),
                _inputField(
                  controller: _phoneController,
                  hint: '98765 43210',
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  prefix: '🇮🇳 +91  ',
                  validator: (v) =>
                      (v == null || v.trim().length != 10) ? 'Enter valid 10-digit number' : null,
                ),
                const SizedBox(height: 16),

                _label('PASSWORD'),
                _inputField(
                  controller: _passwordController,
                  hint: 'Minimum 6 characters',
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
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 16),

                _label('REPAIR SKILLS'),
                _inputField(
                  controller: _skillsController,
                  hint: 'Screen, Battery, Motherboard, Charging',
                  icon: Icons.handyman_outlined,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Please enter your repair skills' : null,
                ),
                const SizedBox(height: 16),

                _label('WORKSHOP ADDRESS'),
                _inputField(
                  controller: _addressController,
                  hint: 'Shop No., Market Area, City, Pincode',
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Workshop address is required' : null,
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: (authProvider.isLoading || authProvider.isWakingServer)
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            final navigator = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);
                            bool sent = await authProvider.initiateSignup(
                              role: 'technician',
                              name: _nameController.text.trim(),
                              shopName: _shopNameController.text.trim(),
                              email: _emailController.text.trim(),
                              phone: _phoneController.text.trim(),
                              password: _passwordController.text,
                              skills: _skillsController.text.trim(),
                              address: _addressController.text.trim(),
                            );
                            if (!mounted) return;
                            if (sent) {
                              navigator.push(
                                  MaterialPageRoute(builder: (_) => const OtpScreen()));
                            } else if (authProvider.lastError != null) {
                              messenger.showSnackBar(SnackBar(
                                content: Text(authProvider.lastError!),
                                backgroundColor: AppTheme.error,
                              ));
                            }
                          },
                    child: (authProvider.isLoading || authProvider.isWakingServer)
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            'Create Account & Verify',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already registered? ',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            fontSize: 11,
            color: AppTheme.textMuted,
          ),
        ),
      );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
    String? prefix,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, color: AppTheme.textMuted, size: 20) : null,
        prefixText: prefix,
        prefixStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
        suffixIcon: suffix,
        counterText: '',
        filled: true,
        fillColor: AppTheme.darkElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        errorStyle: const TextStyle(color: AppTheme.error),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.error, width: 2),
        ),
      ),
    );
  }
}
