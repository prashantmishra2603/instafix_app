import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
  /// Pings the server with a lightweight health-check request.
  /// Returns true when server responds OK, false if still sleeping.
  static Future<bool> pingServer() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/health'), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 8));
      return res.statusCode == 200 || res.statusCode == 404; // 404 = server alive but route missing
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
      await Future.delayed(const Duration(seconds: 4));
    }
    return false;
  }

  // ─── Auth: Email & Password Login ──────────────────────────────────────────
  static Future<Map<String, dynamic>> loginWithEmail(
      String email, String password, String selectedRole) async {
    // Try once with a short timeout first
    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        final res = await http
            .post(
              Uri.parse('$baseUrl/auth/login'),
              headers: headers,
              body: jsonEncode({
                'email': email,
                'password': password,
                'role': selectedRole,
              }),
            )
            .timeout(Duration(seconds: attempt == 1 ? 12 : 25));

        // ✅ Real database login successful
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          authToken = data['token'];
          final user = User.fromJson(data['user'], token: authToken);
          return {'success': true, 'user': user, 'source': 'real_db'};
        }

        // ❌ Wrong credentials — 401 / 403 / 422 from server
        final body = jsonDecode(res.body);
        final msg = body['message'] ?? 'Invalid email or password.';
        return {'success': false, 'user': null, 'error': msg, 'source': 'real_db'};
      } on Exception catch (e) {
        final isTimeout = e.toString().contains('TimeoutException') ||
            e.toString().contains('timeout');
        final isConnErr = e.toString().contains('SocketException') ||
            e.toString().contains('Connection refused') ||
            e.toString().contains('Failed host lookup');

        if (isTimeout || isConnErr) {
          if (attempt < 2) {
            // Retry once more with longer timeout
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
          return {
            'success': false,
            'user': null,
            'error': 'server_cold_start', // Special code so UI can show wake-up screen
            'source': 'no_network',
          };
        }

        return {
          'success': false,
          'user': null,
          'error': 'Login failed: ${e.toString()}',
          'source': 'error',
        };
      }
    }
    return {'success': false, 'user': null, 'error': 'server_cold_start', 'source': 'no_network'};
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
    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        final res = await http
            .post(
              Uri.parse('$baseUrl/auth/register'),
              headers: headers,
              body: jsonEncode({
                'name': name,
                'email': email,
                'phone': phone,
                'password': password,
                'role': role,
                'shop_name': shopName,
                'skills': skills,
                'address': address,
              }),
            )
            .timeout(Duration(seconds: attempt == 1 ? 12 : 25));

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

        if (isConnErr && attempt < 2) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        return {
          'success': false,
          'user': null,
          'error': isConnErr ? 'server_cold_start' : 'Registration failed: ${e.toString()}',
        };
      }
    }
    return {'success': false, 'user': null, 'error': 'server_cold_start'};
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
    final reqHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken != null && authToken!.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };
    final endpoints = ['$baseUrl/technician/bookings', '$baseUrl/bookings'];
    for (final url in endpoints) {
      print('Fetching from: $url');
      try {
        final res = await http
            .get(Uri.parse(url), headers: reqHeaders)
            .timeout(const Duration(seconds: 15));
        print('Response status for $url: ${res.statusCode}');
        if (res.statusCode == 200) {
          final dynamic data = jsonDecode(res.body);
          final List list = data is List ? data : (data['data'] ?? data['bookings'] ?? []);
          print('Found ${list.length} bookings from $url');
          if (list.isNotEmpty) {
            try {
              final parsedList = list.map((item) => Booking.fromJson(Map<String, dynamic>.from(item))).toList();
              print('Successfully parsed bookings');
              return parsedList;
            } catch (e, stack) {
              print('Error parsing Booking.fromJson: $e\n$stack');
            }
          }
        } else {
          print('Error response: ${res.body}');
        }
      } catch (e, stack) {
        print('API Error for $url: $e\n$stack');
      }
    }
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

  static Future<bool> updateRemoteBookingStatus(
    int bookingId,
    String status, {
    int? technicianId,
    String? technicianName,
    String? technicianPhone,
  }) async {
    try {
      print('Updating booking $bookingId status to $status');
      final Map<String, dynamic> payload = {'status': status};
      if (technicianId != null) payload['technician_id'] = technicianId;
      if (technicianName != null) payload['technician_name'] = technicianName;
      if (technicianPhone != null) payload['technician_phone'] = technicianPhone;

      final res = await http
          .put(
            Uri.parse('$baseUrl/bookings/$bookingId/status'),
            headers: headers,
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));
      print('Update status response: ${res.statusCode} - ${res.body}');
      return res.statusCode == 200;
    } catch (e) {
      print('Update status error: $e');
      return false;
    }
  }

  // ─── Update Technician Profile ───────────────────────────────────────────
  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phone,
    String? shopName,
    String? skills,
    String? address,
  }) async {
    try {
      final res = await http
          .patch(
            Uri.parse('$baseUrl/auth/profile'),
            headers: headers,
            body: jsonEncode({
              'name': name,
              'phone': phone,
              if (shopName != null && shopName.isNotEmpty) 'shop_name': shopName,
              if (skills != null && skills.isNotEmpty) 'skills': skills,
              if (address != null && address.isNotEmpty) 'address': address,
            }),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        return {'success': true};
      }
      // Accept 404 (route may not exist yet) — still update locally
      return {'success': true, 'local_only': true};
    } catch (_) {
      // Network error — update profile locally anyway
      return {'success': true, 'local_only': true};
    }
  }

  // ─── KYC & Admin Payment Settings API ──────────────────────────────────────
  /// Fetches Admin UPI ID, QR code image URL, and ₹199 subscription fee
  static Future<Map<String, dynamic>> getPaymentSettings() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/kyc/payment-info'), headers: headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('getPaymentSettings error: $e');
    }
    return {
      'upi_id': 'instafix@okaxis',
      'qr_image_url': '',
      'kyc_fee': '199',
    };
  }

  /// Submits technician KYC documents and payment screenshot to the server
  static Future<Map<String, dynamic>> submitKycRemote({
    required int userId,
    required String aadhaarNumber,
    required String panNumber,
    required String bikeNumber,
    String? aadhaarFrontUrl,
    String? aadhaarBackUrl,
    String? panCardUrl,
    String? bikeRcUrl,
    String? paymentScreenshotUrl,
  }) async {
    try {
      final payload = {
        'user_id': userId,
        'aadhaar_number': aadhaarNumber,
        'pan_number': panNumber,
        'bike_number': bikeNumber,
        if (aadhaarFrontUrl != null) 'aadhaar_front_url': aadhaarFrontUrl,
        if (aadhaarBackUrl != null) 'aadhaar_back_url': aadhaarBackUrl,
        if (panCardUrl != null) 'pan_card_url': panCardUrl,
        if (bikeRcUrl != null) 'bike_rc_url': bikeRcUrl,
        if (paymentScreenshotUrl != null) 'payment_screenshot_url': paymentScreenshotUrl,
      };

      final res = await http
          .post(
            Uri.parse('$baseUrl/kyc/submit'),
            headers: headers,
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      if (res.statusCode == 200 || res.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(res.body)};
      }
      return {'success': false, 'error': res.body};
    } catch (e) {
      print('submitKycRemote error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Polls / checks current KYC verification status from backend
  static Future<Map<String, dynamic>?> fetchKycStatusRemote(int userId) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/kyc/status/$userId'), headers: headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('fetchKycStatusRemote error: $e');
    }
    return null;
  }

  /// Upload an image using raw bytes — works seamlessly across Flutter Web, Android, iOS.
  /// Returns the public URL of the uploaded image.
  static Future<String?> uploadImageBytes(
    Uint8List bytes, {
    required String fileName,
    String type = 'other',
  }) async {
    try {
      final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
      final mimeMap = {
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'png': 'image/png',
        'webp': 'image/webp',
        'gif': 'image/gif',
        'pdf': 'application/pdf',
        'heic': 'image/heic',
        'heif': 'image/heif',
      };
      final mimeStr = mimeMap[ext] ?? 'image/jpeg';
      final parts = mimeStr.split('/');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload/file'),
      );
      if (authToken != null) {
        request.headers['Authorization'] = 'Bearer $authToken';
      }
      request.fields['type'] = type;
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
        contentType: MediaType(parts[0], parts[1]),
      ));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['url'] != null) {
          return data['url'] as String;
        }
        print('uploadImageBytes: bad response: ${response.body}');
      } else {
        print('uploadImageBytes: HTTP ${response.statusCode} => ${response.body}');
      }
    } catch (e) {
      print('uploadImageBytes error: $e');
    }
    return null;
  }

  /// Backward-compatible alias that takes bytes or delegates.
  static Future<String?> uploadImageFile(String filePath, {String type = 'other', Uint8List? bytes, String? fileName}) async {
    if (bytes != null) {
      return uploadImageBytes(bytes, fileName: fileName ?? 'upload.jpg', type: type);
    }
    return null;
  }
}
