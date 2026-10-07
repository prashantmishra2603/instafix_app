import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/booking_provider.dart';
import '../../providers/technician_provider.dart';
import '../../models/booking.dart';

class PreInspectionScreen extends StatefulWidget {
  final Booking booking;
  const PreInspectionScreen({super.key, required this.booking});

  @override
  State<PreInspectionScreen> createState() => _PreInspectionScreenState();
}

class _PreInspectionScreenState extends State<PreInspectionScreen> {
  final Map<String, bool> _checks = {
    'Display OLED': true,
    'Touch Sensitivity': true,
    'Battery Health': true,
    'Front & Rear Camera': true,
    'Ear Speaker': true,
    'Microphone': true,
    'Wi-Fi & Bluetooth': true,
    'Charging Port': true,
    'Physical Buttons': true,
    'Flashlight': true,
  };

  final TextEditingController _notesController = TextEditingController(
    text: 'Pre-check completed. Screen glass shattered top corner, touch digitizer operational.',
  );

  bool _hasAdditionalWork = false;
  final TextEditingController _extraTitleController =
      TextEditingController(text: 'Display Ribbon Connector Pin Damage');
  final TextEditingController _extraDescController = TextEditingController(
      text: 'Corrosion on display flex cable pin assembly requires flex replacement.');
  final TextEditingController _extraAmountController = TextEditingController(text: '799');

  @override
  void dispose() {
    _notesController.dispose();
    _extraTitleController.dispose();
    _extraDescController.dispose();
    _extraAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final techProvider = Provider.of<TechnicianProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkNav,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Pre-Repair Inspection',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('10-Point Hardware Checklist',
                        style: TextStyle(
                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Tap to toggle pass/fail for each component.',
                        style: TextStyle(color: Colors.white38, fontSize: 13)),
                    const SizedBox(height: 14),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _checks.length,
                      itemBuilder: (context, index) {
                        final key = _checks.keys.elementAt(index);
                        final val = _checks[key]!;
                        return GestureDetector(
                          onTap: () => setState(() => _checks[key] = !val),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: val
                                  ? AppTheme.success.withValues(alpha: 0.1)
                                  : AppTheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: val
                                    ? AppTheme.success.withValues(alpha: 0.5)
                                    : AppTheme.error.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  val ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                  color: val ? AppTheme.success : AppTheme.error,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    key,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: val ? Colors.white70 : AppTheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    const Text('Technician Pre-Notes',
                        style: TextStyle(
                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter observation details before repair...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: AppTheme.darkSurface,
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
                    ),

                    const SizedBox(height: 24),

                    // Additional Work Toggle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _hasAdditionalWork
                            ? AppTheme.warning.withValues(alpha: 0.08)
                            : AppTheme.darkSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _hasAdditionalWork
                              ? AppTheme.warning.withValues(alpha: 0.4)
                              : AppTheme.darkBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _hasAdditionalWork,
                                activeColor: AppTheme.primary,
                                checkColor: Colors.white,
                                side: const BorderSide(color: Colors.white38),
                                onChanged: (val) =>
                                    setState(() => _hasAdditionalWork = val ?? false),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(
                                      () => _hasAdditionalWork = !_hasAdditionalWork),
                                  child: const Text(
                                    'Found Additional Issue / Extra Cost?',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_hasAdditionalWork) ...[
                            const SizedBox(height: 12),
                            _darkField(_extraTitleController, 'Additional Repair Title',
                                'e.g. Ribbon cable damage'),
                            const SizedBox(height: 10),
                            _darkField(_extraDescController, 'Explanation for Customer',
                                'Explain why extra repair is needed...', maxLines: 2),
                            const SizedBox(height: 10),
                            _darkField(_extraAmountController, 'Additional Cost (₹)',
                                'Enter amount',
                                keyboardType: TextInputType.number, prefix: '₹ '),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.darkNav,
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    double? extraAmt;
                    if (_hasAdditionalWork && _extraAmountController.text.isNotEmpty) {
                      extraAmt = double.tryParse(_extraAmountController.text);
                    }
                    techProvider.submitPreDiagnosis(
                      bookingProvider: bookingProvider,
                      booking: widget.booking,
                      checks: _checks,
                      notes: _notesController.text,
                      photos: [],
                      extraTitle: _hasAdditionalWork ? _extraTitleController.text : null,
                      extraDesc: _hasAdditionalWork ? _extraDescController.text : null,
                      extraCost: extraAmt,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_hasAdditionalWork
                            ? 'Pre-check saved! Approval request sent to customer.'
                            : 'Pre-check completed! Proceeding with repair.'),
                        backgroundColor: AppTheme.success,
                      ),
                    );
                  },
                  child: const Text('Submit Pre-Inspection Record',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _darkField(
    TextEditingController controller,
    String label,
    String hint, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? prefix,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        prefixText: prefix,
        prefixStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: AppTheme.darkBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
      ),
    );
  }
}
