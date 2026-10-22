import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:urban_plants/core/theme.dart';
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
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000/api/v1'));
  List<dynamic> _questions = [];
  final Map<String, bool> _answers = {};
  bool _isLoading = true;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final res = await _dio.get('/treatment/questions/${widget.diseaseCode}');
      setState(() {
        _questions = res.data['questions'] ?? [];
        for (var q in _questions) {
          _answers[q['question_id']] = false; // Mặc định là Không
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // US-061: Tái tính toán độ tin cậy
  Future<void> _verifyAndRecalculate() async {
    setState(() => _isVerifying = true);
    try {
      final res = await _dio.post('/treatment/verify', data: {
        'primary_disease_code': widget.diseaseCode,
        'initial_confidence': widget.initialConfidence,
        'answers': _answers,
      });

      if (!mounted) return;

      final verifResult = res.data['verification_result'];
      final protocol = res.data['recommended_safe_first_protocol'];

      // Hiển thị kết quả tái tính toán và điều hướng sang Phác đồ Safe-First
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SafeFirstProtocolScreen(
            verificationResult: verifResult,
            protocol: protocol,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi xác thực: $e')));
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác Thực Triệu Chứng Vật Lý (XAI)'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: AppTheme.mintSurface,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const Icon(Icons.touch_app_outlined, color: AppTheme.primaryGreen, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chẩn đoán sơ bộ: ${widget.diseaseName}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Hãy chạm nhẹ hoặc quan sát kỹ phiến lá để AI đưa ra phác đồ điều trị an toàn tuyệt đối 100%.',
                                  style: TextStyle(fontSize: 12, color: AppTheme.neutralDark),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // US-059, US-060: Danh sách câu hỏi kèm ảnh mẫu
                  ..._questions.map((q) {
                    final qId = q['question_id'];
                    final bool isChecked = _answers[qId] ?? false;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              q['question_text'],
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, height: 1.4),
                            ),
                            const SizedBox(height: 8),

                            // US-060: Ảnh mẫu minh họa triệu chứng
                            if (q['sample_illustration_url'] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  height: 120,
                                  width: double.infinity,
                                  color: Colors.grey.shade200,
                                  child: Image.network(
                                    q['sample_illustration_url'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.image_outlined, size: 40, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ChoiceChip(
                                  label: const Text('Không'),
                                  selected: !isChecked,
                                  onSelected: (val) => setState(() => _answers[qId] = false),
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: const Text('Có, đúng vậy'),
                                  selected: isChecked,
                                  selectedColor: AppTheme.mintSurface,
                                  labelStyle: TextStyle(
                                    color: isChecked ? AppTheme.primaryGreen : Colors.black,
                                    fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  onSelected: (val) => setState(() => _answers[qId] = true),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  // Nút Tái tính toán độ tin cậy (US-061)
                  ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyAndRecalculate,
                    child: _isVerifying
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Tái tính toán độ tin cậy & Xem Phác đồ Safe-First'),
                  ),
                ],
              ),
            ),
    );
  }
}
