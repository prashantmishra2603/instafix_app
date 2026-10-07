import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/device.dart';
import '../models/service.dart';
import '../models/booking.dart';
import 'mock_data_service.dart';

class ApiService {
  // ✅ Render Live Backend URL
  static const String baseUrl = 'https://instafix-backend.onrender.com/api';

  static String? authToken;

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  // ─── Server Wake-Up Ping (Render free tier cold start) ───────────────────
  /// Pings the server with a lightweight request to check if container is active.
  /// Returns true when server responds OK, false if still sleeping.
  static Future<bool> pingServer() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/brands'), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));
      return res.statusCode >= 200 && res.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  /// Wakes the server up by polling until it responds (max 60 sec).
  /// Calls [onProgress] with elapsed seconds on each attempt.
  static Future<bool> wakeUpServer({
    void Function(int elapsedSeconds)? onProgress,
  }) async {
    final stopwatch = Stopwatch()..start();
    const maxWait = Duration(seconds: 60);

    while (stopwatch.elapsed < maxWait) {
      final ok = await pingServer();
      if (ok) return true;
      onProgress?.call(stopwatch.elapsed.inSeconds);
      await Future.delayed(const Duration(seconds: 3));
    }
    return false;
  }

  // ─── Auth: Email & Password Login ──────────────────────────────────────────
  static Future<Map<String, dynamic>> loginWithEmail(
      String email, String password, String selectedRole) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: headers,
            body: jsonEncode({
              'email': email.trim().toLowerCase(),
              'password': password,
              'role': selectedRole,
            }),
          )
          .timeout(const Duration(seconds: 40));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        authToken = data['token'];
        final user = User.fromJson(data['user'], token: authToken);
        return {'success': true, 'user': user, 'source': 'real_db'};
      }

      final body = jsonDecode(res.body);
      String msg = 'Invalid email or password.';
      if (body['errors'] != null) {
        final errors = body['errors'] as Map<String, dynamic>;
        msg = errors.values.first[0];
      } else if (body['message'] != null) {
        msg = body['message'];
      }
      return {'success': false, 'user': null, 'error': msg, 'source': 'real_db'};
    } on Exception catch (e) {
      final isConnErr = e.toString().contains('TimeoutException') ||
          e.toString().contains('timeout') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup');

      if (isConnErr) {
        return {'success': false, 'user': null, 'error': 'server_cold_start', 'source': 'no_network'};
      }
      return {'success': false, 'user': null, 'error': 'Login failed. Please check internet connection.', 'source': 'error'};
    }
  }

  // ─── Auth: Register new user (Stores in real database) ─────────────────────
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
    String? shopName,
    String? skills,
    String? address,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: headers,
            body: jsonEncode({
              'name': name.trim(),
              'email': email.trim().toLowerCase(),
              'phone': phone.trim(),
              'password': password,
              'role': role,
              'shop_name': shopName,
              'skills': skills,
              'address': address?.trim(),
            }),
          )
          .timeout(const Duration(seconds: 40));

      if (res.statusCode == 201 || res.statusCode == 200) {
        final data = jsonDecode(res.body);
        authToken = data['token'];
        final user = User.fromJson(data['user'], token: authToken);
        return {'success': true, 'user': user};
      }

      final body = jsonDecode(res.body);
      String msg = 'Registration failed.';
      if (body['errors'] != null) {
        final errors = body['errors'] as Map<String, dynamic>;
        msg = errors.values.first[0];
      } else if (body['message'] != null) {
        msg = body['message'];
      }
      return {'success': false, 'user': null, 'error': msg};
    } on Exception catch (e) {
      final isConnErr = e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException') ||
          e.toString().contains('timeout') ||
          e.toString().contains('Failed host lookup');
      return {
        'success': false,
        'user': null,
        'error': isConnErr ? 'server_cold_start' : 'Registration failed. Please check internet connection.',
      };
    }
  }

  // ─── Auth: Send OTP ─────────────────────────────────────────────────────────
  static Future<bool> sendOtp(String contact, {bool isEmail = true}) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/send-otp'),
            headers: headers,
            body: jsonEncode({
              isEmail ? 'email' : 'phone': contact,
              'type': isEmail ? 'email' : 'phone',
            }),
          )
          .timeout(const Duration(seconds: 20));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─── Auth: Verify OTP ───────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> verifyOtp(
      String contact, String otp, String selectedRole) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/verify-otp'),
            headers: headers,
            body: jsonEncode({'contact': contact, 'otp': otp, 'role': selectedRole}),
          )
          .timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        authToken = data['token'];
        final user = User.fromJson(data['user'], token: authToken);
        return {'success': true, 'user': user, 'source': 'real_db'};
      }

      final body = jsonDecode(res.body);
      return {
        'success': false,
        'user': null,
        'error': body['message'] ?? 'Invalid OTP.',
        'source': 'real_db',
      };
    } catch (_) {
      return {
        'success': false,
        'user': null,
        'error': 'Server unreachable. Please check internet connection.',
        'source': 'no_network',
      };
    }
  }

  // ─── Fetch Brands ────────────────────────────────────────────────────────────
  static Future<List<Brand>> getBrands() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/brands'), headers: headers)
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list.map((item) => Brand.fromJson(item)).toList();
      }
    } catch (_) {}
    return MockDataService.brands;
  }

  // ─── Fetch Models ────────────────────────────────────────────────────────────
  static Future<List<DeviceModel>> getModels(int brandId) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/brands/$brandId/models'), headers: headers)
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list.map((item) => DeviceModel.fromJson(item)).toList();
      }
    } catch (_) {}
    return MockDataService.models.where((m) => m.brandId == brandId).toList();
  }

  // ─── Fetch Services ──────────────────────────────────────────────────────────
  static Future<List<RepairService>> getServices() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/services'), headers: headers)
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list.map((item) => RepairService.fromJson(item)).toList();
      }
    } catch (_) {}
    return MockDataService.services;
  }

  // ─── Bookings / Jobs API ───────────────────────────────────────────────────
  static Future<List<Booking>> getBookings() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/bookings'), headers: headers)
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final dynamic data = jsonDecode(res.body);
        final List list = data is List ? data : (data['data'] ?? []);
        return list.map((item) => Booking.fromJson(item)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>> createRemoteBooking(Map<String, dynamic> bookingData) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/bookings'),
            headers: headers,
            body: jsonEncode(bookingData),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200 || res.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(res.body)};
      }
      return {'success': false, 'error': res.body};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<bool> updateRemoteBookingStatus(int bookingId, String status) async {
    try {
      final res = await http
          .put(
            Uri.parse('$baseUrl/bookings/$bookingId/status'),
            headers: headers,
            body: jsonEncode({'status': status}),
          )
          .timeout(const Duration(seconds: 15));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
