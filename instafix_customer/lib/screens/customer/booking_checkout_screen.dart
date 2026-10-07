import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import 'booking_tracking_screen.dart';

class BookingCheckoutScreen extends StatefulWidget {
  const BookingCheckoutScreen({super.key});
  @override
  State<BookingCheckoutScreen> createState() => _BookingCheckoutScreenState();
}

class _BookingCheckoutScreenState extends State<BookingCheckoutScreen> {
  final _addressCtrl = TextEditingController();
  String _selectedSlot = 'Today, 2:30 PM - 4:00 PM';
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user?.address != null && user!.address!.isNotEmpty) {
        _addressCtrl.text = user.address!;
        Provider.of<BookingProvider>(context, listen: false).setAddress(user.address!);
      }
    });
  }

  @override
  void dispose() { _addressCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final bp = Provider.of<BookingProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Address
                const Text('Doorstep Address',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const SizedBox(height: 10),
                TextField(
                  controller: _addressCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: AppTheme.textDark),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_on_rounded, color: AppTheme.primary),
                    hintText: 'Enter complete doorstep address...',
                  ),
                  onChanged: (v) => bp.setAddress(v),
                ),

                const SizedBox(height: 24),

                // Time Slot
                const Text('Select Preferred Time Slot',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const SizedBox(height: 12),

                ...['Today, 2:30 PM - 4:00 PM', 'Today, 5:00 PM - 6:30 PM',
                    'Tomorrow, 10:00 AM - 11:30 AM', 'Tomorrow, 2:00 PM - 3:30 PM'].map((slot) {
                  final sel = _selectedSlot == slot;
                  return GestureDetector(
                    onTap: () { setState(() => _selectedSlot = slot); bp.setSlot(slot); },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: sel ? AppTheme.primaryLight : AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: sel ? AppTheme.primary : AppTheme.border, width: sel ? 2 : 1),
                      ),
                      child: Row(children: [
                        Icon(Icons.access_time_filled_rounded,
                            color: sel ? AppTheme.primary : AppTheme.textMuted, size: 20),
                        const SizedBox(width: 12),
                        Text(slot, style: TextStyle(
                            fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                            color: AppTheme.textDark)),
                        const Spacer(),
                        if (sel) const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 20),
                      ]),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Summary Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Repair Summary',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark)),
                    const Divider(height: 24, color: AppTheme.border),
                    _row('Device', '${bp.selectedBrand?.name ?? ''} ${bp.selectedModel?.name ?? ''}'),
                    const SizedBox(height: 10),
                    _row('Service', bp.selectedService?.name ?? ''),
                    const SizedBox(height: 10),
                    _row('Part', bp.selectedPartOption?.name ?? ''),
                    const SizedBox(height: 10),
                    _row('Warranty', '${bp.selectedPartOption?.warrantyPeriod ?? ''} Warranty', hi: true),
                    const Divider(height: 24, color: AppTheme.border),
                    _row('Service Cost', '₹${bp.totalPrice.toInt()}'),
                    const SizedBox(height: 8),
                    _row('Doorstep Fee', 'FREE', hi: true),
                    const SizedBox(height: 8),
                    _row('Taxes', 'Included'),
                    const Divider(height: 24, color: AppTheme.border),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Total Payable',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark)),
                      Text('₹${bp.totalPrice.toInt()}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primary)),
                    ]),
                  ]),
                ),
              ]),
            ),
          ),

          // CTA
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(top: BorderSide(color: AppTheme.border)),
            ),
            child: SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                onPressed: _isConfirming ? null : _confirm,
                child: _isConfirming
                    ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)),
                        SizedBox(width: 10),
                        Text('Confirming...', style: TextStyle(color: Colors.white)),
                      ])
                    : const Text('Confirm Doorstep Booking',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _confirm() async {
    final bp   = Provider.of<BookingProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (_addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your doorstep address')));
      return;
    }

    // Capture navigator BEFORE the async gap.
    final navigator = Navigator.of(context);

    setState(() => _isConfirming = true);
    final booking = await bp.createBooking(
      customerName: auth.currentUser?.name,
      customerPhone: auth.currentUser?.phone,
      customerId: auth.currentUser?.id,
      customerAddress: _addressCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isConfirming = false);

    // Navigate and pass the booking number so the tracking screen can show
    // the confirmation snackbar from its OWN scaffold (avoids deactivated-
    // ancestor crash that happens when showing a snackbar then navigating).
    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (_) => BookingTrackingScreen(
          confirmedBookingNumber: booking.bookingNumber,
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool hi = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
      Flexible(child: Text(value, textAlign: TextAlign.end,
          style: TextStyle(fontSize: 13,
              fontWeight: hi ? FontWeight.bold : FontWeight.w600,
              color: hi ? AppTheme.success : AppTheme.textDark))),
    ]),
  );
}
