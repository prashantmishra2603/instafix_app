import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/booking_provider.dart';
import '../../services/mock_data_service.dart';
import '../../models/device.dart';
import 'service_selection_screen.dart';

class DeviceSelectionScreen extends StatefulWidget {
  const DeviceSelectionScreen({super.key});

  @override
  State<DeviceSelectionScreen> createState() => _DeviceSelectionScreenState();
}

class _DeviceSelectionScreenState extends State<DeviceSelectionScreen> {
  final TextEditingController _customBrandController = TextEditingController();
  final TextEditingController _customModelController = TextEditingController();
  bool _isOtherBrandSelected = false;
  bool _isOtherModelSelected = false;
  final TextEditingController _otherModelController = TextEditingController();

  static const int _otherBrandId = 9999;
  static const int _otherModelId = 99999;

  @override
  void dispose() {
    _customBrandController.dispose();
    _customModelController.dispose();
    _otherModelController.dispose();
    super.dispose();
  }

  String? _brandLogoUrl(String brandName) => MockDataService.brandLogoUrls[brandName];

  IconData _modelIcon(String category) {
    switch (category) {
      case 'tablet':     return Icons.tablet_mac_rounded;
      case 'laptop':     return Icons.laptop_mac_rounded;
      case 'smartwatch': return Icons.watch_rounded;
      default:           return Icons.phone_iphone_rounded;
    }
  }

  IconData _categoryIcon(String categoryId) {
    switch (categoryId) {
      case 'tablet':     return Icons.tablet_mac_rounded;
      case 'laptop':     return Icons.laptop_mac_rounded;
      case 'smartwatch': return Icons.watch_rounded;
      default:           return Icons.phone_iphone_rounded;
    }
  }

  String _modelSubtitle(String categoryId) {
    switch (categoryId) {
      case 'tablet':     return 'Doorstep tablet repair service';
      case 'laptop':     return 'On-site laptop repair & parts';
      case 'smartwatch': return 'Smartwatch screen & battery fix';
      default:           return 'Doorstep repair in 30 mins';
    }
  }

  void _selectOtherBrand(BookingProvider bp, String categoryId) {
    setState(() { _isOtherBrandSelected = true; _isOtherModelSelected = false; });
    bp.selectBrand(Brand(id: _otherBrandId, category: categoryId, name: 'Other', logo: ''));
  }

  void _confirmOtherBrand(BuildContext context, BookingProvider bp, String categoryId) {
    final brand = _customBrandController.text.trim();
    final model = _customModelController.text.trim();
    if (brand.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter brand name')));
      return;
    }
    if (model.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter model name')));
      return;
    }
    FocusScope.of(context).unfocus();
    bp.selectBrand(Brand(id: _otherBrandId, category: categoryId, name: brand, logo: ''));
    bp.selectModel(DeviceModel(id: _otherModelId, brandId: _otherBrandId, category: categoryId, name: model, image: ''));
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceSelectionScreen()));
  }

  void _confirmOtherModel(BuildContext context, BookingProvider bp, String categoryId) {
    final model = _otherModelController.text.trim();
    if (model.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your model name')));
      return;
    }
    FocusScope.of(context).unfocus();
    bp.selectModel(DeviceModel(
      id: _otherModelId, brandId: bp.selectedBrand!.id,
      category: categoryId, name: model, image: '',
    ));
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceSelectionScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final bp = Provider.of<BookingProvider>(context);
    final categoryId = bp.selectedCategory?.id ?? 'smartphone';
    final categoryBrands = MockDataService.brands.where((b) => b.category == categoryId).toList();
    final availableModels = (bp.selectedBrand != null && bp.selectedBrand!.id != _otherBrandId)
        ? MockDataService.models.where((m) => m.category == categoryId && m.brandId == bp.selectedBrand!.id).toList()
        : <DeviceModel>[];

    if (bp.selectedBrand != null && bp.selectedBrand!.id != _otherBrandId && _isOtherBrandSelected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() { _isOtherBrandSelected = false; _isOtherModelSelected = false; });
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text('Select ${bp.selectedCategory?.name ?? 'Device'}')),
      body: SafeArea(
        child: Column(
          children: [
            // Stepper
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: const Color(0xFF0D0B1E),
              child: Row(children: [
                _stepPill('1', 'Device', true),
                _stepDivider(),
                _stepPill('2', 'Service', false),
                _stepDivider(),
                _stepPill('3', 'Checkout', false),
              ]),
            ),
            const Divider(height: 1, color: AppTheme.border),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── BRAND SECTION ──────────────────────────────────────
                    Text('Select Brand',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('${categoryBrands.length + 1} brands available',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    const SizedBox(height: 12),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, childAspectRatio: 1.05,
                        crossAxisSpacing: 10, mainAxisSpacing: 10,
                      ),
                      itemCount: categoryBrands.length + 1,
                      itemBuilder: (context, index) {
                        if (index == categoryBrands.length) {
                          return GestureDetector(
                            onTap: () => _selectOtherBrand(bp, categoryId),
                            child: _brandCard(
                              isSelected: _isOtherBrandSelected,
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    color: _isOtherBrandSelected
                                        ? Colors.white.withValues(alpha: 0.2)
                                        : AppTheme.primaryLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.edit_rounded, size: 22,
                                      color: _isOtherBrandSelected ? Colors.white : AppTheme.primary),
                                ),
                                const SizedBox(height: 8),
                                Text('Other',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12,
                                        color: _isOtherBrandSelected ? Colors.white : AppTheme.textDark)),
                              ]),
                            ),
                          );
                        }
                        final brand = categoryBrands[index];
                        final isSelected = bp.selectedBrand?.id == brand.id;
                        final logoUrl = _brandLogoUrl(brand.name);
                        return GestureDetector(
                          onTap: () {
                            setState(() { _isOtherBrandSelected = false; _isOtherModelSelected = false; });
                            bp.selectBrand(brand);
                          },
                          child: _brandCard(
                            isSelected: isSelected,
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              if (isSelected)
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 6, top: 6),
                                    child: Container(
                                      width: 16, height: 16,
                                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                      child: const Icon(Icons.check_rounded, size: 12, color: AppTheme.primary),
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(height: 22),
                              Expanded(
                                child: Center(
                                  child: logoUrl != null
                                      ? Image.network(
                                          logoUrl,
                                          fit: BoxFit.contain,
                                          color: isSelected ? Colors.white : Colors.white70,
                                          colorBlendMode: BlendMode.srcIn,
                                          errorBuilder: (context, error, stackTrace) => Icon(_categoryIcon(categoryId),
                                              size: 28, color: isSelected ? Colors.white : AppTheme.primary),
                                        )
                                      : Icon(_categoryIcon(categoryId), size: 28,
                                          color: isSelected ? Colors.white : AppTheme.primary),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(brand.name,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5,
                                      color: isSelected ? Colors.white : AppTheme.textDark),
                                  textAlign: TextAlign.center,
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 8),
                            ]),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // ── OTHER BRAND FORM ───────────────────────────────────
                    if (_isOtherBrandSelected) ...[
                      _customInputCard(
                        context: context,
                        title: 'Enter Your Device Details',
                        subtitle: 'Type your brand and model name',
                        children: [
                          _inputField(controller: _customBrandController, icon: _categoryIcon(categoryId),
                              label: 'Brand Name', hint: 'e.g. Itel, Lava, Micromax, Tecno...'),
                          const SizedBox(height: 12),
                          _inputField(controller: _customModelController, icon: Icons.devices_rounded,
                              label: 'Model Name', hint: 'e.g. Itel A70, Lava Blaze 2...'),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 14)),
                              onPressed: () => _confirmOtherBrand(context, bp, categoryId),
                              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                              label: const Text('Continue to Service Selection'),
                            ),
                          ),
                        ],
                      ),
                    ]

                    // ── MODEL SECTION ──────────────────────────────────────
                    else if (bp.selectedBrand != null) ...[
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Select ${bp.selectedBrand!.name} Model',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                        Text('${availableModels.length + 1} models',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      ]),
                      const SizedBox(height: 14),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: availableModels.length,
                        itemBuilder: (context, index) {
                          final model = availableModels[index];
                          final isSelected = bp.selectedModel?.id == model.id;
                          return _modelTile(
                            context: context, isSelected: isSelected,
                            icon: _modelIcon(categoryId), title: model.name,
                            subtitle: _modelSubtitle(categoryId),
                            onTap: () {
                              setState(() => _isOtherModelSelected = false);
                              bp.selectModel(model);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceSelectionScreen()));
                            },
                          );
                        },
                      ),

                      _modelTile(
                        context: context, isSelected: _isOtherModelSelected,
                        icon: Icons.edit_rounded, title: 'Other Model',
                        subtitle: 'Type your own model name',
                        onTap: () => setState(() => _isOtherModelSelected = !_isOtherModelSelected),
                        isOther: true,
                      ),

                      if (_isOtherModelSelected) ...[
                        const SizedBox(height: 4),
                        _customInputCard(
                          context: context,
                          title: 'Enter Your Model Name',
                          subtitle: 'Type the exact model of your ${bp.selectedBrand!.name}',
                          children: [
                            _inputField(controller: _otherModelController, icon: _modelIcon(categoryId),
                                label: 'Model Name', hint: 'e.g. ${bp.selectedBrand!.name} Pro Max, Ultra...'),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    padding: const EdgeInsets.symmetric(vertical: 14)),
                                onPressed: () => _confirmOtherModel(context, bp, categoryId),
                                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                                label: const Text('Continue to Service Selection'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ]

                    // ── No brand selected ──────────────────────────────────
                    else ...[
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: const Center(
                          child: Column(children: [
                            Icon(Icons.touch_app_rounded, size: 40, color: AppTheme.textMuted),
                            SizedBox(height: 8),
                            Text('Select a brand above to see models',
                                style: TextStyle(color: AppTheme.textMuted)),
                          ]),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _brandCard({required bool isSelected, required Widget child}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primary : AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.border, width: isSelected ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: isSelected ? AppTheme.primary.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.2),
            blurRadius: isSelected ? 12 : 5,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _modelTile({
    required BuildContext context,
    required bool isSelected,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isOther = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryLight : AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppTheme.primary : (isOther ? AppTheme.primary.withValues(alpha: 0.4) : AppTheme.border),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: isSelected ? Colors.white : AppTheme.primary),
        ),
        title: Text(title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15,
                color: isOther && !isSelected ? AppTheme.primary : AppTheme.textDark)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        trailing: isSelected
            ? const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 22)
            : Icon(isOther ? Icons.edit_rounded : Icons.arrow_forward_ios_rounded,
                size: isOther ? 18 : 16,
                color: isOther ? AppTheme.primary : AppTheme.textMuted),
        onTap: onTap,
      ),
    );
  }

  Widget _customInputCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1040),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.edit_note_rounded, color: AppTheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primary, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        const SizedBox(height: 16),
        ...children,
      ]),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(color: AppTheme.textDark),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.surface,
        prefixIcon: Icon(icon, color: AppTheme.primary),
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _stepPill(String number, String label, bool active) {
    return Row(children: [
      Container(
        width: 24, height: 24,
        decoration: BoxDecoration(
            color: active ? AppTheme.primary : AppTheme.border, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(number,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
      const SizedBox(width: 6),
      Text(label,
          style: TextStyle(
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
              color: active ? AppTheme.textDark : AppTheme.textMuted,
              fontSize: 13)),
    ]);
  }

  Widget _stepDivider() {
    return Expanded(
      child: Container(height: 2, margin: const EdgeInsets.symmetric(horizontal: 8), color: AppTheme.border),
    );
  }
}
