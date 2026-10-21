import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DiagnosisApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Options> _authOptions() async {
    final token = await _storage.read(key: 'jwt_token');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // US-048, US-049, US-051..US-054: Gửi ảnh chẩn đoán AI & Grad-CAM
  Future<Map<String, dynamic>> scanAndDiagnose({
    required Uint8List imageBytes,
    required String filename,
    String? plantId,
  }) async {
    final opts = await _authOptions();
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(imageBytes, filename: filename),
      if (plantId != null) 'plant_id': plantId,
    });

    final response = await _dio.post('/diagnosis/predict', data: formData, options: opts);
    return response.data;
  }

  // US-047, US-057: Gửi phản hồi kết quả chưa đúng (Active Learning)
  Future<Map<String, dynamic>> submitFeedback({
    required String diagnosisId,
    required String predictedDisease,
    required String userCorrectedDisease,
    required String feedbackNotes,
  }) async {
    final opts = await _authOptions();
    final response = await _dio.post('/diagnosis/feedback', options: opts, data: {
      'diagnosis_id': diagnosisId,
      'predicted_disease': predictedDisease,
      'user_corrected_disease': userCorrectedDisease,
      'feedback_notes': feedbackNotes,
    });
    return response.data;
  }
}
