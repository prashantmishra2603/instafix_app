import 'dart:async';
import 'package:flutter/material.dart';
import '../models/device.dart';
import '../models/service.dart';
import '../models/booking.dart';
import '../models/warranty.dart';
import '../services/api_service.dart';

class BookingProvider extends ChangeNotifier {
  // Selection Flow State
  DeviceCategory? _selectedCategory;
  Brand? _selectedBrand;
  DeviceModel? _selectedModel;
  RepairService? _selectedService;
  PartOption? _selectedPartOption;
  String _selectedAddress = 'Flat 402, Green Glen Layout, Bellandur, Bengaluru';
  String _selectedDateSlot = 'Today, 2:30 PM - 4:00 PM';
  String _customIssueNote = '';

  // Bookings List – populated exclusively from real backend
  final List<Booking> _bookings = [];
  final List<Warranty> _warranties = [];
  final List<WarrantyClaim> _warrantyClaims = [];

  // Getters
  DeviceCategory? get selectedCategory => _selectedCategory;
  Brand? get selectedBrand => _selectedBrand;
  DeviceModel? get selectedModel => _selectedModel;
  RepairService? get selectedService => _selectedService;
  PartOption? get selectedPartOption => _selectedPartOption;
  String get selectedAddress => _selectedAddress;
  String get selectedDateSlot => _selectedDateSlot;
  String get customIssueNote => _customIssueNote;

  List<Booking> get bookings => _bookings;
  List<Warranty> get warranties => _warranties;
  List<WarrantyClaim> get warrantyClaims => _warrantyClaims;

  Booking? get activeBooking {
    try {
      return _bookings.firstWhere(
        (b) => b.status != 'COMPLETED' && b.status != 'CANCELLED' && b.status != 'REJECTED',
      );
    } catch (_) {
      return null;
    }
  }

  double get totalPrice {
    if (_selectedService == null) return 0.0;
    if (_selectedPartOption != null) {
      return _selectedPartOption!.price;
    }
    return _selectedService!.basePrice;
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
      _selectedPartOption = service.partOptions.firstWhere((p) => p.isPopular, orElse: () => service.partOptions.first);
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

  bool _isFetching = false;
  bool get isFetching => _isFetching;
  
  Timer? _pollingTimer;

  // Fetch Bookings from backend (Real Database Data)
  Future<void> fetchBookings() async {
    if (_isFetching) return;
    _isFetching = true;
    notifyListeners();
    try {
      final remoteList = await ApiService.getBookings();
      _bookings.clear();
      _bookings.addAll(remoteList);
    } catch (_) {}
    _isFetching = false;
    notifyListeners();
  }

  // ── Real-time polling for booking updates ─────────────────────────
  void startPolling() {
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
  
  void _addWarrantyForBooking(Booking updated) {
      final exists = _warranties.any((w) => w.bookingId == updated.id);
      if(!exists) {
        _warranties.insert(
          0,
          Warranty(
            id: 500 + updated.id,
            bookingId: updated.id,
            customerId: updated.customerId,
            serviceName: updated.serviceName,
            deviceModelName: updated.modelName,
            startDate: '2026-09-26',
            endDate: '2027-03-26',
            daysRemaining: 180,
            status: 'active',
          ),
        );
      }
  }

  // Create Booking with real customer info
  Booking createBooking({
    String? customerName,
    String? customerPhone,
    int? customerId,
    String? technicianName,
    String? technicianPhone,
    int? technicianId,
  }) {
    int newId = 1000 + _bookings.length + 1;
    String bNum = 'IFX-${(80000 + newId)}';

    final realCustomerName = (customerName != null && customerName.trim().isNotEmpty)
        ? customerName.trim()
        : 'Customer';
    final realCustomerPhone = (customerPhone != null && customerPhone.trim().isNotEmpty)
        ? customerPhone.trim()
        : '+91 98765 43210';

    Booking newBooking = Booking(
      id: newId,
      bookingNumber: bNum,
      customerId: customerId ?? 1,
      customerName: realCustomerName,
      customerPhone: realCustomerPhone,
      technicianId: technicianId ?? 2,
      technicianName: technicianName ?? 'Vikram Singh (Assigned)',
      technicianPhone: technicianPhone ?? '+91 91234 56789',
      deviceCategory: _selectedCategory?.name ?? 'Smartphones',
      brandName: _selectedBrand?.name ?? 'Apple',
      modelName: _selectedModel?.name ?? 'iPhone 15 Pro',
      serviceName: _selectedService?.name ?? 'Screen Replacement',
      partOptionName: _selectedPartOption?.name ?? 'Original OEM Display',
      addressLine: _selectedAddress,
      scheduledSlot: _selectedDateSlot,
      status: 'CONFIRMED',
      estimateAmount: totalPrice,
      finalAmount: totalPrice,
      paymentStatus: 'PENDING',
      createdAt: 'Just now',
    );

    _bookings.insert(0, newBooking);
    notifyListeners();

    // Async sync with Live Backend Database
    _syncBookingToBackend(newBooking);

    return newBooking;
  }

  void _syncBookingToBackend(Booking b) async {
    try {
      await ApiService.createRemoteBooking({
        'booking_number': b.bookingNumber,
        'brand_name': b.brandName,
        'model_name': b.modelName,
        'service_name': b.serviceName,
        'estimated_cost': b.estimateAmount,
        'final_amount': b.finalAmount,
        'customer_name': b.customerName,
        'customer_phone': b.customerPhone,
        'customer_address': b.addressLine,
        'time_slot': b.scheduledSlot,
        'status': b.status,
      });
    } catch (_) {}
  }

  // Customer approves/rejects extra work diagnostic
  void respondToApproval(int bookingId, bool approved) {
    int idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      Booking current = _bookings[idx];
      if (current.diagnostic != null) {
        var diag = current.diagnostic!;
        double addAmt = diag.additionalAmount ?? 0.0;
        double newFinal = approved ? (current.estimateAmount + addAmt) : current.estimateAmount;

        Booking updated = current.copyWith(
          status: approved ? 'REPAIRING' : 'REPAIRING', // continue repair with/without extra work
          additionalAmount: approved ? addAmt : 0.0,
          finalAmount: newFinal,
          diagnostic: diag,
        );
        _bookings[idx] = updated;
        notifyListeners();
      }
    }
  }

  // File Warranty Claim
  void fileWarrantyClaim(int warrantyId, String description) {
    int claimId = 900 + _warrantyClaims.length + 1;
    _warrantyClaims.add(WarrantyClaim(
      id: claimId,
      warrantyId: warrantyId,
      description: description,
      status: 'pending',
      createdAt: 'Just now',
    ));
    notifyListeners();
  }

  // Sync external booking update (from technician)
  void updateBooking(Booking updated) {
    int idx = _bookings.indexWhere((b) => b.id == updated.id);
    if (idx != -1) {
      _bookings[idx] = updated;

      // Sync status to Live Backend Database
      ApiService.updateRemoteBookingStatus(updated.id, updated.status);

      // If completed, add warranty automatically
      if (updated.status == 'COMPLETED') {
        _warranties.insert(
          0,
          Warranty(
            id: 500 + updated.id,
            bookingId: updated.id,
            customerId: updated.customerId,
            serviceName: updated.serviceName,
            deviceModelName: updated.modelName,
            startDate: '2026-09-26',
            endDate: '2027-03-26',
            daysRemaining: 180,
            status: 'active',
          ),
        );
      }

      notifyListeners();
    }
  }
}
