import 'package:flutter/material.dart';

class ExpertConsultationScreen extends StatefulWidget {
  const ExpertConsultationScreen({Key? key}) : super(key: key);

  @override
  State<ExpertConsultationScreen> createState() => _ExpertConsultationScreenState();
}

class _ExpertConsultationScreenState extends State<ExpertConsultationScreen> {
  final _plantController = TextEditingController(text: 'Hoa hồng Claude Monet ban công');
  final _symptomsController = TextEditingController(text: 'Lá xuất hiện đốm đen lan rộng, đã phun baking soda nhưng chưa thuyên giảm sau 5 ngày.');
  String _selectedSlot = '14:30';
  bool _isBooked = false;
  Map<String, dynamic>? _bookingData;

  final List<Map<String, dynamic>> _experts = [
    {
      'id': 'exp_01',
      'name': 'Kỹ sư Trần Anh Dũng',
      'title': 'Chuyên gia Bệnh Cây Đô Thị & Hoa Hồng',
      'exp': '12 năm kinh nghiệm',
      'rating': 4.98,
      'reviews': 342,
      'fee': '99.000 đ / 30 phút',
      'slots': ['09:00', '10:30', '14:30', '16:00', '19:30'],
      'avatar_color': Colors.teal,
    },
    {
      'id': 'exp_02',
      'name': 'Thạc sĩ Lê Thu Thảo',
      'title': 'Chuyên gia Kiểng Lá & Sen Đá',
      'exp': '8 năm kinh nghiệm',
      'rating': 4.95,
      'reviews': 215,
      'fee': '99.000 đ / 30 phút',
      'slots': ['08:30', '11:00', '15:00', '17:30', '20:00'],
      'avatar_color': Colors.purple,
    },
  ];

  late String _selectedExpertId;

  @override
  void initState() {
    super.initState();
    _selectedExpertId = _experts[0]['id'];
  }

  void _confirmBooking() {
    setState(() {
      _isBooked = true;
      _bookingData = {
        'room_url': 'https://meet.urbanplants.vn/urban-room-a89b7c',
        'time': 'Hôm nay lúc $_selectedSlot',
        'fee': '99.000 đ',
        'expert': _experts.firstWhere((e) => e['id'] == _selectedExpertId)['name'],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text('Tư Vấn 1-1 Với Chuyên Gia'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: _isBooked ? _buildSuccessView() : _buildBookingForm(),
    );
  }

  Widget _buildBookingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner giới thiệu
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFA5D6A7)),
            ),
            child: const Row(
              children: [
                Icon(Icons.video_call, color: Color(0xFF1B5E20), size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Kết nối trực tiếp qua Video Call với Chuyên gia Nông nghiệp để chẩn đoán chính xác các ca bệnh khó chữa.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF1B5E20), height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Chọn chuyên gia (US-087, US-089)
          const Text('Chọn chuyên gia tư vấn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
          const SizedBox(height: 10),
          ..._experts.map((exp) {
            final isSelected = _selectedExpertId == exp['id'];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent, width: 2),
              ),
              child: ListTile(
                onTap: () => setState(() => _selectedExpertId = exp['id']),
                leading: CircleAvatar(
                  backgroundColor: exp['avatar_color'],
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: Text(exp['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exp['title'], style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(' ${exp['rating']} (${exp['reviews']} đánh giá) • ${exp['exp']}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                  ],
                ),
                trailing: Text(exp['fee'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20), fontSize: 13)),
              ),
            );
          }),
          const SizedBox(height: 16),

          // Chọn khung giờ (US-089)
          const Text('Chọn khung giờ tư vấn rảnh hôm nay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: ['09:00', '10:30', '14:30', '16:00', '19:30'].map((slot) {
              final isSelected = _selectedSlot == slot;
              return ChoiceChip(
                label: Text(slot),
                selected: isSelected,
                selectedColor: const Color(0xFFE8F5E9),
                labelStyle: TextStyle(color: isSelected ? const Color(0xFF1B5E20) : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                onSelected: (_) => setState(() => _selectedSlot = slot),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Nhập thông tin cây & mô tả triệu chứng
          const Text('Thông tin cây bệnh cần hỗ trợ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          TextField(
            controller: _plantController,
            decoration: InputDecoration(
              labelText: 'Tên giống cây',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _symptomsController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Mô tả tóm tắt triệu chứng & lịch sử xịt thuốc',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),

          // Nút xác nhận đặt lịch & thanh toán (US-088)
          ElevatedButton.icon(
            onPressed: _confirmBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.payment),
            label: const Text('Thanh toán 99.000 đ & Nhận Link Phòng Gọi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    final b = _bookingData!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.video_camera_front, color: Color(0xFF2E7D32), size: 64),
                const SizedBox(height: 12),
                const Text(
                  'ĐẶT LỊCH TƯ VẤN THÀNH CÔNG!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 6),
                Text(
                  'Chuyên gia ${b['expert']} sẽ kết nối trực tiếp với bạn.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const Divider(height: 30),
                _buildInfoRow('Thời gian hẹn:', b['time']),
                _buildInfoRow('Phí dịch vụ:', b['fee']),
                _buildInfoRow('Trạng thái:', 'Đã thanh toán (CONFIRMED)'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          b['room_url'],
                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Quay về Vườn của tôi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }
}
