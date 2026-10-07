import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking.dart';

class CustomerApprovalScreen extends StatelessWidget {
  final Booking booking;

  const CustomerApprovalScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final diag = booking.diagnostic;
    final extraAmount = diag?.additionalAmount ?? 799.0;
    final extraTitle = diag?.additionalTitle ?? 'Internal Display Flex Cable Damage';
    final extraDesc = diag?.additionalDescription ?? 'During initial teardown, torn display flex connector pins were discovered caused by previous impact.';

    double revisedTotal = booking.estimateAmount + extraAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Extra Work Approval'),
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
                    // Warning Alert Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.report_problem_rounded, color: Color(0xFFD97706), size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Technician Pre-Check Finding',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF92400E)),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Your approval is required before technician proceeds with additional repair.',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Additional Issue Details
                    Text(
                      'Additional Issue Found',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  extraTitle,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              Text(
                                '+ ₹${extraAmount.toInt()}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            extraDesc,
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Inspection Photos Evidence
                    Text(
                      'Diagnostic Evidence Photos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 10),

                    SizedBox(
                      height: 130,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildPhotoCard('https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=400', 'Glass Crack'),
                          const SizedBox(width: 12),
                          _buildPhotoCard('https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=400', 'Flex Pin Inspection'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Revised Price Comparison
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildPriceRow('Original Booking Estimate', '₹${booking.estimateAmount.toInt()}', isLight: true),
                          const SizedBox(height: 8),
                          _buildPriceRow('Additional Repair Work', '+ ₹${extraAmount.toInt()}', isLight: true, accentColor: const Color(0xFFFCD34D)),
                          const Divider(color: Colors.white24, height: 24),
                          _buildPriceRow('Revised Total Payable', '₹${revisedTotal.toInt()}', isBold: true, isLight: true, fontSize: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Approval CTAs
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        side: const BorderSide(color: AppTheme.error),
                      ),
                      onPressed: () {
                        bookingProvider.respondToApproval(booking.id, false);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Extra work declined. Proceeding with original repair.')),
                        );
                      },
                      child: const Text('Decline Extra'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                      ),
                      onPressed: () {
                        bookingProvider.respondToApproval(booking.id, true);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Additional work approved! Technician notified.'),
                            backgroundColor: AppTheme.success,
                          ),
                        );
                      },
                      child: const Text('Approve Repair'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(String url, String label) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
      ),
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String title, String val, {bool isLight = false, bool isBold = false, double fontSize = 14, Color? accentColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isLight ? Colors.white70 : AppTheme.textMuted,
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          val,
          style: TextStyle(
            color: accentColor ?? (isLight ? Colors.white : AppTheme.textDark),
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

