import 'package:flutter/material.dart';
import 'package:urban_plants/core/theme.dart';
import 'package:urban_plants/features/diagnosis/screens/ai_camera_scanner_screen.dart';

class ExpertConsultationScreen extends StatelessWidget {
  const ExpertConsultationScreen({super.key});

  final List<Map<String, dynamic>> _experts = const [
    {
      'id': 'exp_01',
      'name': 'Kỹ sư Trần Anh Dũng',
      'title': 'Chuyên gia Bệnh Cây Đô Thị & Hoa Hồng',
      'exp': '12 năm kinh nghiệm',
      'rating': 4.98,
      'reviews': 342,
      'fee': '99.000 đ / 30 phút',
      'slots': ['09:00', '10:30', '14:30', '16:00'],
    },
    {
      'id': 'exp_02',
      'name': 'Thạc sĩ Lê Thu Thảo',
      'title': 'Chuyên gia Kiểng Lá & Sen Đá Ban Công',
      'exp': '8 năm kinh nghiệm',
      'rating': 4.95,
      'reviews': 215,
      'fee': '99.000 đ / 30 phút',
      'slots': ['08:30', '11:00', '15:00', '17:30'],
    },
  ];

  void _showMaintenanceNotice(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.construction, color: Colors.deepOrange, size: 26),
            SizedBox(width: 8),
            Text('Thông Báo Bảo Trì', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        content: const Text(
          'Hệ thống Video Call 1-1 với Chuyên gia nông nghiệp hiện đang trong quá trình bảo trì và nâng cấp đường truyền máy chủ.\n\nTính năng sẽ sớm mở lại. Trong thời gian này, vui lòng sử dụng Chẩn đoán AI Grad-CAM hoặc Trợ lý Giọng nói để được hỗ trợ tức thì.',
          style: TextStyle(fontSize: 13, height: 1.45, color: Color(0xFF334155)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AICameraScannerScreen()),
              );
            },
            icon: const Icon(Icons.camera_alt, size: 16),
            label: const Text('Dùng Quét AI Thay Thế'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text('Tư Vấn 1-1 Với Chuyên Gia'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner nổi bật: ĐANG BẢO TRÌ HỆ THỐNG (US-087 Constraint)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber.shade400, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.engineering, color: Colors.deepOrange, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'ĐANG BẢO TRÌ HỆ THỐNG',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tính năng kết nối Video Call 1-1 đang được nâng cấp máy chủ truyền phát WebRTC độ trễ thấp.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            const Text('Danh sách Chuyên gia Nông Nghiệp Đô Thị:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),

            ..._experts.map((exp) => Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 26,
                              backgroundColor: AppTheme.mintSurface,
                              child: Icon(Icons.psychology, color: AppTheme.primaryGreen, size: 30),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(exp['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  Text(exp['title'], style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 14),
                                      const SizedBox(width: 2),
                                      Text('${exp['rating']} (${exp['reviews']} đánh giá)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      Text('• ${exp['exp']}', style: const TextStyle(fontSize: 11, color: AppTheme.neutralMuted)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              exp['fee'],
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange, fontSize: 14),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade400,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _showMaintenanceNotice(context),
                              icon: const Icon(Icons.lock, size: 14),
                              label: const Text('Đặt Lịch (Bảo Trì)', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
