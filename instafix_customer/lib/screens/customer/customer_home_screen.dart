import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/device.dart';
import '../../models/offer.dart';
import '../../services/api_service.dart';
import 'device_selection_screen.dart';
import 'booking_tracking_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  List<Brand> _brands = [];
  List<Offer> _offers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    try {
      final results = await Future.wait([
        ApiService.getBrands(),
        ApiService.getOffers(),
      ]);
      if (mounted) {
        setState(() {
          _brands = results[0] as List<Brand>;
          _offers = results[1] as List<Offer>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final activeBooking = bookingProvider.getActiveBookingForUser(authProvider.currentUser);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading)
                const LinearProgressIndicator(minHeight: 2, color: AppTheme.primary),
              // ── Top Header ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                color: const Color(0xFF0D0B1E),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text('Instafix in ',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                          const Text('30 minutes ⚡',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w900,
                                  color: AppTheme.primary, letterSpacing: -0.3)),
                        ]),
                        const SizedBox(height: 2),
                        GestureDetector(
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Doorstep service active in Gurgaon & South Delhi'))),
                          child: Row(children: [
                            const Icon(Icons.location_on_rounded, color: AppTheme.textDark, size: 14),
                            const SizedBox(width: 4),
                            Text('Gurgaon, Haryana',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold, color: AppTheme.textDark, fontSize: 13)),
                            const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textDark, size: 16),
                          ]),
                        ),
                      ],
                    ),
                    Row(children: [
                      Text('Hi, ${authProvider.currentUser?.name.split(' ').first ?? 'User'}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark)),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.notifications_none_rounded, color: AppTheme.primary, size: 20),
                      ),
                    ]),
                  ],
                ),
              ),

              const Divider(height: 1, color: AppTheme.border),

              // ── EMI Promo Banner ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFF0F2A1E),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.credit_card_rounded, size: 14, color: AppTheme.promoBannerText),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      '*Fix now, pay later with easy credit-card EMIs only at Instafix.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.promoBannerText, fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ]),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Active Booking Banner ────────────────────────────
                    if (activeBooking != null) ...[
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5140D5), Color(0xFF3829A0)],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                              child: const Text('ACTIVE REPAIR BOOKING',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                            ),
                            Text(activeBooking.bookingNumber,
                                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)),
                          ]),
                          const SizedBox(height: 14),
                          Text('${activeBooking.brandName} ${activeBooking.modelName}',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Service: ${activeBooking.serviceName}',
                              style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 16),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Row(children: [
                              Container(width: 10, height: 10,
                                  decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Text(activeBooking.statusDisplay,
                                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
                            ]),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white, foregroundColor: AppTheme.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingTrackingScreen())),
                              icon: const Icon(Icons.navigation_rounded, size: 16, color: AppTheme.primary),
                              label: const Text('Track Live', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ]),
                        ]),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ── Hero Banner ──────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A1040), Color(0xFF2D1B69)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                        boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.2), blurRadius: 24, offset: const Offset(0, 8))],
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(6)),
                          child: const Text('DOORSTEP REPAIR',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
                        ),
                        const SizedBox(height: 12),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(fontFamily: 'DM Sans', fontSize: 24, fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic, color: Colors.white, height: 1.15),
                            children: [
                              TextSpan(text: 'DOORSTEP\n'),
                              TextSpan(text: 'DEVICE REPAIR\n'),
                              TextSpan(text: 'IN MINUTES ⚡', style: TextStyle(color: Color(0xFFA5B4FC))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text('Screen, battery & part replacements done right at your doorstep with 1-Year Warranty.',
                            style: TextStyle(color: Colors.white60, fontSize: 12.5, height: 1.4)),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary, foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          onPressed: () {
                            bookingProvider.selectCategory(DeviceCategory(id: 'smartphone', name: 'Smartphones', icon: 'smartphone'));
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const DeviceSelectionScreen()));
                          },
                          iconAlignment: IconAlignment.end,
                          icon: const Icon(Icons.chevron_right_rounded, size: 20),
                          label: const Text('Book now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 16),

                    // ── Stats Bar ────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statItem('50K+', 'Repairs Done'),
                          _vertDivider(),
                          _statItem('4.8★', 'Avg Rating'),
                          _vertDivider(),
                          _statItem('30 min', 'Avg Fix Time'),
                          _vertDivider(),
                          _statItem('1 Year', 'Warranty'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Backed by Trust ──────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Text('Backed by ', style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted)),
                        const Text('Titan Capital', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        const Text(' & ', style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted)),
                        const Text('8i Ventures', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        const SizedBox(width: 8),
                        Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppTheme.textMuted, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        const Icon(Icons.verified_rounded, size: 14, color: AppTheme.primary),
                        const Text(' Certified Experts', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                      ]),
                    ),

                    // ── Exclusive Offers Section (From Admin Panel) ─────
                    if (_offers.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Row(children: [
                          const Icon(Icons.local_offer_rounded, color: AppTheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text('Special Offers & Deals',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                        ]),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
                          child: Text('${_offers.length} ACTIVE', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 140,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _offers.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final offer = _offers[index];
                            return _buildOfferCard(context, offer, bookingProvider);
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // ── Device Categories ────────────────────────────────
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('What can we fix for you?',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                      Text('View all', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    ]),
                    const SizedBox(height: 14),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, childAspectRatio: 1.35,
                        crossAxisSpacing: 12, mainAxisSpacing: 12,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        final cats = [
                          (DeviceCategory(id: 'smartphone', name: 'Phone Repair', icon: 'smartphone'), Icons.phone_iphone_rounded, '10+ brands'),
                          (DeviceCategory(id: 'laptop', name: 'MacBook & Laptop', icon: 'laptop'), Icons.laptop_mac_rounded, '5+ brands'),
                          (DeviceCategory(id: 'tablet', name: 'iPad & Tablet', icon: 'tablet_mac'), Icons.tablet_mac_rounded, '4+ brands'),
                          (DeviceCategory(id: 'smartwatch', name: 'Smartwatch', icon: 'watch'), Icons.watch_rounded, '7+ brands'),
                        ];
                        final (cat, icon, sub) = cats[index];
                        return InkWell(
                          onTap: () {
                            bookingProvider.selectCategory(cat);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const DeviceSelectionScreen()));
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.border),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))],
                            ),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(color: AppTheme.primaryLight, shape: BoxShape.circle),
                                child: Icon(icon, color: AppTheme.primary, size: 24),
                              ),
                              const SizedBox(height: 8),
                              Text(cat.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 2),
                              Text(sub, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                            ]),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // ── Supported Brands with Logos ──────────────────────
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Supported Brands',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                      GestureDetector(
                        onTap: () {
                          bookingProvider.selectCategory(DeviceCategory(id: 'smartphone', name: 'Smartphones', icon: 'smartphone'));
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const DeviceSelectionScreen()));
                        },
                        child: Text('See all', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    const Text('We repair all major brands', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    const SizedBox(height: 14),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, childAspectRatio: 1.0,
                        crossAxisSpacing: 10, mainAxisSpacing: 10,
                      ),
                      itemCount: _displayBrands.length,
                      itemBuilder: (context, index) {
                        final brandItem = _displayBrands[index];
                        return GestureDetector(
                          onTap: () {
                            if (brandItem is Brand) {
                              bookingProvider.selectCategory(DeviceCategory(id: brandItem.category.isNotEmpty ? brandItem.category : 'smartphone', name: 'Smartphones', icon: 'smartphone'));
                              bookingProvider.selectBrand(brandItem);
                            } else {
                              bookingProvider.selectCategory(DeviceCategory(id: 'smartphone', name: 'Smartphones', icon: 'smartphone'));
                            }
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const DeviceSelectionScreen()));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.border),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 2))],
                            ),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              SizedBox(
                                width: 36, height: 36,
                                child: _buildBrandLogo(brandItem),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                brandItem is Brand ? brandItem.name : (brandItem as (String, String)).$1,
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ]),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // ── How It Works ─────────────────────────────────────
                    Text('How Doorstep Repair Works',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(children: [
                        _buildStepItem('1', 'Book Repair Online', 'Choose device, problem & preferred time slot'),
                        Padding(padding: const EdgeInsets.only(left: 15), child: Divider(height: 20, color: AppTheme.border)),
                        _buildStepItem('2', 'Technician Visits Home', 'Certified expert arrives with tools & parts'),
                        Padding(padding: const EdgeInsets.only(left: 15), child: Divider(height: 20, color: AppTheme.border)),
                        _buildStepItem('3', 'Pre-Check & Fix', 'Diagnostic inspection completed before repair'),
                        Padding(padding: const EdgeInsets.only(left: 15), child: Divider(height: 20, color: AppTheme.border)),
                        _buildStepItem('4', 'Pay & Get Warranty', 'Pay after satisfaction. 1-Year warranty provided'),
                      ]),
                    ),

                    const SizedBox(height: 28),

                    // ── Why Choose Instafix ──────────────────────────────
                    Text('Why Choose Instafix?',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                    const SizedBox(height: 14),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.6,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: const [
                        _FeatureCard(icon: Icons.home_repair_service_rounded, title: 'Doorstep Service', subtitle: 'Repair at your home'),
                        _FeatureCard(icon: Icons.verified_rounded, title: 'Certified Experts', subtitle: 'Trained technicians'),
                        _FeatureCard(icon: Icons.workspace_premium_rounded, title: '1-Year Warranty', subtitle: 'On all repairs'),
                        _FeatureCard(icon: Icons.payments_rounded, title: 'Pay After Fix', subtitle: 'No upfront payment'),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<dynamic> get _displayBrands {
    if (_brands.isNotEmpty) return _brands;
    return _homeBrands;
  }

  Widget _buildBrandLogo(dynamic brandItem) {
    String? logoUrl;
    String name = '';
    if (brandItem is Brand) {
      logoUrl = brandItem.logo;
      name = brandItem.name;
    } else if (brandItem is (String, String)) {
      name = brandItem.$1;
      logoUrl = brandItem.$2;
    }

    if (logoUrl != null && logoUrl.isNotEmpty) {
      return Image.network(
        logoUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Text(
            name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary),
          ),
        ),
      );
    }
    return Center(
      child: Text(
        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary),
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, Offer offer, BookingProvider bookingProvider) {
    return GestureDetector(
      onTap: () {
        bookingProvider.selectCategory(DeviceCategory(id: 'smartphone', name: 'Smartphones', icon: 'smartphone'));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(offer.code != null ? 'Promo code "${offer.code}" selected!' : 'Offer selected! Choose your device.'),
            backgroundColor: AppTheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DeviceSelectionScreen()));
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (offer.imageUrl != null && offer.imageUrl!.isNotEmpty)
              Positioned.fill(
                child: Image.network(
                  offer.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.4),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (offer.discountPercentage > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${offer.discountPercentage}% OFF',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        )
                      else
                        const SizedBox(),
                      if (offer.code != null && offer.code!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white38),
                          ),
                          child: Text(
                            offer.code!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (offer.subtitle != null && offer.subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          offer.subtitle!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 11.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<(String, String)> _homeBrands = [
    ('Apple',    'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/180px-Apple_logo_black.svg.png'),
    ('Samsung',  'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Samsung_Logo.svg/320px-Samsung_Logo.svg.png'),
    ('OnePlus',  'https://upload.wikimedia.org/wikipedia/commons/thumb/8/83/OnePlus_Logo.svg/320px-OnePlus_Logo.svg.png'),
    ('Xiaomi',   'https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Xiaomi_logo.svg/200px-Xiaomi_logo.svg.png'),
    ('Vivo',     'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Vivo_logo_2019.svg/320px-Vivo_logo_2019.svg.png'),
    ('Oppo',     'https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Oppo_Logo.svg/320px-Oppo_Logo.svg.png'),
    ('Realme',   'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Realme_logo.svg/320px-Realme_logo.svg.png'),
    ('Motorola', 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/Motorola_2021_logo.svg/320px-Motorola_2021_logo.svg.png'),
  ];

  Widget _statItem(String value, String label) {
    return Column(children: [
      Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.primary)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted)),
    ]);
  }

  Widget _vertDivider() => Container(width: 1, height: 30, color: AppTheme.border);

  Widget _buildStepItem(String number, String title, String subtitle) {
    return Row(children: [
      Container(
        width: 32, height: 32,
        decoration: const BoxDecoration(color: AppTheme.primaryLight, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(number, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
      ])),
    ]);
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _FeatureCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: AppTheme.primaryLight, shape: BoxShape.circle),
          child: Icon(icon, color: AppTheme.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textDark)),
          Text(subtitle, style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted)),
        ])),
      ]),
    );
  }
}
