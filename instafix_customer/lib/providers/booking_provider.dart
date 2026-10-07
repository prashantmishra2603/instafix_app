import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/device.dart';
import '../models/service.dart';
import '../models/booking.dart';
import '../models/warranty.dart';
import '../services/api_service.dart';
import '../services/mock_data_service.dart';

class BookingProvider extends ChangeNotifier {
  // Current authenticated user reference for filtering
  User? _currentUser;

  // Selection Flow State
  DeviceCategory? _selectedCategory;
  Brand? _selectedBrand;
  DeviceModel? _selectedModel;
  RepairService? _selectedService;
  PartOption? _selectedPartOption;
  String _selectedAddress = '';
  String _selectedDateSlot = 'Today, 2:30 PM - 4:00 PM';
  String _customIssueNote = '';

  // Bookings List
  final List<Booking> _bookings = [];
  final List<Warranty> _warranties = List.from(MockDataService.initialWarranties);
  final List<WarrantyClaim> _warrantyClaims = [];

  bool _isLoading = false;
  Timer? _pollingTimer;

  // Getters
  User? get currentUser => _currentUser;
  DeviceCategory? get selectedCategory => _selectedCategory;
  Brand? get selectedBrand => _selectedBrand;
  DeviceModel? get selectedModel => _selectedModel;
  RepairService? get selectedService => _selectedService;
  PartOption? get selectedPartOption => _selectedPartOption;
  String get selectedAddress => _selectedAddress;
  String get selectedDateSlot => _selectedDateSlot;
  String get customIssueNote => _customIssueNote;
  bool get isLoading => _isLoading;

  void setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  bool belongsToUser(Booking b, User? user) {
    if (user == null) return true;

    // 1. Match customerId (if valid > 0)
    if (user.id > 0 && b.customerId > 0 && b.customerId == user.id) {
      return true;
    }

    // 2. Match phone number (normalized)
    final uPhone = user.phone.replaceAll(RegExp(r'\D'), '');
    final bPhone = b.customerPhone.replaceAll(RegExp(r'\D'), '');
    if (uPhone.isNotEmpty && bPhone.isNotEmpty) {
      if (uPhone == bPhone) return true;
      if (uPhone.length >= 10 && bPhone.length >= 10) {
        if (uPhone.substring(uPhone.length - 10) == bPhone.substring(bPhone.length - 10)) {
          return true;
        }
      }
    }

    // 3. Match email if present
    if (user.email != null && user.email!.trim().isNotEmpty) {
      final uEmail = user.email!.trim().toLowerCase();
      if (b.customerPhone.trim().toLowerCase() == uEmail ||
          b.customerName.trim().toLowerCase() == uEmail) {
        return true;
      }
    }

    // 4. Match customer name if non-empty
    if (user.name.trim().isNotEmpty && b.customerName.trim().isNotEmpty) {
      if (user.name.trim().toLowerCase() == b.customerName.trim().toLowerCase()) {
        return true;
      }
    }

    return false;
  }

  List<Booking> get rawBookings => _bookings;

  List<Booking> get bookings {
    if (_currentUser == null) return _bookings;
    return getBookingsForUser(_currentUser);
  }

  List<Booking> getBookingsForUser(User? user) {
    if (user == null) return _bookings;
    return _bookings.where((b) => belongsToUser(b, user)).toList();
  }

  List<Warranty> get warranties {
    return getWarrantiesForUser(_currentUser);
  }

  List<Warranty> getWarrantiesForUser(User? user) {
    if (user == null) return _warranties;
    final userBookingIds = getBookingsForUser(user).map((b) => b.id).toSet();
    return _warranties.where((w) {
      if (user.id > 0 && w.customerId > 0 && w.customerId == user.id) {
        return true;
      }
      return userBookingIds.contains(w.bookingId);
    }).toList();
  }

  List<WarrantyClaim> get warrantyClaims => _warrantyClaims;

  Booking? get activeBooking {
    return getActiveBookingForUser(_currentUser);
  }

  Booking? getActiveBookingForUser(User? user) {
    final list = user != null ? getBookingsForUser(user) : _bookings;
    try {
      return list.firstWhere(
        (b) => b.status != 'COMPLETED' && b.status != 'CANCELLED' && b.status != 'REJECTED',
      );
    } catch (_) {
      return null;
    }
  }

  double get totalPrice {
    if (_selectedPartOption != null) return _selectedPartOption!.price;
    if (_selectedService != null) return _selectedService!.basePrice;
    return 0.0;
  }

  // State Setters
  void selectCategory(DeviceCategory category) {
    _selectedCategory = category;
    _selectedBrand = null;
    _selectedModel = null;
    _selectedService = null;
    _selectedPartOption = null;
    notifyListeners();
  }

  void selectBrand(Brand brand) {
    _selectedBrand = brand;
    _selectedModel = null;
    _selectedService = null;
    _selectedPartOption = null;
    notifyListeners();
  }

  void selectModel(DeviceModel model) {
    _selectedModel = model;
    _selectedService = null;
    _selectedPartOption = null;
    notifyListeners();
  }

  void selectService(RepairService service) {
    _selectedService = service;
    if (service.partOptions.isNotEmpty) {
      _selectedPartOption = service.partOptions.firstWhere(
        (p) => p.isPopular,
        orElse: () => service.partOptions.first,
      );
    } else {
      _selectedPartOption = null;
    }
    notifyListeners();
  }

  void selectPartOption(PartOption option) {
    _selectedPartOption = option;
    notifyListeners();
  }

  void setAddress(String addr) {
    _selectedAddress = addr;
    notifyListeners();
  }

  void setSlot(String slot) {
    _selectedDateSlot = slot;
    notifyListeners();
  }

  void setCustomNote(String note) {
    _customIssueNote = note;
    notifyListeners();
  }

  // ── Fetch Real Bookings from backend database ───────────────────────────
  Future<void> fetchBookings({User? user}) async {
    if (user != null) _currentUser = user;
    _isLoading = true;
    notifyListeners();
    try {
      final remoteList = await ApiService.getBookings();
      if (remoteList.isNotEmpty) {
        _bookings.clear();
        _bookings.addAll(remoteList);
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  // ── Real-time polling for booking status updates ─────────────────────────
  void startPolling({User? user}) {
    if (user != null) _currentUser = user;
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      await _refreshBookingsQuietly();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _refreshBookingsQuietly() async {
    try {
      final remoteList = await ApiService.getBookings();
      if (remoteList.isNotEmpty) {
        bool changed = false;
        for (final remote in remoteList) {
          final idx = _bookings.indexWhere((b) => b.id == remote.id);
          if (idx != -1) {
            if (_bookings[idx].status != remote.status) {
              _bookings[idx] = remote;
              changed = true;
              // Auto-add warranty on completion
              if (remote.status == 'COMPLETED') {
                _addWarrantyForBooking(remote);
              }
            }
          } else {
            _bookings.insert(0, remote);
            changed = true;
          }
        }
        if (changed) notifyListeners();
      }
    } catch (_) {}
  }

  void _addWarrantyForBooking(Booking b) {
    final exists = _warranties.any((w) => w.bookingId == b.id);
    if (!exists) {
      final now = DateTime.now();
      final end = now.add(const Duration(days: 180));
      _warranties.insert(
        0,
        Warranty(
          id: 500 + b.id,
          bookingId: b.id,
          customerId: b.customerId,
          serviceName: b.serviceName,
          deviceModelName: b.modelName,
          startDate: '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
          endDate: '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}',
          daysRemaining: 180,
          status: 'active',
        ),
      );
    }
  }

  // ── Create Real Booking with real customer info (Live Backend API) ─────────
  Future<Booking> createBooking({
    String? customerName,
    String? customerPhone,
    int? customerId,
    String? customerAddress,
  }) async {
    final realAddress = (customerAddress != null && customerAddress.trim().isNotEmpty)
        ? customerAddress.trim()
        : (_selectedAddress.isNotEmpty ? _selectedAddress : 'Customer Doorstep Location');

    final realCustomerName = (customerName != null && customerName.trim().isNotEmpty)
        ? customerName.trim()
        : 'Customer';
    final realCustomerPhone = (customerPhone != null && customerPhone.trim().isNotEmpty)
        ? customerPhone.trim()
        : '9876543210';

    final brand = _selectedBrand?.name ?? 'Apple';
    final model = _selectedModel?.name ?? 'iPhone 15';
    final service = _selectedService?.name ?? 'Screen Replacement';
    final est = totalPrice > 0 ? totalPrice : 1499.0;

    final bookingPayload = {
      'brand_name': brand,
      'model_name': model,
      'service_name': service,
      'estimated_cost': est,
      'final_cost': est,
      'customer_name': realCustomerName,
      'customer_phone': realCustomerPhone,
      'customer_address': realAddress,
      if (customerId != null && customerId > 0) 'customer_id': customerId,
      'city': 'Bengaluru',
      'scheduled_date': DateTime.now().add(const Duration(days: 1)).toString().substring(0, 10),
      'time_slot': _selectedDateSlot.isNotEmpty ? _selectedDateSlot : 'Today, 2:00 PM - 4:00 PM',
      'device_category': _selectedCategory?.id ?? 'smartphone',
      'part_option_name': _selectedPartOption?.name ?? 'Original OEM',
      'notes': _customIssueNote.isNotEmpty ? _customIssueNote : 'Doorstep device repair',
      'status': 'pending',
    };

    Booking newBooking;

    try {
      final res = await ApiService.createRemoteBooking(bookingPayload);
      if (res['success'] == true && res['data'] != null) {
        final dynamic raw = res['data'];
        final Map<String, dynamic> bookingData = (raw is Map && raw['booking'] != null)
            ? raw['booking'] as Map<String, dynamic>
            : (raw is Map<String, dynamic> ? raw : {});
        newBooking = Booking.fromJson(bookingData);
      } else {
        final int newId = DateTime.now().millisecondsSinceEpoch % 100000 + 1000;
        newBooking = Booking(
          id: newId,
          bookingNumber: 'INSTA-$newId',
          customerId: customerId ?? 0,
          customerName: realCustomerName,
          customerPhone: realCustomerPhone,
          deviceCategory: _selectedCategory?.id ?? 'smartphone',
          brandName: brand,
          modelName: model,
          serviceName: service,
          partOptionName: _selectedPartOption?.name ?? '',
          addressLine: realAddress,
          scheduledSlot: _selectedDateSlot,
          status: 'PENDING',
          estimateAmount: est,
          finalAmount: est,
          paymentStatus: 'PENDING',
          createdAt: 'Just now',
        );
      }
    } catch (_) {
      final int newId = DateTime.now().millisecondsSinceEpoch % 100000 + 1000;
      newBooking = Booking(
        id: newId,
        bookingNumber: 'INSTA-$newId',
        customerId: customerId ?? 0,
        customerName: realCustomerName,
        customerPhone: realCustomerPhone,
        deviceCategory: _selectedCategory?.id ?? 'smartphone',
        brandName: brand,
        modelName: model,
        serviceName: service,
        partOptionName: _selectedPartOption?.name ?? '',
        addressLine: realAddress,
        scheduledSlot: _selectedDateSlot,
        status: 'PENDING',
        estimateAmount: est,
        finalAmount: est,
        paymentStatus: 'PENDING',
        createdAt: 'Just now',
      );
    }

    _bookings.insert(0, newBooking);
    notifyListeners();
    return newBooking;
  }

  // ── Customer approves/rejects extra work ─────────────────────────────────
  void respondToApproval(int bookingId, bool approved) {
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      final current = _bookings[idx];
      if (current.diagnostic != null) {
        final diag = current.diagnostic!;
        final addAmt = diag.additionalAmount ?? 0.0;
        final newFinal = approved ? (current.estimateAmount + addAmt) : current.estimateAmount;

        _bookings[idx] = current.copyWith(
          status: 'REPAIRING',
          additionalAmount: approved ? addAmt : 0.0,
          finalAmount: newFinal,
          diagnostic: diag,
        );
        notifyListeners();

        // Sync status to backend
        ApiService.updateRemoteBookingStatus(bookingId, 'REPAIRING');
      }
    }
  }

  // ── File Warranty Claim ──────────────────────────────────────────────────
  void fileWarrantyClaim(int warrantyId, String description) {
    final claimId = 900 + _warrantyClaims.length + 1;
    _warrantyClaims.add(WarrantyClaim(
      id: claimId,
      warrantyId: warrantyId,
      description: description,
      status: 'pending',
      createdAt: 'Just now',
    ));
    notifyListeners();
  }

  // ── Sync external booking update (from technician app) ───────────────────
  void updateBooking(Booking updated) {
    final idx = _bookings.indexWhere((b) => b.id == updated.id);
    if (idx != -1) {
      _bookings[idx] = updated;
      if (updated.status == 'COMPLETED') {
        _addWarrantyForBooking(updated);
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
