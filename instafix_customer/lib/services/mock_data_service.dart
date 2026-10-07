import '../models/device.dart';
import '../models/service.dart';
import '../models/booking.dart';
import '../models/warranty.dart';

class MockDataService {
  static List<DeviceCategory> categories = [
    DeviceCategory(id: 'smartphone', name: 'Smartphones', icon: 'smartphone'),
    DeviceCategory(id: 'tablet', name: 'Tablets & iPads', icon: 'tablet_mac'),
    DeviceCategory(id: 'laptop', name: 'Laptops & MacBooks', icon: 'laptop'),
    DeviceCategory(id: 'smartwatch', name: 'Smartwatches', icon: 'watch'),
  ];

  // ── Brand logo URLs (official/high-quality) ────────────────────────────────
  static const Map<String, String> brandLogoUrls = {
    // Smartphones
    'Apple': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/180px-Apple_logo_black.svg.png',
    'Samsung': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Samsung_Logo.svg/320px-Samsung_Logo.svg.png',
    'Google Pixel': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Google_2015_logo.svg/320px-Google_2015_logo.svg.png',
    'OnePlus': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/83/OnePlus_Logo.svg/320px-OnePlus_Logo.svg.png',
    'Xiaomi': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Xiaomi_logo.svg/200px-Xiaomi_logo.svg.png',
    'Vivo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Vivo_logo_2019.svg/320px-Vivo_logo_2019.svg.png',
    'Oppo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Oppo_Logo.svg/320px-Oppo_Logo.svg.png',
    'Realme': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Realme_logo.svg/320px-Realme_logo.svg.png',
    'Nothing': 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/Nothing_logo_2022.svg/320px-Nothing_logo_2022.svg.png',
    'Motorola': 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/Motorola_2021_logo.svg/320px-Motorola_2021_logo.svg.png',
    // Tablets
    'Apple iPad': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/180px-Apple_logo_black.svg.png',
    'Samsung Tab': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Samsung_Logo.svg/320px-Samsung_Logo.svg.png',
    'Lenovo Tab': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/Lenovo_logo_2015.svg/320px-Lenovo_logo_2015.svg.png',
    'Xiaomi Pad': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Xiaomi_logo.svg/200px-Xiaomi_logo.svg.png',
    // Laptops
    'Apple MacBook': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/180px-Apple_logo_black.svg.png',
    'Dell': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/Dell_logo_2016.svg/300px-Dell_logo_2016.svg.png',
    'HP': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/HP_logo_2012.svg/200px-HP_logo_2012.svg.png',
    'Lenovo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/Lenovo_logo_2015.svg/320px-Lenovo_logo_2015.svg.png',
    'Asus': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/ASUS_Logo.svg/320px-ASUS_Logo.svg.png',
    // Smartwatches
    'Apple Watch': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/180px-Apple_logo_black.svg.png',
    'Samsung Watch': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Samsung_Logo.svg/320px-Samsung_Logo.svg.png',
    'Noise': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/Noise_logo.png/320px-Noise_logo.png',
    'boAt': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/BoAt_Lifestyle_Logo.png/320px-BoAt_Lifestyle_Logo.png',
    'Garmin': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Garmin_logo.svg/320px-Garmin_logo.svg.png',
    'Fitbit': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/Fitbit_logo_2016.svg/320px-Fitbit_logo_2016.svg.png',
    'Fossil': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/Fossil_logo.svg/320px-Fossil_logo.svg.png',
  };

  static List<Brand> brands = [
    // ── Smartphones ──────────────────────────────────────────────────────────
    Brand(id: 1,  category: 'smartphone', name: 'Apple',        logo: 'apple'),
    Brand(id: 2,  category: 'smartphone', name: 'Samsung',      logo: 'samsung'),
    Brand(id: 3,  category: 'smartphone', name: 'Google Pixel', logo: 'google_pixel'),
    Brand(id: 4,  category: 'smartphone', name: 'OnePlus',      logo: 'oneplus'),
    Brand(id: 7,  category: 'smartphone', name: 'Xiaomi',       logo: 'xiaomi'),
    Brand(id: 8,  category: 'smartphone', name: 'Vivo',         logo: 'vivo'),
    Brand(id: 9,  category: 'smartphone', name: 'Oppo',         logo: 'oppo'),
    Brand(id: 10, category: 'smartphone', name: 'Realme',       logo: 'realme'),
    Brand(id: 11, category: 'smartphone', name: 'Nothing',      logo: 'nothing'),
    Brand(id: 12, category: 'smartphone', name: 'Motorola',     logo: 'motorola'),
    // ── Tablets ──────────────────────────────────────────────────────────────
    Brand(id: 20, category: 'tablet', name: 'Apple iPad',   logo: 'apple_ipad'),
    Brand(id: 21, category: 'tablet', name: 'Samsung Tab',  logo: 'samsung_tab'),
    Brand(id: 22, category: 'tablet', name: 'Lenovo Tab',   logo: 'lenovo_tab'),
    Brand(id: 23, category: 'tablet', name: 'Xiaomi Pad',   logo: 'xiaomi_pad'),
    // ── Laptops ──────────────────────────────────────────────────────────────
    Brand(id: 5,  category: 'laptop', name: 'Apple MacBook', logo: 'laptop_mac'),
    Brand(id: 6,  category: 'laptop', name: 'Dell',          logo: 'laptop'),
    Brand(id: 13, category: 'laptop', name: 'HP',            logo: 'laptop'),
    Brand(id: 14, category: 'laptop', name: 'Lenovo',        logo: 'laptop'),
    Brand(id: 15, category: 'laptop', name: 'Asus',          logo: 'laptop'),
    // ── Smartwatches ─────────────────────────────────────────────────────────
    Brand(id: 30, category: 'smartwatch', name: 'Apple Watch',   logo: 'watch'),
    Brand(id: 31, category: 'smartwatch', name: 'Samsung Watch', logo: 'watch'),
    Brand(id: 32, category: 'smartwatch', name: 'Noise',         logo: 'watch'),
    Brand(id: 33, category: 'smartwatch', name: 'boAt',          logo: 'watch'),
    Brand(id: 34, category: 'smartwatch', name: 'Garmin',        logo: 'watch'),
    Brand(id: 35, category: 'smartwatch', name: 'Fitbit',        logo: 'watch'),
    Brand(id: 36, category: 'smartwatch', name: 'Fossil',        logo: 'watch'),
  ];

  static List<DeviceModel> models = [
    // ── Apple iPhone ─────────────────────────────────────────────────────────
    DeviceModel(id: 101, brandId: 1, category: 'smartphone', name: 'iPhone 16 Pro Max', image: 'phone_iphone'),
    DeviceModel(id: 102, brandId: 1, category: 'smartphone', name: 'iPhone 16 Pro', image: 'phone_iphone'),
    DeviceModel(id: 103, brandId: 1, category: 'smartphone', name: 'iPhone 15 Pro Max', image: 'phone_iphone'),
    DeviceModel(id: 104, brandId: 1, category: 'smartphone', name: 'iPhone 15 Pro', image: 'phone_iphone'),
    DeviceModel(id: 105, brandId: 1, category: 'smartphone', name: 'iPhone 15', image: 'phone_iphone'),
    DeviceModel(id: 106, brandId: 1, category: 'smartphone', name: 'iPhone 14 Pro', image: 'phone_iphone'),
    DeviceModel(id: 107, brandId: 1, category: 'smartphone', name: 'iPhone 14', image: 'phone_iphone'),
    DeviceModel(id: 108, brandId: 1, category: 'smartphone', name: 'iPhone 13 Pro', image: 'phone_iphone'),
    DeviceModel(id: 109, brandId: 1, category: 'smartphone', name: 'iPhone 13', image: 'phone_iphone'),
    DeviceModel(id: 110, brandId: 1, category: 'smartphone', name: 'iPhone 12', image: 'phone_iphone'),
    // ── Samsung ──────────────────────────────────────────────────────────────
    DeviceModel(id: 201, brandId: 2, category: 'smartphone', name: 'Samsung Galaxy S24 Ultra', image: 'phone_android'),
    DeviceModel(id: 202, brandId: 2, category: 'smartphone', name: 'Samsung Galaxy S24+', image: 'phone_android'),
    DeviceModel(id: 203, brandId: 2, category: 'smartphone', name: 'Samsung Galaxy S24', image: 'phone_android'),
    DeviceModel(id: 204, brandId: 2, category: 'smartphone', name: 'Samsung Galaxy S23 Ultra', image: 'phone_android'),
    DeviceModel(id: 205, brandId: 2, category: 'smartphone', name: 'Samsung Galaxy S23', image: 'phone_android'),
    DeviceModel(id: 206, brandId: 2, category: 'smartphone', name: 'Samsung Galaxy A54', image: 'phone_android'),
    DeviceModel(id: 207, brandId: 2, category: 'smartphone', name: 'Samsung Galaxy A34', image: 'phone_android'),
    // ── Google Pixel ─────────────────────────────────────────────────────────
    DeviceModel(id: 301, brandId: 3, category: 'smartphone', name: 'Google Pixel 9 Pro XL', image: 'phone_android'),
    DeviceModel(id: 302, brandId: 3, category: 'smartphone', name: 'Google Pixel 9 Pro', image: 'phone_android'),
    DeviceModel(id: 303, brandId: 3, category: 'smartphone', name: 'Google Pixel 9', image: 'phone_android'),
    DeviceModel(id: 304, brandId: 3, category: 'smartphone', name: 'Google Pixel 8 Pro', image: 'phone_android'),
    DeviceModel(id: 305, brandId: 3, category: 'smartphone', name: 'Google Pixel 8', image: 'phone_android'),
    // ── OnePlus ──────────────────────────────────────────────────────────────
    DeviceModel(id: 401, brandId: 4, category: 'smartphone', name: 'OnePlus 12 Pro', image: 'phone_android'),
    DeviceModel(id: 402, brandId: 4, category: 'smartphone', name: 'OnePlus 12', image: 'phone_android'),
    DeviceModel(id: 403, brandId: 4, category: 'smartphone', name: 'OnePlus 11 Pro', image: 'phone_android'),
    DeviceModel(id: 404, brandId: 4, category: 'smartphone', name: 'OnePlus Nord 4', image: 'phone_android'),
    // ── Xiaomi ───────────────────────────────────────────────────────────────
    DeviceModel(id: 501, brandId: 7, category: 'smartphone', name: 'Xiaomi 14 Ultra', image: 'phone_android'),
    DeviceModel(id: 502, brandId: 7, category: 'smartphone', name: 'Xiaomi 14 Pro', image: 'phone_android'),
    DeviceModel(id: 503, brandId: 7, category: 'smartphone', name: 'Redmi Note 13 Pro+', image: 'phone_android'),
    DeviceModel(id: 504, brandId: 7, category: 'smartphone', name: 'Redmi Note 13 Pro', image: 'phone_android'),
    // ── Vivo ─────────────────────────────────────────────────────────────────
    DeviceModel(id: 601, brandId: 8, category: 'smartphone', name: 'Vivo X100 Pro', image: 'phone_android'),
    DeviceModel(id: 602, brandId: 8, category: 'smartphone', name: 'Vivo V30 Pro', image: 'phone_android'),
    DeviceModel(id: 603, brandId: 8, category: 'smartphone', name: 'Vivo Y200 Pro', image: 'phone_android'),
    // ── Oppo ─────────────────────────────────────────────────────────────────
    DeviceModel(id: 701, brandId: 9, category: 'smartphone', name: 'Oppo Find X7 Pro', image: 'phone_android'),
    DeviceModel(id: 702, brandId: 9, category: 'smartphone', name: 'Oppo Reno 12 Pro', image: 'phone_android'),
    // ── Realme ───────────────────────────────────────────────────────────────
    DeviceModel(id: 801, brandId: 10, category: 'smartphone', name: 'Realme GT 6', image: 'phone_android'),
    DeviceModel(id: 802, brandId: 10, category: 'smartphone', name: 'Realme 12 Pro+', image: 'phone_android'),
    // ── Nothing ──────────────────────────────────────────────────────────────
    DeviceModel(id: 901, brandId: 11, category: 'smartphone', name: 'Nothing Phone (2a)', image: 'phone_android'),
    DeviceModel(id: 902, brandId: 11, category: 'smartphone', name: 'Nothing Phone (2)', image: 'phone_android'),
    // ── Motorola ─────────────────────────────────────────────────────────────
    DeviceModel(id: 1001, brandId: 12, category: 'smartphone', name: 'Motorola Edge 50 Pro', image: 'phone_android'),
    DeviceModel(id: 1002, brandId: 12, category: 'smartphone', name: 'Moto G84', image: 'phone_android'),

    // ── Apple iPad ───────────────────────────────────────────────────────────
    DeviceModel(id: 2001, brandId: 20, category: 'tablet', name: 'iPad Pro 13" M4', image: 'tablet_mac'),
    DeviceModel(id: 2002, brandId: 20, category: 'tablet', name: 'iPad Pro 11" M4', image: 'tablet_mac'),
    DeviceModel(id: 2003, brandId: 20, category: 'tablet', name: 'iPad Air M2', image: 'tablet_mac'),
    DeviceModel(id: 2004, brandId: 20, category: 'tablet', name: 'iPad Mini 7th Gen', image: 'tablet_mac'),
    DeviceModel(id: 2005, brandId: 20, category: 'tablet', name: 'iPad 10th Gen', image: 'tablet_mac'),
    DeviceModel(id: 2006, brandId: 20, category: 'tablet', name: 'iPad 9th Gen', image: 'tablet_mac'),
    // ── Samsung Tab ──────────────────────────────────────────────────────────
    DeviceModel(id: 2101, brandId: 21, category: 'tablet', name: 'Galaxy Tab S9 Ultra', image: 'tablet_android'),
    DeviceModel(id: 2102, brandId: 21, category: 'tablet', name: 'Galaxy Tab S9+', image: 'tablet_android'),
    DeviceModel(id: 2103, brandId: 21, category: 'tablet', name: 'Galaxy Tab S9 FE', image: 'tablet_android'),
    DeviceModel(id: 2104, brandId: 21, category: 'tablet', name: 'Galaxy Tab A9+', image: 'tablet_android'),
    // ── Lenovo Tab ───────────────────────────────────────────────────────────
    DeviceModel(id: 2201, brandId: 22, category: 'tablet', name: 'Lenovo Tab P12 Pro', image: 'tablet_android'),
    DeviceModel(id: 2202, brandId: 22, category: 'tablet', name: 'Lenovo Tab M11', image: 'tablet_android'),
    // ── Xiaomi Pad ───────────────────────────────────────────────────────────
    DeviceModel(id: 2301, brandId: 23, category: 'tablet', name: 'Xiaomi Pad 6 Pro', image: 'tablet_android'),
    DeviceModel(id: 2302, brandId: 23, category: 'tablet', name: 'Xiaomi Pad 6', image: 'tablet_android'),

    // ── Apple MacBook ─────────────────────────────────────────────────────────
    DeviceModel(id: 3001, brandId: 5, category: 'laptop', name: 'MacBook Pro 16" M3 Max', image: 'laptop_mac'),
    DeviceModel(id: 3002, brandId: 5, category: 'laptop', name: 'MacBook Pro 14" M3 Pro', image: 'laptop_mac'),
    DeviceModel(id: 3003, brandId: 5, category: 'laptop', name: 'MacBook Air 15" M3', image: 'laptop_mac'),
    DeviceModel(id: 3004, brandId: 5, category: 'laptop', name: 'MacBook Air 13" M2', image: 'laptop_mac'),
    // ── Dell ─────────────────────────────────────────────────────────────────
    DeviceModel(id: 3101, brandId: 6, category: 'laptop', name: 'Dell XPS 15', image: 'laptop'),
    DeviceModel(id: 3102, brandId: 6, category: 'laptop', name: 'Dell Inspiron 15', image: 'laptop'),
    DeviceModel(id: 3103, brandId: 6, category: 'laptop', name: 'Dell Latitude 14', image: 'laptop'),
    // ── HP ───────────────────────────────────────────────────────────────────
    DeviceModel(id: 3201, brandId: 13, category: 'laptop', name: 'HP Spectre x360', image: 'laptop'),
    DeviceModel(id: 3202, brandId: 13, category: 'laptop', name: 'HP Pavilion 15', image: 'laptop'),
    DeviceModel(id: 3203, brandId: 13, category: 'laptop', name: 'HP EliteBook 840', image: 'laptop'),
    // ── Lenovo ───────────────────────────────────────────────────────────────
    DeviceModel(id: 3301, brandId: 14, category: 'laptop', name: 'Lenovo ThinkPad X1 Carbon', image: 'laptop'),
    DeviceModel(id: 3302, brandId: 14, category: 'laptop', name: 'Lenovo IdeaPad Slim 5', image: 'laptop'),
    // ── Asus ─────────────────────────────────────────────────────────────────
    DeviceModel(id: 3401, brandId: 15, category: 'laptop', name: 'Asus ROG Zephyrus G14', image: 'laptop'),
    DeviceModel(id: 3402, brandId: 15, category: 'laptop', name: 'Asus ZenBook 14 OLED', image: 'laptop'),

    // ── Apple Watch ──────────────────────────────────────────────────────────
    DeviceModel(id: 4001, brandId: 30, category: 'smartwatch', name: 'Apple Watch Ultra 2', image: 'watch'),
    DeviceModel(id: 4002, brandId: 30, category: 'smartwatch', name: 'Apple Watch Series 9', image: 'watch'),
    DeviceModel(id: 4003, brandId: 30, category: 'smartwatch', name: 'Apple Watch SE 2024', image: 'watch'),
    // ── Samsung Watch ────────────────────────────────────────────────────────
    DeviceModel(id: 4101, brandId: 31, category: 'smartwatch', name: 'Galaxy Watch 7', image: 'watch'),
    DeviceModel(id: 4102, brandId: 31, category: 'smartwatch', name: 'Galaxy Watch Ultra', image: 'watch'),
    DeviceModel(id: 4103, brandId: 31, category: 'smartwatch', name: 'Galaxy Watch 6 Classic', image: 'watch'),
    // ── Noise ────────────────────────────────────────────────────────────────
    DeviceModel(id: 4201, brandId: 32, category: 'smartwatch', name: 'Noise ColorFit Ultra 3', image: 'watch'),
    DeviceModel(id: 4202, brandId: 32, category: 'smartwatch', name: 'Noise Newly Plus', image: 'watch'),
    // ── boAt ─────────────────────────────────────────────────────────────────
    DeviceModel(id: 4301, brandId: 33, category: 'smartwatch', name: 'boAt Wave Sigma', image: 'watch'),
    DeviceModel(id: 4302, brandId: 33, category: 'smartwatch', name: 'boAt Lunar Connect Xtend', image: 'watch'),
    // ── Garmin ───────────────────────────────────────────────────────────────
    DeviceModel(id: 4401, brandId: 34, category: 'smartwatch', name: 'Garmin Fenix 7X', image: 'watch'),
    DeviceModel(id: 4402, brandId: 34, category: 'smartwatch', name: 'Garmin Venu 3', image: 'watch'),
    // ── Fitbit ───────────────────────────────────────────────────────────────
    DeviceModel(id: 4501, brandId: 35, category: 'smartwatch', name: 'Fitbit Sense 2', image: 'watch'),
    DeviceModel(id: 4502, brandId: 35, category: 'smartwatch', name: 'Fitbit Versa 4', image: 'watch'),
    // ── Fossil ───────────────────────────────────────────────────────────────
    DeviceModel(id: 4601, brandId: 36, category: 'smartwatch', name: 'Fossil Gen 6 Wellness', image: 'watch'),
    DeviceModel(id: 4602, brandId: 36, category: 'smartwatch', name: 'Fossil Hybrid HR', image: 'watch'),
  ];

  static List<RepairService> services = [
    // ── Smartphone Services ───────────────────────────────────────────────────
    RepairService(
      id: 1,
      deviceCategory: 'smartphone',
      name: 'Screen Glass / OLED Replacement',
      description: 'Cracked screen, dead pixels, touch unresponsiveness, or flickering display.',
      basePrice: 2499.0,
      warrantyDays: 180,
      icon: 'smartphone',
      partOptions: [
        PartOption(id: 11, serviceId: 1, name: 'Compatible Grade-A Display', price: 2499.0, warrantyPeriod: '3 Months'),
        PartOption(id: 12, serviceId: 1, name: 'Original OEM OLED Panel', price: 4499.0, warrantyPeriod: '6 Months', isPopular: true),
        PartOption(id: 13, serviceId: 1, name: 'Premium Super Retina (Refurbished)', price: 3499.0, warrantyPeriod: '6 Months'),
      ],
    ),
    RepairService(
      id: 2,
      deviceCategory: 'smartphone',
      name: 'Battery Replacement (Health Boost)',
      description: 'Rapid battery drain, phone overheating, or unexpected shutdowns.',
      basePrice: 1299.0,
      warrantyDays: 180,
      icon: 'battery_alert',
      partOptions: [
        PartOption(id: 21, serviceId: 2, name: 'Standard High-Capacity Battery', price: 1299.0, warrantyPeriod: '3 Months'),
        PartOption(id: 22, serviceId: 2, name: 'Original OEM Battery (Zero Cycle)', price: 1999.0, warrantyPeriod: '6 Months', isPopular: true),
      ],
    ),
    RepairService(
      id: 3,
      deviceCategory: 'smartphone',
      name: 'Charging Port & Flex Repair',
      description: 'Phone not charging, loose cable connection, or slow charging speed.',
      basePrice: 899.0,
      warrantyDays: 90,
      icon: 'power',
      partOptions: [
        PartOption(id: 31, serviceId: 3, name: 'Original Type-C / Lightning Flex', price: 899.0, warrantyPeriod: '3 Months', isPopular: true),
      ],
    ),
    RepairService(
      id: 4,
      deviceCategory: 'smartphone',
      name: 'Camera Lens / Sensor Repair',
      description: 'Blurry photos, focus motor buzzing, broken rear camera glass.',
      basePrice: 1599.0,
      warrantyDays: 90,
      icon: 'camera_alt',
      partOptions: [
        PartOption(id: 41, serviceId: 4, name: 'Camera Glass Protection Replacement', price: 599.0, warrantyPeriod: '1 Month'),
        PartOption(id: 42, serviceId: 4, name: 'Complete Rear Camera Module', price: 2299.0, warrantyPeriod: '3 Months', isPopular: true),
      ],
    ),

    // ── Tablet Services ───────────────────────────────────────────────────────
    RepairService(
      id: 10,
      deviceCategory: 'tablet',
      name: 'Tablet Screen / LCD Replacement',
      description: 'Cracked display, touch not working, or broken digitizer.',
      basePrice: 3999.0,
      warrantyDays: 180,
      icon: 'tablet_mac',
      partOptions: [
        PartOption(id: 101, serviceId: 10, name: 'Compatible LCD Assembly', price: 3999.0, warrantyPeriod: '3 Months'),
        PartOption(id: 102, serviceId: 10, name: 'Original OEM Display Panel', price: 6999.0, warrantyPeriod: '6 Months', isPopular: true),
      ],
    ),
    RepairService(
      id: 11,
      deviceCategory: 'tablet',
      name: 'Tablet Battery Replacement',
      description: 'Battery draining fast, swelling battery, or tablet not turning on.',
      basePrice: 1999.0,
      warrantyDays: 180,
      icon: 'battery_charging_full',
      partOptions: [
        PartOption(id: 111, serviceId: 11, name: 'Standard Capacity Battery', price: 1999.0, warrantyPeriod: '3 Months'),
        PartOption(id: 112, serviceId: 11, name: 'Original OEM Battery', price: 2999.0, warrantyPeriod: '6 Months', isPopular: true),
      ],
    ),
    RepairService(
      id: 12,
      deviceCategory: 'tablet',
      name: 'Tablet Charging Port Repair',
      description: 'Tablet not charging, loose or bent charging port.',
      basePrice: 1299.0,
      warrantyDays: 90,
      icon: 'power',
      partOptions: [
        PartOption(id: 121, serviceId: 12, name: 'Original Type-C / Lightning Port', price: 1299.0, warrantyPeriod: '3 Months', isPopular: true),
      ],
    ),
    RepairService(
      id: 13,
      deviceCategory: 'tablet',
      name: 'Back Glass / Housing Repair',
      description: 'Cracked back panel, bent chassis, or broken frame.',
      basePrice: 2499.0,
      warrantyDays: 90,
      icon: 'tablet_android',
      partOptions: [
        PartOption(id: 131, serviceId: 13, name: 'Compatible Back Glass', price: 2499.0, warrantyPeriod: '3 Months', isPopular: true),
      ],
    ),

    // ── Laptop Services ───────────────────────────────────────────────────────
    RepairService(
      id: 20,
      deviceCategory: 'laptop',
      name: 'Laptop Screen Replacement',
      description: 'Cracked display, blank screen, flickering lines, or backlight issue.',
      basePrice: 4999.0,
      warrantyDays: 180,
      icon: 'laptop',
      partOptions: [
        PartOption(id: 201, serviceId: 20, name: 'Compatible LCD/LED Panel', price: 4999.0, warrantyPeriod: '3 Months'),
        PartOption(id: 202, serviceId: 20, name: 'Original IPS/OLED Panel', price: 8999.0, warrantyPeriod: '6 Months', isPopular: true),
      ],
    ),
    RepairService(
      id: 21,
      deviceCategory: 'laptop',
      name: 'Laptop Battery Replacement',
      description: 'Laptop not lasting long, battery bulging, or dead battery.',
      basePrice: 2499.0,
      warrantyDays: 180,
      icon: 'battery_full',
      partOptions: [
        PartOption(id: 211, serviceId: 21, name: 'Compatible High-Cap Battery', price: 2499.0, warrantyPeriod: '6 Months', isPopular: true),
        PartOption(id: 212, serviceId: 21, name: 'Original OEM Battery', price: 3999.0, warrantyPeriod: '1 Year'),
      ],
    ),
    RepairService(
      id: 22,
      deviceCategory: 'laptop',
      name: 'Keyboard Replacement',
      description: 'Keys not working, sticky keys, or liquid damage to keyboard.',
      basePrice: 2999.0,
      warrantyDays: 90,
      icon: 'keyboard',
      partOptions: [
        PartOption(id: 221, serviceId: 22, name: 'Compatible Keyboard Unit', price: 2999.0, warrantyPeriod: '3 Months', isPopular: true),
        PartOption(id: 222, serviceId: 22, name: 'Original OEM Keyboard', price: 4499.0, warrantyPeriod: '6 Months'),
      ],
    ),

    // ── Smartwatch Services ───────────────────────────────────────────────────
    RepairService(
      id: 30,
      deviceCategory: 'smartwatch',
      name: 'Smartwatch Display Replacement',
      description: 'Cracked screen, touch not working, or display not visible.',
      basePrice: 1999.0,
      warrantyDays: 90,
      icon: 'watch',
      partOptions: [
        PartOption(id: 301, serviceId: 30, name: 'Compatible AMOLED Display', price: 1999.0, warrantyPeriod: '3 Months'),
        PartOption(id: 302, serviceId: 30, name: 'Original OEM Display', price: 3499.0, warrantyPeriod: '6 Months', isPopular: true),
      ],
    ),
    RepairService(
      id: 31,
      deviceCategory: 'smartwatch',
      name: 'Smartwatch Battery Replacement',
      description: 'Watch not lasting a full day or not charging properly.',
      basePrice: 999.0,
      warrantyDays: 90,
      icon: 'battery_1_bar',
      partOptions: [
        PartOption(id: 311, serviceId: 31, name: 'Compatible Battery', price: 999.0, warrantyPeriod: '3 Months', isPopular: true),
        PartOption(id: 312, serviceId: 31, name: 'Original OEM Battery', price: 1799.0, warrantyPeriod: '6 Months'),
      ],
    ),
    RepairService(
      id: 32,
      deviceCategory: 'smartwatch',
      name: 'Crown / Button Repair',
      description: 'Digital crown stuck, side button not working.',
      basePrice: 799.0,
      warrantyDays: 60,
      icon: 'settings',
      partOptions: [
        PartOption(id: 321, serviceId: 32, name: 'Crown / Button Assembly', price: 799.0, warrantyPeriod: '2 Months', isPopular: true),
      ],
    ),
    RepairService(
      id: 33,
      deviceCategory: 'smartwatch',
      name: 'Watch Band / Strap Replacement',
      description: 'Broken band, loose attachment pins, or strap damage.',
      basePrice: 499.0,
      warrantyDays: 30,
      icon: 'watch_later',
      partOptions: [
        PartOption(id: 331, serviceId: 33, name: 'Silicon Sport Band', price: 499.0, warrantyPeriod: '1 Month'),
        PartOption(id: 332, serviceId: 33, name: 'Premium Leather Band', price: 999.0, warrantyPeriod: '3 Months', isPopular: true),
        PartOption(id: 333, serviceId: 33, name: 'Stainless Steel Milanese Loop', price: 1499.0, warrantyPeriod: '6 Months'),
      ],
    ),
  ];

  // Empty — real bookings come from backend per logged-in user
  static List<Booking> initialBookings = [];

  // Empty — real warranties come from backend per logged-in user
  static List<Warranty> initialWarranties = [];
}
