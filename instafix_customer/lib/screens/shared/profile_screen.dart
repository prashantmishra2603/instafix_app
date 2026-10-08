import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        _nameCtrl.text = user.name;
        _addressCtrl.text = user.address ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(AuthProvider authProvider) async {
    setState(() => _isEditing = false);
    final success = await authProvider.updateProfile({
      'name': _nameCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Profile updated successfully!' : 'Failed to update profile.'),
          backgroundColor: success ? AppTheme.success : AppTheme.error,
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check_rounded : Icons.edit_rounded, color: AppTheme.primary),
            onPressed: () {
              if (_isEditing) {
                _saveProfile(authProvider);
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Profile Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppTheme.primaryLight,
                      child: const Icon(Icons.person_rounded, size: 36, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _isEditing
                              ? TextField(
                                  controller: _nameCtrl,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    hintText: 'Full Name',
                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                  ),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                )
                              : Text(
                                  user?.name ?? 'User',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (user?.role ?? 'Customer').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Read-only Details
              _buildReadOnlyField('Phone Number', user?.phone ?? '+91 98219 73355', Icons.phone_rounded),
              if (user?.email != null && user!.email!.isNotEmpty)
                _buildReadOnlyField('Email Address', user.email!, Icons.email_rounded),
              
              const SizedBox(height: 16),
              
              // Address Field (Editable)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text('Doorstep Address', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  ),
                  TextField(
                    controller: _addressCtrl,
                    enabled: _isEditing,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Enter your full address',
                      prefixIcon: const Icon(Icons.location_on_rounded, color: AppTheme.textMuted),
                      filled: true,
                      fillColor: _isEditing ? AppTheme.surface : AppTheme.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.border),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Menu List
              _buildMenuItem(context, Icons.payment_outlined, 'Payment & EMI Options'),
              _buildMenuItem(context, Icons.help_outline_rounded, 'Instafix Support & FAQs'),
              _buildMenuItem(context, Icons.description_outlined, 'Terms & Privacy Policy'),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    side: const BorderSide(color: AppTheme.error),
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
                  label: const Text('Logout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          ),
          TextField(
            controller: TextEditingController(text: value),
            readOnly: true,
            enabled: false,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppTheme.textMuted),
              filled: true,
              fillColor: AppTheme.background,
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.border.withValues(alpha: 0.5)),
              ),
            ),
            style: const TextStyle(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SettingsDetailScreen(title: title)),
          );
        },
      ),
    );
  }
}

class SettingsDetailScreen extends StatelessWidget {
  final String title;
  
  const SettingsDetailScreen({super.key, required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (title) {
      case 'Payment & EMI Options':
        return _buildPaymentEmiPage(context);
      case 'Instafix Support & FAQs':
        return _buildSupportPage(context);
      case 'Terms & Privacy Policy':
        return _buildTermsPage(context);
      default:
        return Center(child: Text('Coming Soon', style: TextStyle(color: AppTheme.textDark)));
    }
  }

  Widget _buildPaymentEmiPage(BuildContext context) {
    return const PaymentEmiPage();
  }

  Widget _buildSupportPage(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceHigh,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Need Help with a Repair?', style: TextStyle(color: AppTheme.textDark, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Our support team is here to assist you 24/7.', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                        onPressed: () {},
                        icon: const Icon(Icons.chat_rounded, size: 18),
                        label: const Text('Chat Now'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.call_rounded, size: 18),
                        label: const Text('Call Us'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Frequently Asked Questions', style: TextStyle(color: AppTheme.textDark, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _faqTile('How long does a repair take?', 'Most smartphone repairs take 30-45 minutes. Complex motherboard issues may take 2-3 hours.'),
          _faqTile('Are the replacement parts original?', 'We offer both 100% Genuine OEM parts and high-quality compatible parts. You can choose during booking.'),
          _faqTile('What is covered under the 6-month warranty?', 'The warranty covers any defects in the replaced part. It does not cover accidental damage or liquid damage after the repair.'),
          _faqTile('Can I reschedule my booking?', 'Yes, you can reschedule up to 2 hours before the technician\'s arrival time without any penalty.'),
        ],
      ),
    );
  }

  Widget _buildTermsPage(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _termsBlock('1. Service Agreement', 'By booking a repair with InstaFix, you agree to our standard terms of service. Our technicians will inspect the device before repair and inform you of any additional issues found.'),
          _termsBlock('2. Data Privacy & Safety', 'Your data is 100% safe. We recommend taking a backup before the repair. Our technicians follow a strict no-data-access policy during screen or battery replacements.'),
          _termsBlock('3. Cancellation Policy', 'Cancellations made within 2 hours of the scheduled time may incur a nominal fee of ₹150 to compensate the technician\'s travel time.'),
          _termsBlock('4. Warranty Terms', 'InstaFix Shield provides a 6-month warranty on parts and a 30-day warranty on workmanship. Warranty is void if the device shows physical damage after repair.'),
        ],
      ),
    );
  }

  Widget _faqTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(color: AppTheme.textDark, fontSize: 14, fontWeight: FontWeight.w600)),
        iconColor: AppTheme.primary,
        collapsedIconColor: AppTheme.textMuted,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(answer, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  Widget _termsBlock(String title, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.textDark, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}

class PaymentEmiPage extends StatefulWidget {
  const PaymentEmiPage({super.key});
  @override
  State<PaymentEmiPage> createState() => _PaymentEmiPageState();
}

class _PaymentEmiPageState extends State<PaymentEmiPage> {
  final List<Map<String, dynamic>> _savedCards = [];
  final List<Map<String, dynamic>> _upiIds = [];

  void _showAddDialog(String type) {
    final titleCtrl = TextEditingController();
    final detailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New ${type == 'card' ? 'Card' : 'UPI ID'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                hintText: type == 'card' ? 'Bank Name (e.g. HDFC)' : 'App Name (e.g. GPay)',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: detailCtrl,
              decoration: InputDecoration(
                hintText: type == 'card' ? 'Card Number (last 4 digits)' : 'UPI ID (e.g. name@upi)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty && detailCtrl.text.isNotEmpty) {
                setState(() {
                  if (type == 'card') {
                    _savedCards.add({'title': titleCtrl.text, 'subtitle': detailCtrl.text});
                  } else {
                    _upiIds.add({'title': titleCtrl.text, 'subtitle': detailCtrl.text});
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(String type, int index) {
    final isCard = type == 'card';
    final currentList = isCard ? _savedCards : _upiIds;
    final titleCtrl = TextEditingController(text: currentList[index]['title']);
    final detailCtrl = TextEditingController(text: currentList[index]['subtitle']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${isCard ? 'Card' : 'UPI ID'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl),
            const SizedBox(height: 10),
            TextField(controller: detailCtrl),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty && detailCtrl.text.isNotEmpty) {
                setState(() {
                  currentList[index] = {'title': titleCtrl.text, 'subtitle': detailCtrl.text};
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionCard(
            title: 'Saved Cards',
            icon: Icons.credit_card_rounded,
            color: AppTheme.primary,
            children: [
              if (_savedCards.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text('No saved cards.', style: TextStyle(color: AppTheme.textMuted)),
                ),
              ..._savedCards.asMap().entries.map((e) => _paymentMethodTile(
                    'card',
                    e.key,
                    Icons.credit_card_rounded,
                    e.value['title'],
                    e.value['subtitle'],
                  )),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => _showAddDialog('card'),
                icon: const Icon(Icons.add_rounded, color: AppTheme.primary),
                label: const Text('Add New Card', style: TextStyle(color: AppTheme.primary)),
              )
            ],
          ),
          const SizedBox(height: 20),
          _sectionCard(
            title: 'UPI IDs',
            icon: Icons.qr_code_rounded,
            color: AppTheme.success,
            children: [
              if (_upiIds.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text('No saved UPI IDs.', style: TextStyle(color: AppTheme.textMuted)),
                ),
              ..._upiIds.asMap().entries.map((e) => _paymentMethodTile(
                    'upi',
                    e.key,
                    Icons.account_balance_wallet_rounded,
                    e.value['title'],
                    e.value['subtitle'],
                  )),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => _showAddDialog('upi'),
                icon: const Icon(Icons.add_rounded, color: AppTheme.primary),
                label: const Text('Add New UPI ID', style: TextStyle(color: AppTheme.primary)),
              )
            ],
          ),
          const SizedBox(height: 20),
          _sectionCard(
            title: 'EMI Eligibility',
            icon: Icons.percent_rounded,
            color: AppTheme.warning,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppTheme.warning, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text('Add a card to check your pre-approved EMI offers.', style: TextStyle(color: AppTheme.warning, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required IconData icon, required Color color, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(color: AppTheme.textDark, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodTile(String type, int index, IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceHigh,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.textMuted, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.textDark, fontSize: 14, fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primary, size: 20),
            onPressed: () => _showEditDialog(type, index),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 20),
            onPressed: () {
              setState(() {
                if (type == 'card') {
                  _savedCards.removeAt(index);
                } else {
                  _upiIds.removeAt(index);
                }
              });
            },
          ),
        ],
      ),
    );
  }
}

