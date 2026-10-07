import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/booking_provider.dart';
import '../../providers/technician_provider.dart';
import '../../models/booking.dart';

class PostQcScreen extends StatefulWidget {
  final Booking booking;
  const PostQcScreen({super.key, required this.booking});

  @override
  State<PostQcScreen> createState() => _PostQcScreenState();
}

class _PostQcScreenState extends State<PostQcScreen> {
  final Map<String, bool> _postChecks = {
    'Display Quality & Color': true,
    'Touch Sensitivity & Multi-Touch': true,
    'Ear Speaker & Mic Clarity': true,
    'Front & Rear Camera Focus': true,
    'Fast Charging Speed': true,
    'Device Cleaned & Polished': true,
  };

  final TextEditingController _postNotesController = TextEditingController(
    text:
        'Repair completed cleanly. Display tested with diagnostic pattern grid. All functions 100% operational.',
  );

  @override
  void dispose() {
    _postNotesController.dispose();
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
        title: const Text('Post-Repair Quality Check',
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
                    const Text('Final Quality Checklist',
                        style: TextStyle(
                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text(
                        'Verify all hardware tests pass before handing device to customer.',
                        style: TextStyle(color: Colors.white38, fontSize: 13)),
                    const SizedBox(height: 14),

                    ...(_postChecks.entries.map((entry) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: entry.value
                              ? AppTheme.success.withValues(alpha: 0.08)
                              : AppTheme.darkSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: entry.value
                                ? AppTheme.success.withValues(alpha: 0.4)
                                : AppTheme.darkBorder,
                          ),
                        ),
                        child: CheckboxListTile(
                          activeColor: AppTheme.success,
                          checkColor: Colors.white,
                          side: const BorderSide(color: Colors.white38),
                          title: Text(
                            entry.key,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white),
                          ),
                          subtitle: const Text('Verified by Technician',
                              style: TextStyle(color: Colors.white38, fontSize: 12)),
                          value: entry.value,
                          onChanged: (val) =>
                              setState(() => _postChecks[entry.key] = val ?? false),
                        ),
                      );
                    })),

                    const SizedBox(height: 24),

                    const Text('Completion Notes',
                        style: TextStyle(
                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    TextField(
                      controller: _postNotesController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter final handover notes...',
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
                    backgroundColor: AppTheme.success,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    techProvider.submitPostQC(
                      bookingProvider: bookingProvider,
                      booking: widget.booking,
                      postChecks: _postChecks,
                      postNotes: _postNotesController.text,
                      postPhotos: [],
                    );
                    Navigator.popUntil(context, (route) => route.isFirst);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Repair Completed! Invoice & Warranty generated successfully.'),
                        backgroundColor: AppTheme.success,
                      ),
                    );
                  },
                  child: const Text('Complete Job & Issue Digital Invoice',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
