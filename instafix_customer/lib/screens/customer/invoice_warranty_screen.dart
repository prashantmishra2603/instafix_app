import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking.dart';
import '../../models/warranty.dart';

class InvoiceWarrantyScreen extends StatelessWidget {
  final Booking? booking;
  const InvoiceWarrantyScreen({super.key, this.booking});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final bookingProvider = Provider.of<BookingProvider>(context);
    final warranties = bookingProvider.getWarrantiesForUser(user);

    // Use the passed booking or find the first completed booking
    final b = booking ?? 
      bookingProvider.bookings.firstWhere(
        (bk) => bk.status == 'COMPLETED',
        orElse: () => bookingProvider.bookings.isNotEmpty ? bookingProvider.bookings.first : Booking(
          id: 0,
          bookingNumber: 'N/A',
          customerId: 0,
          customerName: 'Customer',
          customerPhone: '',
          deviceCategory: '',
          brandName: 'N/A',
          modelName: 'N/A',
          serviceName: 'N/A',
          partOptionName: '',
          addressLine: '',
          scheduledSlot: '',
          status: 'COMPLETED',
          estimateAmount: 0.0,
          finalAmount: 0.0,
          paymentStatus: 'PAID',
          createdAt: '',
        ),
      );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Invoice & Warranties'),
          bottom: const TabBar(
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textMuted,
            indicatorColor: AppTheme.primary,
            tabs: [
              Tab(text: 'Active Warranties'),
              Tab(text: 'Digital Invoice'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: WARRANTIES
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Protection Cards',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 14),

                  if (warranties.isEmpty) ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No active warranties yet.'),
                      ),
                    ),
                  ] else ...[
                    ...warranties.map((w) => _buildWarrantyCard(context, bookingProvider, w)),
                  ],

                  if (bookingProvider.warrantyClaims.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text(
                      'Filed Warranty Claims',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    ...bookingProvider.warrantyClaims.map((claim) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shield_outlined, color: AppTheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    claim.description,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text('Filed: ${claim.createdAt}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                claim.status.toUpperCase(),
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),

            // TAB 2: DIGITAL INVOICE
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'INSTAFIX INVOICE',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary),
                            ),
                            const SizedBox(height: 2),
                            Text('Invoice #${b.bookingNumber}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.success),
                          ),
                          child: const Text(
                            'PAID IN FULL',
                            style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 32),

                    _buildInvoiceRow('Customer', b.customerName.isNotEmpty ? b.customerName : 'Customer'),
                    const SizedBox(height: 8),
                    _buildInvoiceRow('Device', '${b.brandName} ${b.modelName}'),
                    const SizedBox(height: 8),
                    _buildInvoiceRow('Date', b.createdAt.isNotEmpty ? b.createdAt : 'Today'),
                    const SizedBox(height: 8),
                    _buildInvoiceRow('Technician', b.technicianName?.isNotEmpty == true ? b.technicianName! : 'InstaFix Certified Tech'),

                    const Divider(height: 32),

                    const Text('Line Items Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),

                    _buildLineItem(b.serviceName, '₹${b.estimateAmount.toStringAsFixed(2)}'),
                    if ((b.additionalAmount ?? 0) > 0) ...[
                      const SizedBox(height: 8),
                      _buildLineItem('Additional Work', '₹${b.additionalAmount!.toStringAsFixed(2)}'),
                    ],
                    const SizedBox(height: 8),
                    _buildLineItem('Doorstep Convenience Fee', 'FREE'),
                    const SizedBox(height: 8),
                    _buildLineItem('GST (18%)', 'Included'),

                    const Divider(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          '₹${b.finalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppTheme.primary),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primary),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Downloading PDF Invoice...')),
                          );
                        },
                        icon: const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.primary),
                        label: const Text('Download PDF Copy'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarrantyCard(BuildContext context, BookingProvider bookingProvider, Warranty warranty) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'INSTAFIX SHIELD',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.success,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('ACTIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            warranty.deviceModelName,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            warranty.serviceName,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),

          const SizedBox(height: 20),

          // Days Remaining Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${warranty.daysRemaining} Days Remaining', style: const TextStyle(color: Color(0xFFFCD34D), fontWeight: FontWeight.bold, fontSize: 13)),
              Text('Valid till ${warranty.endDate}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: warranty.daysRemaining / 180.0,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.success),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 20),

          // Claim Warranty CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.secondary,
              ),
              onPressed: () => _showClaimDialog(context, bookingProvider, warranty),
              child: const Text('File Warranty Claim'),
            ),
          ),
        ],
      ),
    );
  }

  void _showClaimDialog(BuildContext context, BookingProvider bookingProvider, Warranty warranty) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('File Warranty Claim'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Device: ${warranty.deviceModelName}'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Describe the issue (e.g. Screen touch response issue...)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  bookingProvider.fileWarrantyClaim(warranty.id, controller.text.trim());
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Warranty claim submitted! Our team will contact you shortly.'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                }
              },
              child: const Text('Submit Claim'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInvoiceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
      ],
    );
  }

  Widget _buildLineItem(String item, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(item, style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
        Text(price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
      ],
    );
  }
}

