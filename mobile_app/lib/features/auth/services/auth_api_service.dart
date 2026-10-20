import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AuthApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Lưu trữ Token bảo mật
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> clearAuth() async {
    await _storage.deleteAll();
  }

  // US-007: Đăng ký
  Future<Map<String, dynamic>> register({
    String? email,
    String? phone,
    required String password,
    required String fullName,
    String? locationCity,
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'email': email,
      'phone': phone,
      'password': password,
      'full_name': fullName,
      'location_city': locationCity ?? 'TP. Hồ Chí Minh',
    });
    final data = response.data;
    if (data['access_token'] != null) {
      await saveToken(data['access_token']);
    }
    return data;
  }

  // Đăng nhập thường
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'identifier': identifier,
      'password': password,
    });
    final data = response.data;
    if (data['access_token'] != null) {
      await saveToken(data['access_token']);
    }
    return data;
  }

  // US-008: Đăng nhập Google / Apple ID
  Future<Map<String, dynamic>> oauthLogin({
    required String provider,
    required String idToken,
    String? email,
    String? fullName,
  }) async {
    final response = await _dio.post('/auth/oauth', data: {
      'provider': provider,
      'id_token': idToken,
      'email': email,
      'full_name': fullName,
    });
    final data = response.data;
    if (data['access_token'] != null) {
      await saveToken(data['access_token']);
    }
    return data;
  }

  // US-009: Quên mật khẩu qua OTP
  Future<String> requestForgotPasswordOTP(String email) async {
    final response = await _dio.post('/auth/forgot-password', data: {
      'email': email,
    });
    return response.data['message'];
  }

  Future<String> resetPasswordOTP({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    final response = await _dio.post('/auth/reset-password', data: {
      'email': email,
      'otp_code': otpCode,
      'new_password': newPassword,
    });
    return response.data['message'];
  }

  // US-011: Xác thực Sinh trắc học Local Auth (Vân tay / FaceID)
  Future<bool> authenticateWithBiometrics() async {
    final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

    if (!canAuthenticate) return false;

    return await _localAuth.authenticate(
      localizedReason: 'Vui lòng quét vân tay hoặc FaceID để mở khóa ứng dụng Urban Plants',
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: true,
      ),
    );
  }

  // US-013: Xóa vĩnh viễn tài khoản (Tiêu chuẩn CH Play)
  Future<bool> deleteAccountPermanently(String? password) async {
    final token = await getToken();
    final response = await _dio.delete(
      '/users/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
      data: {
        'confirm_text': 'XOA TAI KHOAN',
        'password': password,
      },
    );
    if (response.statusCode == 200) {
      await clearAuth();
      return true;
    }
    return false;
  }
}
