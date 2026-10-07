import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/booking_provider.dart';
import '../../services/mock_data_service.dart';
import 'booking_checkout_screen.dart';

class ServiceSelectionScreen extends StatelessWidget {
  const ServiceSelectionScreen({super.key});

  IconData _categoryIcon(String categoryId) {
    switch (categoryId) {
      case 'tablet':     return Icons.tablet_mac_rounded;
      case 'laptop':     return Icons.laptop_mac_rounded;
      case 'smartwatch': return Icons.watch_rounded;
      default:           return Icons.phone_iphone_rounded;
    }
  }

  IconData _serviceIcon(String iconName) {
    switch (iconName) {
      case 'battery_alert':        return Icons.battery_alert_rounded;
      case 'battery_charging_full': return Icons.battery_charging_full_rounded;
      case 'battery_full':         return Icons.battery_full_rounded;
      case 'battery_1_bar':        return Icons.battery_1_bar_rounded;
      case 'power':                return Icons.power_rounded;
      case 'camera_alt':           return Icons.camera_alt_rounded;
      case 'tablet_mac':           return Icons.tablet_mac_rounded;
      case 'tablet_android':       return Icons.tablet_android_rounded;
      case 'laptop':               return Icons.laptop_rounded;
      case 'laptop_mac':           return Icons.laptop_mac_rounded;
      case 'keyboard':             return Icons.keyboard_rounded;
      case 'watch':                return Icons.watch_rounded;
      case 'watch_later':          return Icons.watch_later_rounded;
      case 'settings':             return Icons.settings_rounded;
      case 'smartphone':           return Icons.smartphone_rounded;
      default:                     return Icons.build_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bp = Provider.of<BookingProvider>(context);
    final categoryId = bp.selectedCategory?.id ?? 'smartphone';
    final brandName  = bp.selectedBrand?.name ?? '';
    final modelName  = bp.selectedModel?.name ?? 'Device';
    final deviceLabel = brandName.isNotEmpty ? '$brandName $modelName' : modelName;
    final services   = MockDataService.services.where((s) => s.deviceCategory == categoryId).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Select Service & Part')),
      body: SafeArea(
        child: Column(
          children: [
            // ── Selected Device Header ─────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: AppTheme.surface,
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)),
                  child: Icon(_categoryIcon(categoryId), color: AppTheme.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  const Text('Selected Device', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  Text(deviceLabel,
                      style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis),
                ])),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Change', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                ),
              ]),
            ),
            const Divider(height: 1, color: AppTheme.border),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('What needs repair?',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                    const SizedBox(height: 4),
                    Text('${services.length} repair services available',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    const SizedBox(height: 16),

                    // ── Service List ───────────────────────────────────
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        final isSelected = bp.selectedService?.id == service.id;
                        return GestureDetector(
                          onTap: () => bp.selectService(service),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryLight : AppTheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppTheme.primary : AppTheme.border,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(color: AppTheme.primary.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))
                              ] : [],
                            ),
                            child: Row(children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.primary : AppTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(_serviceIcon(service.icon),
                                    color: isSelected ? Colors.white : AppTheme.primary),
                              ),
                              const SizedBox(width: 14),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(service.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark)),
                                const SizedBox(height: 4),
                                Text(service.description,
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                              ])),
                              Icon(
                                isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                              ),
                            ]),
                          ),
                        );
                      },
                    ),

                    // ── Part Options ───────────────────────────────────
                    if (bp.selectedService != null) ...[
                      const SizedBox(height: 24),
                      const Text('Select Part Quality & Warranty',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                      const SizedBox(height: 12),

                      ...bp.selectedService!.partOptions.map((part) {
                        final isPartSelected = bp.selectedPartOption?.id == part.id;
                        return GestureDetector(
                          onTap: () => bp.selectPartOption(part),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isPartSelected ? AppTheme.primaryLight : AppTheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isPartSelected ? AppTheme.primary : AppTheme.border,
                                width: isPartSelected ? 2 : 1,
                              ),
                              boxShadow: isPartSelected ? [
                                BoxShadow(color: AppTheme.primary.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))
                              ] : [],
                            ),
                            child: Row(children: [
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Flexible(child: Text(part.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark))),
                                  if (part.isPopular) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.warning.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text('POPULAR',
                                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.warning)),
                                    ),
                                  ],
                                ]),
                                const SizedBox(height: 6),
                                Row(children: [
                                  const Icon(Icons.verified_user_rounded, size: 14, color: AppTheme.success),
                                  const SizedBox(width: 4),
                                  Text('${part.warrantyPeriod} Warranty',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.success)),
                                ]),
                              ])),
                              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Text('₹${part.price.toInt()}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
                                const Text('Estimated', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                              ]),
                            ]),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),

            // ── Bottom CTA ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: const Border(top: BorderSide(color: AppTheme.border)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, -4))],
              ),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  const Text('Total Estimated', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  Text('₹${bp.totalPrice.toInt()}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                ]),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: bp.selectedService == null
                        ? null
                        : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingCheckoutScreen())),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('Proceed to Checkout', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                    ]),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
