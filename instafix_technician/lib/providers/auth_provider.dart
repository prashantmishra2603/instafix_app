import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  bool _isRestoring = true; // true while checking saved session
  String _targetContact = '';
  bool _isEmailOtp = true;
  String _selectedRole = 'technician';
  String? _lastError;
  bool _isWakingServer = false;
  int _wakeUpElapsed = 0;
  Map<String, dynamic>? _pendingSignupData;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isRestoring => _isRestoring;
  bool get isAuthenticated => _currentUser != null;
  String get targetContact => _targetContact;
  bool get isEmailOtp => _isEmailOtp;
  String get selectedRole => _selectedRole;
  String? get lastError => _lastError;
  bool get isWakingServer => _isWakingServer;
  int get wakeUpElapsed => _wakeUpElapsed;

  AuthProvider() {
    _restoreSession();
  }

  // ── Restore saved session on app start ──────────────────────────────────
  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final role  = prefs.getString('user_role') ?? 'technician';
      final name  = prefs.getString('user_name') ?? '';
      final email = prefs.getString('user_email');
      final phone = prefs.getString('user_phone') ?? '';
      final shop  = prefs.getString('shop_name');
      final skills = prefs.getString('user_skills');
      final address = prefs.getString('user_address');
      final id    = prefs.getInt('user_id') ?? 0;

      if (token != null && token.isNotEmpty && role == 'technician') {
        ApiService.authToken = token;
        _currentUser = User(
          id: id,
          name: name,
          phone: phone,
          email: email,
          role: role,
          shopName: shop,
          skills: skills,
          address: address,
          token: token,
        );
      }
    } catch (_) {}
    _isRestoring = false;
    notifyListeners();
  }

  void setSelectedRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  void setTargetContact(String contact, {bool isEmail = true}) {
    _targetContact = contact;
    _isEmailOtp = isEmail;
    notifyListeners();
  }

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

  Future<bool> loginWithEmail(String email, String password, String role) async {
    _isLoading = true;
    _lastError = null;
    _selectedRole = role;
    notifyListeners();

    var result = await ApiService.loginWithEmail(email, password, role);

    if (result['error'] == 'server_cold_start') {
      final woke = await _handleColdStart();
      if (woke) {
        _isLoading = true;
        notifyListeners();
        result = await ApiService.loginWithEmail(email, password, role);
      } else {
        _lastError = 'Server is unavailable. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    }

    final User? user = result['user'] as User?;
    if (user != null && result['success'] == true) {
      _currentUser = user;
      _isLoading = false;
      await _saveSession(user);
      notifyListeners();
      return true;
    }

    _lastError = result['error'] as String? ?? 'Login failed.';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> sendOtp(String contact, {bool isEmail = true, Map<String, dynamic>? signupData}) async {
    _isLoading = true;
    _lastError = null;
    _targetContact = contact;
    _isEmailOtp = isEmail;
    if (signupData != null) {
      _pendingSignupData = signupData;
      if (signupData.containsKey('role')) _selectedRole = signupData['role'];
    }
    notifyListeners();

    bool success = await ApiService.sendOtp(contact, isEmail: isEmail);
    if (!success) {
      final woke = await _handleColdStart();
      if (woke) {
        _isLoading = true;
        notifyListeners();
        success = await ApiService.sendOtp(contact, isEmail: isEmail);
      }
    }
    if (!success) _lastError = 'Failed to send OTP. Please retry.';
    _isLoading = false;
    notifyListeners();
    return success;
  }

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
    _pendingSignupData = {
      'role': role, 'name': name, 'email': email, 'phone': phone,
      'password': password, 'shop_name': shopName, 'skills': skills, 'address': address,
    };
    _selectedRole = role;
    return await sendOtp(email, isEmail: true, signupData: _pendingSignupData);
  }

  Future<bool> verifyOtp(String otp) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    User? user;
    Map<String, dynamic> result;

    if (_pendingSignupData != null) {
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
          _lastError = 'Server unavailable. Please try again.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }
      user = result['user'] as User?;
      _pendingSignupData = null;
    } else {
      result = await ApiService.verifyOtp(_targetContact, otp, _selectedRole);
      user = result['user'] as User?;
    }

    if (user != null && result['success'] == true) {
      _currentUser = user;
      _isLoading = false;
      await _saveSession(user);
      notifyListeners();
      return true;
    }

    _lastError = result['error'] as String? ?? 'OTP verification failed.';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> _saveSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user.token != null) await prefs.setString('auth_token', user.token!);
    await prefs.setString('user_role', user.role);
    await prefs.setString('user_name', user.name);
    await prefs.setInt('user_id', user.id);
    if (user.email != null) await prefs.setString('user_email', user.email!);
    if (user.phone.isNotEmpty) await prefs.setString('user_phone', user.phone);
    if (user.shopName != null) await prefs.setString('shop_name', user.shopName!);
    if (user.skills != null) await prefs.setString('user_skills', user.skills!);
    if (user.address != null) await prefs.setString('user_address', user.address!);
  }

  void switchRole(String role) {
    _selectedRole = role;
    if (_currentUser != null) {
      _currentUser = User(
        id: _currentUser!.id,
        name: _currentUser!.name,
        phone: _currentUser!.phone,
        email: _currentUser!.email,
        role: role,
        shopName: _currentUser!.shopName,
        skills: _currentUser!.skills,
        token: _currentUser!.token,
      );
    }
    notifyListeners();
  }

  // ── Update Profile (name, phone, shop, skills, address — email not editable) ──
  Future<bool> updateProfile({
    required String name,
    required String phone,
    String? shopName,
    String? skills,
    String? address,
  }) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.updateProfile(
        name: name,
        phone: phone,
        shopName: shopName,
        skills: skills,
        address: address,
      );

      if (result['success'] == true) {
        _currentUser = User(
          id: _currentUser!.id,
          name: name,
          phone: phone,
          email: _currentUser!.email,
          role: _currentUser!.role,
          shopName: shopName?.isNotEmpty == true ? shopName : _currentUser!.shopName,
          skills: skills?.isNotEmpty == true ? skills : _currentUser!.skills,
          address: address?.isNotEmpty == true ? address : _currentUser!.address,
          profileImage: _currentUser!.profileImage,
          token: _currentUser!.token,
        );
        await _saveSession(_currentUser!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    _pendingSignupData = null;
    ApiService.authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
