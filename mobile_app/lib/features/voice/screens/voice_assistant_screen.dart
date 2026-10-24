import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_plants/core/theme.dart';
import 'package:urban_plants/core/app_state.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  bool _isListening = false;
  double _speechRate = 1.0;
  final List<Map<String, String>> _messages = [
    {
      'sender': 'AI',
      'text': 'Xin chào Hoàng Minh Triều! Tôi là Trợ lý Giọng nói Urban Plants. Bạn có thể nói khẩu lệnh rảnh tay như "Đã tưới hết cây ban công", "Hỏi cách trị phấn trắng" hoặc "Bật chế độ đi vắng".',
    },
  ];

  final List<String> _quickCommands = [
    'Đã tưới hết các chậu cây ban công hôm nay',
    'Nhiệt độ hôm nay có cần che lưới cho hoa hồng?',
    'Lá hoa hồng bị phấn trắng phải xử lý thế nào?',
    'Bật chế độ đi vắng cho khu vườn',
  ];

  void _handleCommand(String text) async {
    final appState = context.read<AppState>();

    setState(() {
      _messages.add({'sender': 'USER', 'text': text});
      _isListening = true;
    });

    await Future.delayed(const Duration(milliseconds: 900));

    String reply = '';
    if (text.contains('tưới')) {
      appState.markAllWateringCompleted();
      reply = 'Đã ghi nhận! Toàn bộ lịch tưới hôm nay đã được đánh dấu hoàn tất. Độ ẩm các chậu cây đã được cập nhật lên 85%.';
    } else if (text.contains('nhiệt độ') || text.contains('che lưới')) {
      reply =
          'Nhiệt độ hiện tại tại ${appState.currentLocationName} là ${appState.temperature.toStringAsFixed(1)}°C. ${appState.weatherAdvice}';
    } else if (text.contains('phấn trắng') || text.contains('bệnh')) {
      reply =
          'Bệnh phấn trắng cần tuân thủ 3 bước Safe-First: Bước 1 cắt bỏ lá bệnh và khử trùng kéo; Bước 2 phun dung dịch Dầu Neem 5ml pha 1 lít nước ấm lúc chiều mát; Bước 3 dùng chế phẩm vi sinh Bacillus nếu chưa dứt điểm.';
    } else if (text.contains('đi vắng')) {
      appState.toggleVacationMode(true);
      reply = 'Đã kích hoạt Chế độ Đi Vắng cho khu vườn! Hệ thống sẽ tạm dừng chuông nhắc nhở và tối ưu chu kỳ ẩm.';
    } else {
      reply = 'Đã ghi nhận khẩu lệnh: "$text". Trợ lý đã lưu vào nhật ký chăm sóc của bạn.';
    }

    if (mounted) {
      setState(() {
        _isListening = false;
        _messages.add({'sender': 'AI', 'text': reply});
      });
    }
  }

  void _startMicListening() {
    setState(() => _isListening = true);
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _handleCommand('Đã tưới hết các chậu cây ban công hôm nay');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text('Trợ Lý Giọng Nói Tiếng Việt (TTS/STT)'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Khung hội thoại tin nhắn giọng nói
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (ctx, idx) {
                final msg = _messages[idx];
                final bool isAi = msg['sender'] == 'AI';

                return Align(
                  alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                      color: isAi ? Colors.white : AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAi ? Icons.smart_toy_outlined : Icons.person_outline,
                              size: 16,
                              color: isAi ? AppTheme.primaryGreen : Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isAi ? 'Trợ lý Urban Plants' : 'Bạn',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: isAi ? AppTheme.primaryGreen : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          msg['text'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            color: isAi ? AppTheme.neutralDark : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Tùy chỉnh tốc độ đọc TTS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tốc độ giọng đọc (TTS):', style: TextStyle(fontSize: 11, color: AppTheme.neutralMuted)),
                Row(
                  children: [0.8, 1.0, 1.2].map((rate) {
                    final isSel = _speechRate == rate;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ChoiceChip(
                        label: Text('${rate}x', style: TextStyle(fontSize: 11, color: isSel ? Colors.white : Colors.black87)),
                        selected: isSel,
                        selectedColor: AppTheme.primaryGreen,
                        onSelected: (val) {
                          if (val) setState(() => _speechRate = rate);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Các câu lệnh gợi ý nhanh
          Container(
            height: 48,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: _quickCommands.length,
              itemBuilder: (ctx, idx) {
                final cmd = _quickCommands[idx];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: const Icon(Icons.record_voice_over, size: 14, color: AppTheme.primaryGreen),
                    label: Text(cmd, style: const TextStyle(fontSize: 11)),
                    onPressed: _isListening ? null : () => _handleCommand(cmd),
                  ),
                );
              },
            ),
          ),

          // Nút bấm Microphone thu âm giọng nói
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _isListening ? '🎙️ Đang lắng nghe giọng nói tiếng Việt...' : 'Chạm vào micro hoặc bấm khẩu lệnh mẫu phía trên',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: _isListening ? AppTheme.primaryGreen : AppTheme.neutralMuted,
                      fontWeight: _isListening ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: _isListening ? Colors.red : AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  onPressed: _isListening ? null : _startMicListening,
                  child: Icon(_isListening ? Icons.graphic_eq : Icons.mic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
