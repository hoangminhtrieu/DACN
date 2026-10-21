import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:urban_plants/core/theme.dart';
import 'package:urban_plants/features/diagnosis/services/diagnosis_api_service.dart';

class DiagnosisResultScreen extends StatefulWidget {
  final Uint8List originalImageBytes;
  final Map<String, dynamic> diagnosisData;

  const DiagnosisResultScreen({
    super.key,
    required this.originalImageBytes,
    required this.diagnosisData,
  });

  @override
  State<DiagnosisResultScreen> createState() => _DiagnosisResultScreenState();
}

class _DiagnosisResultScreenState extends State<DiagnosisResultScreen> {
  final DiagnosisApiService _apiService = DiagnosisApiService();
  double _heatmapOpacity = 0.65; // US-053: Giá trị thanh trượt độ trong suốt mặc định 65%

  Uint8List? _heatmapBytes;

  @override
  void initState() {
    super.initState();
    final String dataUrl = widget.diagnosisData['gradcam_heatmap_url'] ?? '';
    if (dataUrl.startsWith('data:image/jpeg;base64,')) {
      final base64Str = dataUrl.replaceFirst('data:image/jpeg;base64,', '');
      _heatmapBytes = base64Decode(base64Str);
    }
  }

  // US-057: Phản hồi kết quả chưa đúng
  void _showFeedbackDialog() {
    final correctedCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Phản Hồi Chẩn Đoán Chưa Đúng'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ý kiến thực tế của bạn sẽ được AI nạp vào kho Active Learning để tái huấn luyện giúp mô hình ngày càng thông minh hơn.',
                style: TextStyle(fontSize: 13, color: AppTheme.neutralMuted),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: correctedCtrl,
                decoration: const InputDecoration(labelText: 'Tên bệnh thực tế theo kinh nghiệm của bạn'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Mô tả thêm triệu chứng quan sát được'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _apiService.submitFeedback(
                diagnosisId: widget.diagnosisData['diagnosis_id'],
                predictedDisease: widget.diagnosisData['primary_prediction']['disease_name_vi'],
                userCorrectedDisease: correctedCtrl.text.trim(),
                feedbackNotes: notesCtrl.text.trim(),
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cảm ơn bạn! Đã gửi phản hồi về hệ thống Active Learning.'),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              }
            },
            child: const Text('Gửi phản hồi'),
          ),
        ],
      ),
    );
  }

  // US-055: Lưu vào bệnh án
  void _saveToMedicalRecord() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu kết quả quét AI vào Hồ sơ Bệnh án của chậu cây!'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
    Navigator.pop(context);
  }

  // US-056: Chia sẻ kết quả
  void _shareResult() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã tạo liên kết chia sẻ ảnh quét bệnh lên cộng đồng yêu cây!'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'CRITICAL':
        return AppTheme.criticalRed;
      case 'MEDIUM':
        return Colors.orange;
      default:
        return AppTheme.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.diagnosisData['primary_prediction'];
    final candidates = widget.diagnosisData['differential_candidates'] as List? ?? [];
    final confidencePercent = (primary['confidence'] * 100).toStringAsFixed(1);
    final String severity = primary['severity'] ?? 'LOW';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết Quả Chẩn Đoán AI (XAI)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Chia sẻ cộng đồng (US-056)',
            onPressed: _shareResult,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // US-052 & US-053: Khung ảnh tương tác Grad-CAM với thanh trượt Opacity
            Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ảnh gốc lá cây
                      Image.memory(
                        widget.originalImageBytes,
                        height: 260,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      // Bản đồ nhiệt Grad-CAM phủ lên với Opacity điều chỉnh được
                      if (_heatmapBytes != null)
                        Opacity(
                          opacity: _heatmapOpacity,
                          child: Image.memory(
                            _heatmapBytes!,
                            height: 260,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      // Badge chỉ dẫn
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Bản đồ nhiệt: ${(_heatmapOpacity * 100).toInt()}%',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // US-053: Thanh trượt Opacity
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Ảnh Gốc', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.neutralMuted)),
                            Text('Thanh trượt so sánh vùng nhiệt Grad-CAM', style: TextStyle(fontSize: 12, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
                            Text('Grad-CAM 100%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.neutralMuted)),
                          ],
                        ),
                        Slider(
                          value: _heatmapOpacity,
                          min: 0.0,
                          max: 1.0,
                          activeColor: AppTheme.primaryGreen,
                          onChanged: (val) => setState(() => _heatmapOpacity = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // US-051 & US-054: Thông tin chẩn đoán chính
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            primary['disease_name_vi'],
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.neutralDark),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getSeverityColor(severity).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Mức độ: $severity',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getSeverityColor(severity)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      primary['scientific_name'] ?? '',
                      style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppTheme.neutralMuted),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.verified, color: AppTheme.primaryGreen, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'Độ tin cậy ban đầu của AI: $confidencePercent%',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    // US-052: Câu mô tả tự động Explainable Text
                    const Text('Giải thích căn cứ chẩn đoán của AI:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      widget.diagnosisData['explanation_text'] ?? '',
                      style: const TextStyle(fontSize: 13, height: 1.4, color: AppTheme.neutralDark),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Top các bệnh tương đồng (Differential Candidates)
            if (candidates.isNotEmpty) ...[
              const Text('Các Bệnh Có Triệu Chứng Tương Đồng (Top 3)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...candidates.map((c) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(c['disease_name_vi'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text(c['scientific_name'], style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                    trailing: Text('${(c['confidence'] * 100).toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            // Action Buttons
            ElevatedButton.icon(
              onPressed: _saveToMedicalRecord,
              icon: const Icon(Icons.bookmark_add_outlined),
              label: const Text('Lưu vào Hồ sơ Bệnh án của Cây (US-055)'),
            ),
            const SizedBox(height: 10),

            // US-057: Nút phản hồi chưa đúng
            OutlinedButton.icon(
              onPressed: _showFeedbackDialog,
              icon: const Icon(Icons.feedback_outlined, color: Colors.deepOrange),
              label: const Text('Phản hồi kết quả chưa đúng (Active Learning)', style: TextStyle(color: Colors.deepOrange)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.deepOrange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
