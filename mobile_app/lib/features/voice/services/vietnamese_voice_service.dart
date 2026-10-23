import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class VietnameseVoiceService {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  double speechRate = 1.0; // 0.8x, 1.0x, 1.2x (US-073)
  bool isVoiceEnabled = true;

  // US-067, US-068, US-070: Phân tích khẩu lệnh tiếng Việt rảnh tay
  Future<Map<String, dynamic>> sendVoiceCommand(String transcript) async {
    final response = await _dio.post('/voice/command', data: {
      'transcript_text': transcript,
    });
    return response.data;
  }

  // US-072: Chuyển ghi âm giọng nói thành ghi chú nhật ký cây
  Future<Map<String, dynamic>> convertVoiceToLog(String transcript) async {
    final response = await _dio.post('/voice/convert-note', data: {
      'voice_transcript': transcript,
    });
    return response.data;
  }

  // US-069, US-073: Đọc to nội dung bằng giọng tiếng Việt (TTS Mockup/Interface)
  void speak(String text, {Function? onDone}) {
    if (!isVoiceEnabled) return;
    // Tích hợp flutter_tts hoặc gọi Web Speech Synthesis API
    debugPrint('[Vietnamese TTS (${speechRate}x)]: $text');
    if (onDone != null) onDone();
  }
}
