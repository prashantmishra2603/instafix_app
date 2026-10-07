import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String _targetContact = '';
  bool _isEmailOtp = true;
  String _selectedRole = 'customer';
  String? _lastError;

  // Server wake-up state
  bool _isWakingServer = false;
  int _wakeUpElapsed = 0;

  // Temporary signup data during OTP verification
  Map<String, dynamic>? _pendingSignupData;

  AuthProvider({User? initialUser}) : _currentUser = initialUser;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String get targetContact => _targetContact;
  bool get isEmailOtp => _isEmailOtp;
  String get selectedRole => _selectedRole;
  String? get lastError => _lastError;
  bool get isWakingServer => _isWakingServer;
  int get wakeUpElapsed => _wakeUpElapsed;

  void setSelectedRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  void setTargetContact(String contact, {bool isEmail = true}) {
    _targetContact = contact;
    _isEmailOtp = isEmail;
    notifyListeners();
  }

  // ─── Server wake-up flow ─────────────────────────────────────────────────
  Future<bool> _handleColdStart() async {
    _isWakingServer = true;
    _wakeUpElapsed = 0;
    notifyListeners();

    final ok = await ApiService.wakeUpServer(
      onProgress: (elapsed) {
        _wakeUpElapsed = elapsed;
        notifyListeners();
      },
    );

    _isWakingServer = false;
    notifyListeners();
    return ok;
  }

  // ─── Login via Email & Password ──────────────────────────────────────────
  Future<bool> loginWithEmail(
      String email, String password, String role) async {
    _isLoading = true;
    _lastError = null;
    _isWakingServer = false;
    _selectedRole = role;
    notifyListeners();

    var result = await ApiService.loginWithEmail(email, password, role);

    // Server was sleeping — wake it up and retry once
    if (result['error'] == 'server_cold_start') {
      final woke = await _handleColdStart();
      if (woke) {
        _isLoading = true;
        notifyListeners();
        result = await ApiService.loginWithEmail(email, password, role);
      } else {
        _lastError = 'Server is unavailable. Please try again in a moment.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    }

    final User? user = result['user'] as User?;

    if (user != null && result['success'] == true) {
      _currentUser = user;
      _isLoading = false;
      await _saveUserLocally(user);
      notifyListeners();
      return true;
    }

    _lastError = result['error'] as String? ?? 'Login failed. Please try again.';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── Initiate OTP sending ────────────────────────────────────────────────
  Future<bool> sendOtp(
    String contact, {
    bool isEmail = true,
    Map<String, dynamic>? signupData,
  }) async {
    _isLoading = true;
    _lastError = null;
    _isWakingServer = false;
    _targetContact = contact;
    _isEmailOtp = isEmail;

    if (signupData != null) {
      _pendingSignupData = signupData;
      if (signupData.containsKey('role')) {
        _selectedRole = signupData['role'];
      }
    }

    notifyListeners();

    bool success = await ApiService.sendOtp(contact, isEmail: isEmail);

    if (!success) {
      // Try waking server and retry
      final woke = await _handleColdStart();
      if (woke) {
        _isLoading = true;
        notifyListeners();
        success = await ApiService.sendOtp(contact, isEmail: isEmail);
      }
    }

    if (!success) {
      _lastError = 'Failed to send OTP. Server may be starting up, please retry.';
    }

    _isLoading = false;
    notifyListeners();

    return success;
  }

  // ─── Direct Instant Signup (Live Backend Database) ───────────────────────────
  Future<bool> signupDirect({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? address,
    String role = 'customer',
  }) async {
    _isLoading = true;
    _lastError = null;
    _isWakingServer = false;
    _selectedRole = role;
    notifyListeners();

    var result = await ApiService.registerUser(
      name: name,
      email: email,
      phone: phone,
      password: password,
      role: role,
      address: address,
    );

    // If server was sleeping, wake it up and retry
    if (result['error'] == 'server_cold_start') {
      final woke = await _handleColdStart();
      if (woke) {
        _isLoading = true;
        notifyListeners();
        result = await ApiService.registerUser(
          name: name,
          email: email,
          phone: phone,
          password: password,
          role: role,
          address: address,
        );
      } else {
        _lastError = 'Server is booting up. Please try again in a moment.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    }

    final User? user = result['user'] as User?;
    if (user != null && result['success'] == true) {
      _currentUser = user;
      _isLoading = false;
      await _saveUserLocally(user);
      notifyListeners();
      return true;
    }

    _lastError = result['error'] as String? ?? 'Registration failed. Please try again.';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── Store Signup Data without sending OTP (for demo OTP flow) ─────────────
  void setPendingSignupData({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? address,
    String role = 'customer',
  }) {
    _pendingSignupData = {
      'role': role,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'address': address,
    };
    _selectedRole = role;
    _targetContact = email;
    _isEmailOtp = true;
    notifyListeners();
  }

  bool get hasPendingSignup => _pendingSignupData != null;

  // ─── Submit Signup Data (via OTP flow) ──────────────────────────────────
  Future<bool> initiateSignup({
    required String role,
    required String name,
    required String email,
    required String phone,
    required String password,
    String? shopName,
    String? skills,
    String? address,
  }) async {
    // Store data locally — no API call needed, OTP is demo (1234)
    _pendingSignupData = {
      'role': role,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'shop_name': shopName,
      'skills': skills,
      'address': address,
    };
    _selectedRole = role;
    _targetContact = email;
    _isEmailOtp = true;
    notifyListeners();
    return true;
  }

  // ─── Verify OTP ──────────────────────────────────────────────────────────
  Future<bool> verifyOtp(String otp) async {
    // Demo: OTP is always 1234
    if (otp != '1234') {
      _lastError = 'Invalid OTP. Use 1234 for demo.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    if (_pendingSignupData != null) {
      // Register on backend after OTP verified
      var result = await ApiService.registerUser(
        name: _pendingSignupData!['name'] ?? 'User',
        email: _pendingSignupData!['email'],
        phone: _pendingSignupData!['phone'] ?? '',
        password: _pendingSignupData!['password'] ?? '123456',
        role: _pendingSignupData!['role'] ?? _selectedRole,
        shopName: _pendingSignupData!['shop_name'],
        skills: _pendingSignupData!['skills'],
        address: _pendingSignupData!['address'],
      );

      if (result['error'] == 'server_cold_start') {
        final woke = await _handleColdStart();
        if (woke) {
          _isLoading = true;
          notifyListeners();
          result = await ApiService.registerUser(
            name: _pendingSignupData!['name'] ?? 'User',
            email: _pendingSignupData!['email'],
            phone: _pendingSignupData!['phone'] ?? '',
            password: _pendingSignupData!['password'] ?? '123456',
            role: _pendingSignupData!['role'] ?? _selectedRole,
            shopName: _pendingSignupData!['shop_name'],
            skills: _pendingSignupData!['skills'],
            address: _pendingSignupData!['address'],
          );
        } else {
          _lastError = 'Server is unavailable. Please try again in a moment.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      final User? user = result['user'] as User?;
      _pendingSignupData = null;

      if (user != null && result['success'] == true) {
        _currentUser = user;
        _isLoading = false;
        await _saveUserLocally(user);
        notifyListeners();
        return true;
      }

      _lastError = result['error'] as String? ?? 'Registration failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // No pending signup — OTP verified, nothing else to do
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> _saveUserLocally(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user.id);
    await prefs.setString('user_role', user.role);
    await prefs.setString('user_name', user.name);
    if (user.email != null) await prefs.setString('user_email', user.email!);
    if (user.phone.isNotEmpty) await prefs.setString('user_phone', user.phone);
    if (user.shopName != null) await prefs.setString('shop_name', user.shopName!);
    if (user.address != null) await prefs.setString('user_address', user.address!);
    if (user.token != null) await prefs.setString('auth_token', user.token!);
  }

  // Quick switch role for testing in demo
  void switchRole(String role) {
    _selectedRole = role;

    if (_currentUser != null) {
      _currentUser = User(
        id: _currentUser!.id,
        name: _currentUser!.name.isNotEmpty ? _currentUser!.name : (role == 'technician' ? 'Technician' : 'Customer'),
        phone: _currentUser!.phone.isNotEmpty ? _currentUser!.phone : '9876543210',
        email: _currentUser!.email ?? (role == 'technician' ? 'tech@instafix.com' : 'user@instafix.com'),
        role: role,
        shopName: _currentUser!.shopName ?? (role == 'technician' ? 'Express Mobile Care & Repair' : null),
        skills: _currentUser!.skills ?? (role == 'technician' ? 'Display Replacement, Motherboard Repair' : null),
        token: _currentUser!.token,
      );
    }

    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _pendingSignupData = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }
}