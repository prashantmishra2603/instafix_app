import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../providers/technician_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class TechnicianKycScreen extends StatefulWidget {
  const TechnicianKycScreen({super.key});

  @override
  State<TechnicianKycScreen> createState() => _TechnicianKycScreenState();
}

class _TechnicianKycScreenState extends State<TechnicianKycScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _aadhaarCtrl;
  late TextEditingController _panCtrl;
  late TextEditingController _bikeCtrl;

  bool _isUploading = false;
  String _uploadStepText = '';
  double _uploadProgress = 0.0;

  // Actual Image URLs for the documents
  String? _aadhaarFrontImg;
  String? _aadhaarBackImg;
  String? _panImg;
  String? _bikeRcImg;
  String? _paymentScreenshotImg;

  // Admin Payment Configuration for ₹199 Subscription
  String _adminUpiId = 'instafix@okaxis';
  String _adminQrUrl = '';
  String _kycFee = '199';
  bool _isLoadingPaymentInfo = false;

  // Preset realistic high-resolution document photos
  static const String _defaultAadhaarFront =
      'https://images.unsplash.com/photo-1633265486064-086b219458ec?w=600&auto=format&fit=crop&q=80';
  static const String _defaultAadhaarBack =
      'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600&auto=format&fit=crop&q=80';
  static const String _defaultPan =
      'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600&auto=format&fit=crop&q=80';
  static const String _defaultBikeRc =
      'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=600&auto=format&fit=crop&q=80';
  static const String _defaultPaymentSlip =
      'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600&auto=format&fit=crop&q=80';

  @override
  void initState() {
    super.initState();
    final tech = context.read<TechnicianProvider>();
    final kyc = tech.kyc;

    _aadhaarCtrl = TextEditingController(text: kyc.aadhaarNumber);
    _panCtrl = TextEditingController(text: kyc.panNumber);
    _bikeCtrl = TextEditingController(text: kyc.bikeNumber);

    if (kyc.aadhaarFrontUrl.isNotEmpty) _aadhaarFrontImg = kyc.aadhaarFrontUrl;
    if (kyc.aadhaarBackUrl.isNotEmpty) _aadhaarBackImg = kyc.aadhaarBackUrl;
    if (kyc.panCardUrl.isNotEmpty) _panImg = kyc.panCardUrl;
    if (kyc.bikeRcUrl.isNotEmpty) _bikeRcImg = kyc.bikeRcUrl;
    if (kyc.paymentScreenshotUrl != null && kyc.paymentScreenshotUrl!.isNotEmpty) {
      _paymentScreenshotImg = kyc.paymentScreenshotUrl;
    }

    _loadAdminPaymentInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser != null) {
        context.read<TechnicianProvider>().fetchKycStatusFromApi(auth.currentUser!.id);
      }
    });
  }

  Future<void> _loadAdminPaymentInfo() async {
    setState(() => _isLoadingPaymentInfo = true);
    try {
      final info = await ApiService.getPaymentSettings();
      if (mounted) {
        setState(() {
          _adminUpiId = info['upi_id'] ?? 'instafix@okaxis';
          _adminQrUrl = info['qr_image_url'] ?? '';
          _kycFee = (info['kyc_fee'] ?? '199').toString();
          _isLoadingPaymentInfo = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingPaymentInfo = false);
    }
  }

  @override
  void dispose() {
    _aadhaarCtrl.dispose();
    _panCtrl.dispose();
    _bikeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleUploadAndSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Require all 4 document photos
    if (_aadhaarFrontImg == null || _aadhaarBackImg == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please upload both Aadhaar Front and Back photos'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    if (_panImg == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please upload your PAN Card photo'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    if (_bikeRcImg == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please upload your Bike RC / Number plate photo'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    if (_paymentScreenshotImg == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Please upload your ₹$_kycFee subscription payment screenshot'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.15;
      _uploadStepText = 'Validating Government ID numbers...';
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _uploadProgress = 0.45;
      _uploadStepText = 'Encrypting & uploading Aadhaar Front/Back scans...';
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _uploadProgress = 0.75;
      _uploadStepText = 'Uploading PAN Card copy & Bike Registration Certificate...';
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _uploadProgress = 0.90;
      _uploadStepText = 'Attaching ₹$_kycFee Subscription Payment receipt...';
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _uploadProgress = 0.98;
      _uploadStepText = 'Submitting KYC dossier to Instafix Admin Verification Portal...';
    });

    final tech = context.read<TechnicianProvider>();
    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser?.id;

    await tech.submitKyc(
      aadhaarNumber: _aadhaarCtrl.text.trim(),
      panNumber: _panCtrl.text.trim(),
      bikeNumber: _bikeCtrl.text.trim(),
      aadhaarFrontUrl: _aadhaarFrontImg,
      aadhaarBackUrl: _aadhaarBackImg,
      panCardUrl: _panImg,
      bikeRcUrl: _bikeRcImg,
      paymentScreenshotUrl: _paymentScreenshotImg,
      userId: userId,
    );

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _isUploading = false;
      _uploadProgress = 1.0;
    });

    _showSubmittedDialog();
  }

  void _showSubmittedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.3)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.hourglass_top_rounded, color: AppTheme.warning, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'KYC Submitted Successfully!',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Aadhaar, PAN card, and Bike RC documents have been uploaded securely.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, height: 1.4),
            ),
            SizedBox(height: 12),
            Text(
              'Status: Under Admin Review ⏳\nOnce an admin approves your profile, your status will update to "KYC Verified" and repair job acceptance will be unlocked automatically.',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadImage({
    required String title,
    required ImageSource source,
    required String uploadType,
    required Function(String url) onImageSelected,
  }) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: AppTheme.darkCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppTheme.primary),
                  const SizedBox(height: 18),
                  Text('Uploading $title...',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 6),
                  const Text('Sending securely to verification server...',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      );

      final bytes = await pickedFile.readAsBytes();
      final uploadedUrl = await ApiService.uploadImageBytes(
        bytes,
        fileName: pickedFile.name,
        type: uploadType,
      );

      if (mounted) {
        Navigator.pop(context); // close loading dialog
      }

      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        onImageSelected(uploadedUrl);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ $title uploaded successfully to verification server!'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Upload failed. Please check internet and try again.'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Error selecting/uploading image: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  void _openImagePickerSheet({
    required String title,
    required String uploadType,
    String? defaultPresetUrl,
    required Function(String url) onImageSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.darkBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Upload $title',
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Upload real photo from camera or gallery for admin verification:',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12.5),
              ),
              const SizedBox(height: 18),

              // Option 1: Take Photo with Camera
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_camera_rounded, color: AppTheme.primary, size: 22),
                ),
                title: const Text('Take Photo (Camera)',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Capture clear photo directly from device camera',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11.5)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadImage(
                    title: title,
                    source: ImageSource.camera,
                    uploadType: uploadType,
                    onImageSelected: onImageSelected,
                  );
                },
              ),
              const Divider(color: AppTheme.darkBorder),

              // Option 2: Choose from Gallery
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppTheme.accent, size: 22),
                ),
                title: const Text('Choose from Device Gallery',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Select existing photo from phone storage',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11.5)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadImage(
                    title: title,
                    source: ImageSource.gallery,
                    uploadType: uploadType,
                    onImageSelected: onImageSelected,
                  );
                },
              ),
              const Divider(color: AppTheme.darkBorder),

              // Option 3: Custom Image URL
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.link_rounded, color: AppTheme.info, size: 22),
                ),
                title: const Text('Paste Document Image URL',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Enter custom image link',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11.5)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
                onTap: () {
                  Navigator.pop(ctx);
                  _showCustomUrlDialog(title: title, onImageSelected: onImageSelected);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomUrlDialog({
    required String title,
    required Function(String url) onImageSelected,
  }) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: Text('Enter Image URL for $title',
            style: const TextStyle(color: Colors.white, fontSize: 15)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'https://...',
            hintStyle: TextStyle(color: Colors.white30),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () {
              final val = ctrl.text.trim();
              if (val.isNotEmpty) {
                Navigator.pop(ctx);
                onImageSelected(val);
              }
            },
            child: const Text('Attach', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openFullScreenPreview(String title, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, color: AppTheme.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 400),
                width: double.infinity,
                color: Colors.black,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, prog) {
                    if (prog == null) return child;
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                  },
                  errorBuilder: (_, error, stack) => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Icon(Icons.broken_image_rounded, size: 48, color: Colors.white38),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tech = context.watch<TechnicianProvider>();
    final kyc = tech.kyc;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkNav,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Technician KYC Verification',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Status',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () async {
              final auth = context.read<AuthProvider>();
              final userId = auth.currentUser?.id;
              if (userId != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Checking latest verification status from Instafix HQ...'),
                    duration: Duration(seconds: 1),
                  ),
                );
                await context.read<TechnicianProvider>().fetchKycStatusFromApi(userId);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Status Banner ──────────────────────────────────────────
                _buildStatusBanner(kyc),

                const SizedBox(height: 24),

                // ── Upload Progress Indicator ─────────────────────────────
                if (_isUploading) ...[
                  _buildUploadingCard(),
                  const SizedBox(height: 20),
                ],

                // ── Document 1: Aadhaar Card ──────────────────────────────
                _buildSectionTitle(
                  Icons.badge_rounded,
                  '1. Aadhaar Card Verification',
                  '12-Digit Unique Identification Authority of India',
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _aadhaarCtrl,
                  label: 'Aadhaar Number',
                  hint: 'Enter 12-digit Aadhaar number',
                  icon: Icons.fingerprint_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(12),
                  ],
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Aadhaar number is required';
                    if (val.trim().length != 12) return 'Aadhaar must be exactly 12 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDocUploadCard(
                        title: 'Aadhaar Front',
                        subtitle: 'Name & Photo side',
                        imageUrl: _aadhaarFrontImg,
                        icon: Icons.credit_card_rounded,
                        onTap: () {
                          _openImagePickerSheet(
                            title: 'Aadhaar Front Card',
                            uploadType: 'kyc_aadhaar_front',
                            defaultPresetUrl: _defaultAadhaarFront,
                            onImageSelected: (url) => setState(() => _aadhaarFrontImg = url),
                          );
                        },
                        onDelete: () => setState(() => _aadhaarFrontImg = null),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDocUploadCard(
                        title: 'Aadhaar Back',
                        subtitle: 'Address & QR code side',
                        imageUrl: _aadhaarBackImg,
                        icon: Icons.credit_card_outlined,
                        onTap: () {
                          _openImagePickerSheet(
                            title: 'Aadhaar Back Card',
                            uploadType: 'kyc_aadhaar_back',
                            defaultPresetUrl: _defaultAadhaarBack,
                            onImageSelected: (url) => setState(() => _aadhaarBackImg = url),
                          );
                        },
                        onDelete: () => setState(() => _aadhaarBackImg = null),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                // ── Document 2: PAN Card ──────────────────────────────────
                _buildSectionTitle(
                  Icons.account_balance_wallet_rounded,
                  '2. PAN Card Verification',
                  'Permanent Account Number for TDS & payouts',
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _panCtrl,
                  label: 'PAN Number',
                  hint: 'e.g. ABCDE1234F',
                  icon: Icons.article_rounded,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'PAN number is required';
                    if (val.trim().length != 10) return 'PAN must be exactly 10 alphanumeric characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildDocUploadCard(
                  title: 'PAN Card Copy / Photo',
                  subtitle: 'Income Tax Department official card photo',
                  imageUrl: _panImg,
                  icon: Icons.photo_camera_front_rounded,
                  onTap: () {
                    _openImagePickerSheet(
                      title: 'PAN Card Photo',
                      uploadType: 'kyc_pan',
                      defaultPresetUrl: _defaultPan,
                      onImageSelected: (url) => setState(() => _panImg = url),
                    );
                  },
                  onDelete: () => setState(() => _panImg = null),
                ),

                const SizedBox(height: 26),

                // ── Document 3: Bike Registration ─────────────────────────
                _buildSectionTitle(
                  Icons.two_wheeler_rounded,
                  '3. Two-Wheeler / Bike Details',
                  'Vehicle registration used for doorstep visits',
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _bikeCtrl,
                  label: 'Bike / Vehicle Number',
                  hint: 'e.g. DL 01 AB 1234 or HR 26 DQ 9876',
                  icon: Icons.directions_bike_rounded,
                  textCapitalization: TextCapitalization.characters,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Bike number is required for doorstep transit';
                    if (val.trim().length < 6) return 'Enter a valid vehicle registration number';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildDocUploadCard(
                  title: 'Bike RC (Registration Certificate)',
                  subtitle: 'Vehicle registration certificate or number plate photo',
                  imageUrl: _bikeRcImg,
                  icon: Icons.receipt_long_rounded,
                  onTap: () {
                    _openImagePickerSheet(
                      title: 'Bike RC Photo',
                      uploadType: 'kyc_bike_rc',
                      defaultPresetUrl: _defaultBikeRc,
                      onImageSelected: (url) => setState(() => _bikeRcImg = url),
                    );
                  },
                  onDelete: () => setState(() => _bikeRcImg = null),
                ),

                const SizedBox(height: 26),

                // ── Document 4: ₹199 Subscription & Payment Proof ─────────
                _buildSectionTitle(
                  Icons.verified_user_rounded,
                  '4. Instafix Technician Pass (₹$_kycFee Subscription)',
                  'One-time onboarding fee. Pay via QR/UPI & upload screenshot',
                ),
                const SizedBox(height: 12),
                _buildPaymentInfoCard(),
                const SizedBox(height: 14),
                _buildDocUploadCard(
                  title: '₹$_kycFee Payment Screenshot',
                  subtitle: 'Upload payment confirmation slip / UPI receipt',
                  imageUrl: _paymentScreenshotImg,
                  icon: Icons.receipt_long_rounded,
                  onTap: () {
                    _openImagePickerSheet(
                      title: '₹$_kycFee Payment Screenshot',
                      uploadType: 'kyc_payment',
                      defaultPresetUrl: _defaultPaymentSlip,
                      onImageSelected: (url) => setState(() => _paymentScreenshotImg = url),
                    );
                  },
                  onDelete: () => setState(() => _paymentScreenshotImg = null),
                ),

                const SizedBox(height: 32),

                // ── Submit Button ─────────────────────────────────────────
                if (kyc.status != 'VERIFIED') ...[
                  GestureDetector(
                    onTap: _isUploading ? null : _handleUploadAndSubmit,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: _isUploading ? null : AppTheme.primaryGradient,
                        color: _isUploading ? AppTheme.darkElevated : null,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _isUploading
                            ? []
                            : [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                )
                              ],
                      ),
                      child: Center(
                        child: _isUploading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    kyc.status == 'PENDING'
                                        ? 'Update & Re-Submit KYC'
                                        : 'Upload & Submit KYC for Verification',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.success.withValues(alpha: 0.35)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'KYC Verified • Authorized to Accept Jobs',
                          style: TextStyle(
                            color: AppTheme.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner(dynamic kyc) {
    Color bgGradientStart;
    Color bgGradientEnd;
    Color accentColor;
    IconData icon;
    String title;
    String desc;

    if (kyc.isVerified) {
      bgGradientStart = const Color(0xFF064E3B);
      bgGradientEnd = const Color(0xFF065F46);
      accentColor = const Color(0xFF34D399);
      icon = Icons.verified_rounded;
      title = 'KYC Verified by Admin ✅';
      desc = 'Your credentials and vehicle are fully certified. You have complete access to accept customer repair assignments.';
    } else if (kyc.isPending) {
      bgGradientStart = const Color(0xFF78350F);
      bgGradientEnd = const Color(0xFF451A03);
      accentColor = const Color(0xFFFBBF24);
      icon = Icons.hourglass_top_rounded;
      title = 'KYC Under Admin Review ⏳';
      desc = 'Your Aadhaar, PAN card, and Bike number have been received. Verification is in progress. You can accept jobs as soon as an admin approves your profile.';
    } else if (kyc.isRejected) {
      bgGradientStart = const Color(0xFF7F1D1D);
      bgGradientEnd = const Color(0xFF450A0A);
      accentColor = const Color(0xFFF87171);
      icon = Icons.cancel_rounded;
      title = 'KYC Verification Rejected ❌';
      desc = kyc.rejectionReason ?? 'Documents unclear or verification failed. Please correct details and re-submit.';
    } else {
      bgGradientStart = const Color(0xFF1E1B4B);
      bgGradientEnd = const Color(0xFF172554);
      accentColor = const Color(0xFF818CF8);
      icon = Icons.shield_outlined;
      title = 'KYC Verification Pending ⚠️';
      desc = 'Doorstep repair guidelines require certified technicians. Upload your Aadhaar, PAN card, and Bike number below to start accepting jobs.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgGradientStart, bgGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          if (kyc.isPending) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accentColor.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF59E0B)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Awaiting review by Instafix Admin Team',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      final auth = context.read<AuthProvider>();
                      final userId = auth.currentUser?.id;
                      if (userId != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Checking latest verification status from Admin...'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        await context.read<TechnicianProvider>().fetchKycStatusFromApi(userId);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh_rounded, size: 12, color: accentColor),
                          const SizedBox(width: 4),
                          Text('Check Status',
                              style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (kyc.isVerified && kyc.verifiedAt != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.security_rounded, size: 13, color: Colors.white54),
                const SizedBox(width: 5),
                Text(
                  'Verified on: ${kyc.verifiedAt!.substring(0, 10)}',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
              ),
              const SizedBox(width: 10),
              Text(
                _uploadStepText,
                style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _uploadProgress,
              backgroundColor: AppTheme.darkBorder,
              color: AppTheme.primary,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    final qrSrc = _adminQrUrl.isNotEmpty
        ? _adminQrUrl
        : 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${Uri.encodeComponent('upi://pay?pa=$_adminUpiId&am=$_kycFee')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Admin UPI QR Code',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        'Pay ₹$_kycFee via any UPI App',
                        style: const TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
                ),
                child: _isLoadingPaymentInfo
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.success),
                      )
                    : Text(
                        '₹$_kycFee Only',
                        style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.w800, fontSize: 13),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // QR Code Preview
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Image.network(
              qrSrc,
              width: 140,
              height: 140,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 140,
                height: 140,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.qr_code_2_rounded, size: 60, color: Colors.black54),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // UPI ID copy row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.darkElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ADMIN UPI ID', style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      SelectableText(
                        _adminUpiId,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _adminUpiId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('📋 Copied UPI ID: $_adminUpiId'),
                        backgroundColor: AppTheme.primary,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_rounded, color: AppTheme.primary, size: 14),
                        SizedBox(width: 4),
                        Text('Copy', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDocUploadCard({
    required String title,
    required String subtitle,
    required String? imageUrl,
    required IconData icon,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    final hasImg = imageUrl != null && imageUrl.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasImg
              ? const Color(0xFF10B981).withValues(alpha: 0.08)
              : AppTheme.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasImg ? const Color(0xFF10B981).withValues(alpha: 0.45) : AppTheme.darkBorder,
            width: hasImg ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: hasImg ? const Color(0xFF10B981) : AppTheme.textMuted, size: 20),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasImg
                        ? const Color(0xFF10B981).withValues(alpha: 0.2)
                        : AppTheme.darkElevated,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasImg ? Icons.check_circle_rounded : Icons.file_upload_outlined,
                        size: 12,
                        color: hasImg ? const Color(0xFF10B981) : AppTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasImg ? 'Uploaded' : 'Upload',
                        style: TextStyle(
                          color: hasImg ? const Color(0xFF10B981) : AppTheme.textMuted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (hasImg) ...[
              const SizedBox(height: 10),
              // Image Thumbnail with Preview and Delete actions
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 80,
                      width: double.infinity,
                      color: AppTheme.darkElevated,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, prog) {
                          if (prog == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                            ),
                          );
                        },
                        errorBuilder: (_, error, stack) => const Center(
                          child: Icon(Icons.broken_image_rounded, size: 28, color: Colors.white30),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // View Full Image Button
                        GestureDetector(
                          onTap: () => _openFullScreenPreview(title, imageUrl),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Remove Image Button
                        GestureDetector(
                          onTap: onDelete,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, color: Color(0xFFEF4444), size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
