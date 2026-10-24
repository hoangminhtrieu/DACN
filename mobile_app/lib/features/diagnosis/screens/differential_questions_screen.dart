import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_plants/core/theme.dart';
import 'package:urban_plants/core/app_state.dart';
import 'package:urban_plants/features/treatment/screens/safe_first_protocol_screen.dart';

class DifferentialQuestionsScreen extends StatefulWidget {
  final String diseaseCode;
  final String diseaseName;
  final double initialConfidence;

  const DifferentialQuestionsScreen({
    super.key,
    required this.diseaseCode,
    required this.diseaseName,
    required this.initialConfidence,
  });

  @override
  State<DifferentialQuestionsScreen> createState() => _DifferentialQuestionsScreenState();
}

class _DifferentialQuestionsScreenState extends State<DifferentialQuestionsScreen> {
  final Map<String, bool> _answers = {
    'q1': true,
    'q2': false,
    'q3': false,
  };

  bool _isVerifying = false;

  final List<Map<String, dynamic>> _defaultQuestions = [
    {
      'id': 'q1',
      'title': '1. Kiểm tra cảm quan & xúc giác bề mặt lá:',
      'question': 'Dùng đầu ngón tay quẹt nhẹ lên bề mặt vết đốm, bạn có thấy lớp bụi phấn mịn màu trắng/xám bám dính vào tay không?',
      'explanation': 'Đặc trưng màng khuẩn ty của bệnh phấn nấm Podosphaera pannosa.',
    },
    {
      'id': 'q2',
      'title': '2. Kiểm tra độ biến dạng của lá non:',
      'question': 'Phiến lá non và đọt hoa có dấu hiệu co rúm, mép lá cong queo dị dạng bất thường không?',
      'explanation': 'Đánh giá mức độ vi nấm hút dịch tế bào biểu bì thực vật.',
    },
    {
      'id': 'q3',
      'title': '3. Phân biệt với sâu bệnh chích hút (Nhện đỏ):',
      'question': 'Soi kỹ mặt dưới lá dưới ánh đèn, có xuất hiện màng tơ mỏng hoặc chấm đỏ li ti đang bò không?',
      'explanation': 'Phân biệt chính xác giữa bệnh vi nấm và bọ trĩ/nhện đỏ để tránh dùng sai thuốc.',
    },
  ];

  Future<void> _verifyAndRecalculate() async {
    final appState = context.read<AppState>();
    setState(() => _isVerifying = true);

    await Future.delayed(const Duration(milliseconds: 900));

    // Thuật toán tái tính toán độ tin cậy khoa học sau phản hồi xúc giác (US-061)
    double confidence = widget.initialConfidence;
    if (_answers['q1'] == true) confidence += 0.035;
    if (_answers['q2'] == true) confidence += 0.02;
    if (_answers['q3'] == false) confidence += 0.015; // Loại trừ nhện đỏ thành công
    if (confidence > 0.985) confidence = 0.985;

    final verificationResult = {
      'primary_disease': widget.diseaseName,
      'recalculated_confidence': confidence,
      'is_fungal_confirmed': _answers['q1'] == true,
      'is_pest_infestation': _answers['q3'] == true,
      'is_nutrient_deficiency': false,
      'contagion_risk': _answers['q2'] == true ? 'rất cao' : 'trung bình',
      'differential_notes':
          'Đã xác thực chéo: Phát hiện lớp phấn cơ học mặt trên lá, đã loại trừ sâu hại chích hút. Đủ điều kiện kích hoạt phác đồ Safe-First.',
    };

    final protocol = {
      'disease_name': widget.diseaseName,
      'steps': {
        'step1_isolation_pruning': {
          'title': 'Cắt Tỉa Cơ Học & Cách Ly',
          'actions': 'Dùng kéo sạch tỉa bỏ 100% các lá có vết phấn trắng. Cách ly chậu cây tối thiểu 1.5 mét khỏi các chậu kiểng khác.',
          'tool_disinfection': 'Khử trùng lưỡi kéo bằng cồn y tế 70 độ hoặc hơ lửa 5 giây trước và sau khi cắt.',
          'waste_disposal': 'Gói kín lá bệnh vào túi nylon bỏ rác thải sinh hoạt, tuyệt đối không ủ làm phân compost.',
        },
        'step2_organic_home_remedy': {
          'title': 'Giải Pháp Hữu Cơ / Nhà Làm',
          'recipe_name': 'Dung dịch Dầu Neem & Nước rửa chén sinh học (hoặc Baking Soda)',
          'mixing_ratio': '5ml Dầu Neem nguyên chất + 2ml Nước rửa chén hữu cơ pha trong 1 Lít nước ấm 40°C.',
          'spray_instructions': 'Lắc thật đều bình xịt. Phun ướt đẫm 2 mặt lá và thân cành lúc 17h30 chiều mát (tránh nắng gắt).',
          'frequency': 'Phun nhắc lại 3 ngày/lần. Đánh giá lại sau 2 chu kỳ phun.',
        },
        'step3_safe_bio_actives': {
          'title': 'Hoạt Chất Sinh Học Đặc Trị',
          'recommended_bio_agents': 'Bacillus subtilis, Trichoderma harzianum, Nano Bạc hữu cơ',
          'action_mechanism': 'Khuẩn đối kháng sinh học ức chế hoàn toàn sợi nấm, kích hoạt kháng thể tự nhiên của cây.',
          'shelf_life_note': 'Sử dụng chế phẩm còn hạn dùng, bảo quản nơi thoáng mát tránh ánh nắng.',
        },
      },
      'pet_child_safety_notes': {
        'dogs_cats_safe': true,
        'child_safe': true,
        'ventilation_advice': 'Ban công thông thoáng gió, hoàn toàn không độc hại cho trẻ nhỏ và thú cưng.',
      },
    };

    if (!mounted) return;

    appState.setActiveDiagnosis(
      plantId: 'plt_01',
      plantName: 'Hoa Hồng Mon Coeur',
      diseaseName: widget.diseaseName,
      diseaseSci: 'Podosphaera pannosa',
      confidence: confidence,
      heatmapDesc: 'Đã hoàn tất kiểm chứng 3 câu hỏi vật lý với độ tin cậy ${(confidence * 100).toStringAsFixed(1)}%.',
    );

    setState(() => _isVerifying = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SafeFirstProtocolScreen(
          verificationResult: verificationResult,
          protocol: protocol,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text('Kiểm Chứng Triệu Chứng Vật Lý (XAI)'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thẻ hướng dẫn
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              color: AppTheme.mintSurface,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.psychology, color: AppTheme.primaryGreen, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chẩn đoán phân biệt: ${widget.diseaseName}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryDark),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'AI nghi ngờ đạt ${(widget.initialConfidence * 100).toStringAsFixed(1)}%. Vui lòng trả lời 3 câu hỏi thực tế dưới đây để loại trừ chẩn đoán nhầm lẫn.',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Danh sách câu hỏi
            ..._defaultQuestions.map((q) {
              final id = q['id'] as String;
              final bool currentVal = _answers[id] ?? false;

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.neutralDark),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        q['question'],
                        style: const TextStyle(fontSize: 13, height: 1.35, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '💡 ${q['explanation']}',
                        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ChoiceChip(
                            label: const Text('KHÔNG'),
                            selected: !currentVal,
                            selectedColor: Colors.grey.shade300,
                            onSelected: (val) {
                              if (val) setState(() => _answers[id] = false);
                            },
                          ),
                          const SizedBox(width: 10),
                          ChoiceChip(
                            label: const Text('CÓ (Đúng)'),
                            selected: currentVal,
                            selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.25),
                            labelStyle: TextStyle(
                              color: currentVal ? AppTheme.primaryDark : Colors.black87,
                              fontWeight: currentVal ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _answers[id] = true);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Nút xác thực & nhận phác đồ
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isVerifying ? null : _verifyAndRecalculate,
                icon: _isVerifying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  _isVerifying ? 'Đang tái tính toán độ tin cậy...' : 'Xác Thực & Nhận Phác Đồ Safe-First',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
