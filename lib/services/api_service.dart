import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../models/login_result.dart';
import '../models/medicine.dart';
import '../models/notification_item.dart';
import '../models/user_profile.dart';
import 'http_client.dart';

class ApiService {
  ApiService._();

  // URL storage untuk akses file gambar dari Laravel.
  static String get storageUrl => ApiConfig.storageUrl;

  // Auth 

  // Login buyer dan simpan token jika berhasil.
  static Future<LoginResult> loginPembeli(String phone, String password) async {
    try {
      final response = await HttpClient.post(
        '/login-pembeli',
        authenticated: false,
        body: {'no_hp': phone, 'password': password},
      );

      final Map<String, dynamic> data = response.body.isNotEmpty
          ? json.decode(response.body)
          : {};

      if (response.statusCode == 200) {
        final String token = data['token'];
        await HttpClient.saveToken(token);

        return LoginResult(
          success: true,
          token: token,
          message: data['message'] ?? 'Login berhasil',
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode == 429) {
        return LoginResult(
          success: false,
          message: data['message'] ??
              'Terlalu banyak percobaan login. Silakan coba lagi nanti.',
          retryAfterSeconds: data['retry_after_seconds'] ?? 60,
          statusCode: response.statusCode,
        );
      }

      return LoginResult(
        success: false,
        message: data['message'] ?? 'Nomor HP atau Password salah.',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('Error Login: $e');
      return const LoginResult(
        success: false,
        message: 'Gagal terhubung ke server.',
        statusCode: 500,
      );
    }
  }

  /// Register buyer baru.
  static Future<bool> registerPembeli(
    String name,
    String phone,
    String password,
  ) async {
    try {
      final response = await HttpClient.post(
        '/register-pembeli',
        authenticated: false,
        body: {'username': name, 'no_hp': phone, 'password': password},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error Register: $e');
      return false;
    }
  }

  // OTP & Password 

  /// Kirim OTP ke nomor HP yang terdaftar.
  static Future<bool> requestOtp(String phone) async {
    try {
      final response = await HttpClient.post(
        '/request-otp',
        authenticated: false,
        body: {'no_hp': phone},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error Request OTP: $e');
      return false;
    }
  }

  /// Reset password menggunakan OTP.
  static Future<bool> resetPassword(
    String phone,
    String otp,
    String newPassword,
  ) async {
    try {
      final response = await HttpClient.post(
        '/reset-password',
        authenticated: false,
        body: {'no_hp': phone, 'otp': otp, 'new_password': newPassword},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error Reset Password: $e');
      return false;
    }
  }

  /// Ubah password user yang sedang login.
  static Future<bool> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    try {
      final response = await HttpClient.put(
        '/change-password',
        body: {'old_password': oldPassword, 'new_password': newPassword},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error Change Password: $e');
      return false;
    }
  }

  // Profile 

  /// Ambil data profil user yang sedang login.
  static Future<UserProfile?> getProfile() async {
    try {
      final response = await HttpClient.get('/me');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final profileData = data['user'] ?? data;
        return UserProfile.fromJson(profileData);
      }
      return null;
    } catch (e) {
      debugPrint('Error Profile: $e');
      return null;
    }
  }

  /// Update data profil user.
  static Future<bool> updateProfile(
    String nama,
    String tglLahir,
    String gender,
  ) async {
    try {
      final response = await HttpClient.put(
        '/profile',
        body: {
          'username': nama,
          'tanggal_lahir': tglLahir,
          'jenis_kelamin': gender,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error Update Profile: $e');
      return false;
    }
  }

  // ── Medicine ──────────────────────────────────────────────────────────

  /// Ambil daftar obat dengan filter pencarian dan kategori opsional.
  static Future<List<Medicine>> getMedicines({
    String? search,
    int? kategoriId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (kategoriId != null) {
        queryParams['kategori_id'] = kategoriId.toString();
      }

      final response = await HttpClient.get(
        '/obats',
        authenticated: false,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> rawList = data['data'] ?? [];
        return rawList.map((e) => Medicine.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error Fetch Medicines: $e');
      return [];
    }
  }

  // ── Notification ──────────────────────────────────────────────────────

  /// Ambil semua notifikasi user.
  static Future<List<NotificationItem>> getNotifications() async {
    try {
      final response = await HttpClient.get('/notifications');

      if (response.statusCode == 200) {
        final List<dynamic> rawList =
            json.decode(response.body)['data'] ?? [];
        return rawList.map((e) => NotificationItem.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error Fetch Notifications: $e');
      return [];
    }
  }

  /// Ambil jumlah notifikasi belum dibaca.
  static Future<int> getUnreadNotificationCount() async {
    try {
      final response = await HttpClient.get('/notifications/unread-count');

      if (response.statusCode == 200) {
        return json.decode(response.body)['unread_count'] ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Error Fetch Unread Count: $e');
      return 0;
    }
  }

  /// Tandai notifikasi sebagai sudah dibaca.
  static Future<bool> markNotificationAsRead(String id) async {
    try {
      final response = await HttpClient.patch('/notifications/$id');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error Mark as Read: $e');
      return false;
    }
  }

  // ── Order & Checkout ──────────────────────────────────────────────────

  /// Ambil semua pesanan user yang sedang login.
  static Future<List<dynamic>> getOrders() async {
    try {
      final response = await HttpClient.get('/orders');

      if (response.statusCode == 200) {
        return json.decode(response.body)['data'] ?? [];
      }
      return [];
    } catch (e) {
      debugPrint('Error Fetch Orders: $e');
      return [];
    }
  }

  /// Proses checkout ke Midtrans dan kembalikan snap token + order code.
  static Future<Map<String, dynamic>?> checkoutMidtrans(
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final response = await HttpClient.postJson(
        '/midtrans/checkout',
        body: {'items': items},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error Checkout: $e');
      return null;
    }
  }

  // ── Prescription ──────────────────────────────────────────────────────

  /// Upload foto resep dokter untuk obat keras.
  static Future<bool> uploadPrescription(
    String filePath,
    String obatId,
  ) async {
    try {
      final response = await HttpClient.uploadFile(
        '/prescriptions/upload',
        fileField: 'image',
        filePath: filePath,
        fields: {'obat_id': obatId},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error Upload: $e');
      return false;
    }
  }
}
