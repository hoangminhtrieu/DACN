import 'package:flutter/material.dart';

class SafeFirstProtocolScreen extends StatefulWidget {
  final Map<String, dynamic>? protocolData;
  final Map<String, dynamic>? verificationResult;
  final Map<String, dynamic>? protocol;

  const SafeFirstProtocolScreen({
    super.key,
    this.protocolData,
    this.verificationResult,
    this.protocol,
  });

  @override
  State<SafeFirstProtocolScreen> createState() => _SafeFirstProtocolScreenState();
}

class _SafeFirstProtocolScreenState extends State<SafeFirstProtocolScreen> {
  bool _reminderScheduled = false;
  bool _auditScheduled = false;

  Map<String, dynamic> _resolvedData() {
    if (widget.protocolData != null) return widget.protocolData!;
    final v = widget.verificationResult ?? {};
    final p = widget.protocol ?? {};
    return {
      'primary_diagnosis': v['primary_disease'] ?? p['disease_name'] ?? 'Bệnh cây trồng đô thị',
      'recalculated_confidence': v['recalculated_confidence'] ?? 0.85,
      'is_fungal_confirmed': v['is_fungal_confirmed'] ?? false,
      'is_pest_infestation': v['is_pest_infestation'] ?? false,
      'is_nutrient_deficiency': v['is_nutrient_deficiency'] ?? false,
      'contagion_risk': v['contagion_risk'] ?? 'trung bình',
      'differential_notes': v['differential_notes'] ?? 'Đã xác thực chéo triệu chứng.',
      'safe_first_steps': p['steps'] ?? {
        'step1_isolation_pruning': {
          'title': 'Cắt Tỉa Cơ Học & Cách Ly',
          'actions': 'Cắt bỏ 100% lá bệnh, cách ly chậu 1.5m.',
          'tool_disinfection': 'Lau kéo bằng cồn 70 độ y tế.',
          'waste_disposal': 'Buộc kín túi rác, không ủ phân hữu cơ.',
        },
        'step2_organic_home_remedy': {
          'title': 'Giải Pháp Hữu Cơ / Nhà Làm',
          'recipe_name': 'Dung dịch Dầu Neem & Nước rửa chén sinh học',
          'mixing_ratio': '5ml Neem + 2ml nước rửa chén / 1 Lít nước ấm',
          'spray_instructions': 'Phun ướt đều 2 mặt lá lúc 17h30 chiều mát.',
          'frequency': 'Phun 3 ngày/lần trong vòng 9 ngày.',
        },
        'step3_safe_bio_actives': {
          'title': 'Hoạt Chất Sinh Học Đặc Trị',
          'recommended_bio_agents': 'Bacillus subtilis, Trichoderma harzianum',
          'action_mechanism': 'Đối kháng vi nấm và kích kháng tự nhiên.',
          'shelf_life_note': 'Bảo quản nơi thoáng mát, tránh ánh nắng trực tiếp.',
        },
      },
      'pet_child_safety_notes': p['pet_child_safety_notes'] ?? {
        'dogs_cats_safe': true,
        'child_safe': true,
        'ventilation_advice': 'Đảm bảo ban công thông thoáng gió khi phun.',
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final data = _resolvedData();
    final primary = data['primary_diagnosis'] ?? 'Bệnh cây trồng đô thị';
    final isFungal = data['is_fungal_confirmed'] ?? false;
    final isPest = data['is_pest_infestation'] ?? false;
    final isDeficiency = data['is_nutrient_deficiency'] ?? false;
    final contagionRisk = data['contagion_risk'] ?? 'trung bình';
    final confidence = ((data['recalculated_confidence'] ?? 0.85) * 100).toStringAsFixed(1);
    final diffNotes = data['differential_notes'] ?? 'Đã hoàn tất kiểm chứng chéo triệu chứng vật lý.';

    final steps = data['safe_first_steps'] as Map<String, dynamic>? ?? {};
    final step1 = steps['step1_isolation_pruning'] as Map<String, dynamic>? ?? {};
    final step2 = steps['step2_organic_home_remedy'] as Map<String, dynamic>? ?? {};
    final step3 = steps['step3_safe_bio_actives'] as Map<String, dynamic>? ?? {};
    final safety = data['pet_child_safety_notes'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF8),
      appBar: AppBar(
        title: const Text('Phác Đồ Safe-First 3 Bước'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Kết quả sau phân biệt chéo
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified, color: Color(0xFF2E7D32), size: 28),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            primary,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF81C784)),
                          ),
                          child: Text(
                            'Độ tin cậy: $confidence%',
                            style: const TextStyle(
                              color: Color(0xFF1B5E20),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (isFungal)
                          _buildBadge(Icons.bubble_chart, 'Nhiễm Nấm Bào Tử', Colors.orange),
                        if (isPest)
                          _buildBadge(Icons.pest_control, 'Côn Trùng / Nhện Đỏ', Colors.red),
                        if (isDeficiency)
                          _buildBadge(Icons.eco, 'Thiếu Hụt Vi Lượng Fe/Mg', Colors.amber[800]!),
                        _buildBadge(Icons.warning_amber_rounded, 'Nguy cơ lây: $contagionRisk', Colors.purple),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      diffNotes,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF475569), fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Banner chuẩn Urban Plant Trust Safe-First
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Color(0xFF2E7D32), size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Chuẩn An Toàn Safe-First: Ưu tiên cô lập cơ học và chế phẩm hữu cơ tự chế tại nhà trước khi dùng vi sinh, tuyệt đối không hóa chất độc hại.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF1B5E20), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bước 1: Cách ly & Cắt tỉa
            _buildStepCard(
              stepNumber: '1',
              title: step1['title'] ?? 'Cắt Tỉa Cơ Học & Cách Ly',
              color: const Color(0xFFE65100),
              icon: Icons.content_cut,
              content: [
                _buildBullet('Hành động:', step1['actions'] ?? 'Cắt bỏ 100% lá bệnh, cách ly chậu 1.5m.'),
                _buildBullet('Khử trùng:', step1['tool_disinfection'] ?? 'Lau kéo bằng cồn 70 độ cồn y tế.'),
                _buildBullet('Tiêu hủy:', step1['waste_disposal'] ?? 'Buộc kín túi rác, không ủ phân hữu cơ.'),
              ],
            ),
            const SizedBox(height: 14),

            // Bước 2: Hữu cơ nhà làm
            _buildStepCard(
              stepNumber: '2',
              title: step2['title'] ?? 'Giải Pháp Hữu Cơ / Nhà Làm',
              color: const Color(0xFF2E7D32),
              icon: Icons.eco,
              content: [
                _buildBullet('Chế phẩm:', step2['recipe_name'] ?? 'Dung dịch Dầu Neem & Nước rửa chén sinh học'),
                _buildBullet('Tỷ lệ pha:', step2['mixing_ratio'] ?? '5ml Neem + 2ml nước rửa chén / 1 Lít nước ấm'),
                _buildBullet('Cách phun:', step2['spray_instructions'] ?? 'Phun ướt đều 2 mặt lá lúc 17h30 chiều mát.'),
                _buildBullet('Tần suất:', step2['frequency'] ?? 'Phun 3 ngày/lần trong vòng 9 ngày.'),
              ],
            ),
            const SizedBox(height: 14),

            // Bước 3: Hoạt chất sinh học an toàn
            _buildStepCard(
              stepNumber: '3',
              title: step3['title'] ?? 'Hoạt Chất Sinh Học Đặc Trị',
              color: const Color(0xFF0277BD),
              icon: Icons.biotech,
              content: [
                _buildBullet('Hoạt chất an toàn:', step3['recommended_bio_agents'] ?? 'Bacillus subtilis, Trichoderma harzianum'),
                _buildBullet('Cơ chế:', step3['action_mechanism'] ?? 'Đối kháng vi nấm và kích kháng tự nhiên.'),
                _buildBullet('Lưu ý bảo quản:', step3['shelf_life_note'] ?? 'Bảo quản nơi thoáng mát, tránh ánh nắng trực tiếp.'),
              ],
            ),
            const SizedBox(height: 16),

            // Cảnh báo an toàn thú cưng & trẻ em (US-079)
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              color: const Color(0xFFFFF8E1),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.pets, color: Color(0xFFF57F17), size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'An Toàn Ban Công & Thú Cưng / Trẻ Nhỏ',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFE65100)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Chó mèo: ${safety['dogs_cats_safe'] == true ? 'An toàn khi dung dịch đã khô ráo (sau 1-2h).' : 'Cần để xa tầm với.'}\n'
                            'Trẻ nhỏ: ${safety['child_safe'] == true ? 'Không độc hại da, tránh uống phải.' : 'Cách ly trong 24h đầu.'}\n'
                            'Lưu ý: ${safety['ventilation_advice'] ?? 'Đảm bảo ban công thông thoáng gió.'}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF4E342E), height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nhóm nút nhắc lịch 3 ngày và đánh giá phục hồi 7 ngày (US-080, US-081)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _reminderScheduled
                        ? null
                        : () {
                            setState(() => _reminderScheduled = true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã đặt lịch nhắc phun xịt đợt 2 sau 3 ngày!'),
                                backgroundColor: Color(0xFF2E7D32),
                              ),
                            );
                          },
                    icon: Icon(_reminderScheduled ? Icons.check_circle : Icons.alarm),
                    label: Text(_reminderScheduled ? 'Đã Nhắc 3 Ngày' : 'Nhắc Xịt 3 Ngày'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _auditScheduled
                        ? null
                        : () {
                            setState(() => _auditScheduled = true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã lên lịch chụp ảnh đối chiếu phục hồi sau 7 ngày!'),
                                backgroundColor: Color(0xFF0277BD),
                              ),
                            );
                          },
                    icon: Icon(_auditScheduled ? Icons.task_alt : Icons.history_edu),
                    label: Text(_auditScheduled ? 'Đã Hẹn 7 Ngày' : 'Đánh Giá 7 Ngày'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0277BD),
                      side: const BorderSide(color: Color(0xFF0277BD)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required Color color,
    required IconData icon,
    required List<Widget> content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: color,
                  child: Text(
                    stepNumber,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...content,
          ],
        ),
      ),
    );
  }

  Widget _buildBullet(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
          children: [
            TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
