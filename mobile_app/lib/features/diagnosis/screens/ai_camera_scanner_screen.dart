import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_plants/core/theme.dart';
import 'package:urban_plants/features/diagnosis/services/diagnosis_api_service.dart';
import 'package:urban_plants/features/diagnosis/screens/diagnosis_result_screen.dart';

class AICameraScannerScreen extends StatefulWidget {
  const AICameraScannerScreen({super.key});

  @override
  State<AICameraScannerScreen> createState() => _AICameraScannerScreenState();
}

class _AICameraScannerScreenState extends State<AICameraScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final DiagnosisApiService _apiService = DiagnosisApiService();

  bool _isProcessing = false;
  String? _warningMessage;

  // Xử lý ảnh chụp hoặc ảnh chọn từ thư viện
  Future<void> _processImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (file == null) return;

      setState(() {
        _isProcessing = true;
        _warningMessage = null;
      });

      final Uint8List imageBytes = await file.readAsBytes();

      // Gọi API chẩn đoán
      final result = await _apiService.scanAndDiagnose(
        imageBytes: imageBytes,
        filename: file.name,
      );

      if (!mounted) return;

      // US-050: Kiểm tra nếu ảnh bị cảnh báo chất lượng
      if (result['is_quality_valid'] == false) {
        final List warnings = result['quality_warnings'] ?? [];
        setState(() {
          _warningMessage = warnings.isNotEmpty
              ? warnings.join('\n')
              : 'Ảnh chưa đạt chuẩn (bị mờ hoặc thiếu sáng). Vui lòng chụp lại.';
        });
        return;
      }

      // Điều hướng sang màn hình kết quả chẩn đoán Explainable AI
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DiagnosisResultScreen(
            originalImageBytes: imageBytes,
            diagnosisData: result,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi quét chẩn đoán: $e'), backgroundColor: AppTheme.criticalRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Quét Bệnh AI (Explainable AI)'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // US-048: Khung ngắm Viewfinder lấy nét
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 280,
                  height: 320,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.secondaryGreen, width: 2.5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      // 4 góc chỉ dẫn
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Text(
                          '🌿 Căn giữa lá có đốm bệnh',
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Center(
                        child: Icon(
                          Icons.center_focus_strong,
                          size: 72,
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Khoảng cách tối ưu: 15 - 20cm • Đủ ánh sáng',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),

                // US-050: Hộp cảnh báo ảnh mờ/lỗi chất lượng
                if (_warningMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.yellow, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _warningMessage!,
                            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Loading Overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.secondaryGreen),
                    SizedBox(height: 16),
                    Text(
                      'AI đang phân tích mô bệnh học & tính toán Grad-CAM Heatmap...',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Bar Actions
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // US-049: Chọn ảnh có sẵn từ thư viện
                IconButton(
                  icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 36),
                  tooltip: 'Chọn ảnh từ thư viện',
                  onPressed: _isProcessing ? null : () => _processImage(ImageSource.gallery),
                ),

                // Nút chụp ảnh camera trực tiếp
                GestureDetector(
                  onTap: _isProcessing ? null : () => _processImage(ImageSource.camera),
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: AppTheme.primaryGreen,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 38),
                  ),
                ),

                // Nút đổi góc hoặc thông tin
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.white, size: 36),
                  tooltip: 'Hướng dẫn chụp',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Giữ máy ổn định, chụp ở điều kiện ánh sáng tự nhiên, tránh bóng râm đổ lên lá.'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
