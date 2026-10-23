import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedCity = 'Tất cả';

  // US-093: Số liệu tổng quan Dashboard
  final Map<String, dynamic> _stats = {
    'dau': '14.250',
    'mau': '89.400',
    'scans_today': '3.280',
    'revenue_today': '18.450.000 đ',
    'revenue_month': '342.000.000 đ',
    'vip_count': '4.520',
  };

  // US-094: Bản đồ phân bố dịch bệnh cây cảnh theo quận
  final List<Map<String, dynamic>> _districtAlerts = [
    {
      'city': 'Hà Nội',
      'district': 'Quận Cầu Giấy',
      'top_disease': 'Bệnh Phấn Trắng Hoa Hồng',
      'cases': 420,
      'risk': 'BÁO ĐỘNG ĐỎ',
      'risk_color': Colors.red,
      'note': 'Độ ẩm 85%, sương đêm dày tạo điều kiện vi nấm bùng phát.',
    },
    {
      'city': 'Hà Nội',
      'district': 'Quận Ba Đình',
      'top_disease': 'Đốm Đen Lá Hoa Hồng',
      'cases': 290,
      'risk': 'CẢNH BÁO VÀNG',
      'risk_color': Colors.orange,
      'note': 'Mưa rào làm bào tử nấm bắn ngược lên tán lá dưới.',
    },
    {
      'city': 'TP. Hồ Chí Minh',
      'district': 'Quận 3',
      'top_disease': 'Nhện Đỏ Hại Kiểng Lá & Mai Vàng',
      'cases': 510,
      'risk': 'BÁO ĐỘNG ĐỎ',
      'risk_color': Colors.red,
      'note': 'Nắng gắt 36 độ C hanh khô, nhện sinh sản nhanh gấp 3 lần.',
    },
    {
      'city': 'TP. Hồ Chí Minh',
      'district': 'Thành phố Thủ Đức',
      'top_disease': 'Rệp Sáp Trắng Bông',
      'cases': 380,
      'risk': 'CẢNH BÁO VÀNG',
      'risk_color': Colors.orange,
      'note': 'Ban công kín gió thiếu lưu thông không khí.',
    },
    {
      'city': 'Đà Nẵng',
      'district': 'Quận Hải Châu',
      'top_disease': 'Bệnh Thối Rễ Sen Đá',
      'cases': 195,
      'risk': 'MỨC TRUNG BÌNH',
      'risk_color': Colors.blue,
      'note': 'Mưa dông liên tục làm đọng nước đáy chậu.',
    },
  ];

  // US-096: Phiên bản AI OTA
  final Map<String, dynamic> _otaModel = {
    'version': 'v1.2.0-int8',
    'size': '8.6 MB',
    'status': 'ĐANG HOẠT ĐỘNG',
    'checksum': 'e3b0c442...855',
    'deployed_at': '23/10/2026',
  };

  @override
  Widget build(BuildContext context) {
    final filteredAlerts = _selectedCity == 'Tất cả'
        ? _districtAlerts
        : _districtAlerts.where((a) => a['city'] == _selectedCity).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Admin Dashboard & CMS'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Xuất báo cáo Excel (US-098)',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đang tải về tệp urban_plants_disease_report.csv...'),
                  backgroundColor: Color(0xFF0F172A),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // US-093: Chỉ số DAU/MAU và Doanh thu
            const Text('TỔNG QUAN HỆ THỐNG (DAU/MAU & DOANH THU)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF475569))),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildMetricCard('DAU (Người dùng ngày)', _stats['dau'], Icons.people, Colors.blue)),
                const SizedBox(width: 10),
                Expanded(child: _buildMetricCard('MAU (Người dùng tháng)', _stats['mau'], Icons.groups, Colors.indigo)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildMetricCard('Quét AI Hôm nay', _stats['scans_today'], Icons.document_scanner, Colors.teal)),
                const SizedBox(width: 10),
                Expanded(child: _buildMetricCard('Hội viên Pro VIP', _stats['vip_count'], Icons.workspace_premium, Colors.amber[800]!)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildMetricCard('Doanh thu ngày', _stats['revenue_today'], Icons.monetization_on, const Color(0xFF2E7D32))),
                const SizedBox(width: 10),
                Expanded(child: _buildMetricCard('Doanh thu tháng', _stats['revenue_month'], Icons.account_balance, const Color(0xFF1B5E20))),
              ],
            ),
            const SizedBox(height: 24),

            // US-096: Quản lý mô hình OTA Model
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.system_update_alt, color: Color(0xFF0277BD)),
                            SizedBox(width: 8),
                            Text('Cơ Chế Cập Nhật AI Ngầm (OTA)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
                          child: Text(_otaModel['status'], style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Text('Phiên bản mô hình hiện hành: ${_otaModel['version']} (${_otaModel['size']})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Mã kiểm tra SHA-256: ${_otaModel['checksum']}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đang phát hành bản cập nhật AI Model v1.2.1-int8 lên CDN...')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0277BD),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.cloud_upload_outlined, size: 16),
                      label: const Text('Phát Hành Model Mới Ngầm'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // US-094: Bản đồ nhiệt lây lan dịch bệnh cây trồng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('BẢN ĐỒ DỊCH BỆNH THEO KHU VỰC', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF475569))),
                DropdownButton<String>(
                  value: _selectedCity,
                  underline: const SizedBox(),
                  items: ['Tất cả', 'Hà Nội', 'TP. Hồ Chí Minh', 'Đà Nẵng'].map((c) {
                    return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCity = val!),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ...filteredAlerts.map((a) {
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${a['district']} (${a['city']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: (a['risk_color'] as Color).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              a['risk'],
                              style: TextStyle(color: a['risk_color'], fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Bệnh phổ biến nhất: ${a['top_disease']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                      const SizedBox(height: 2),
                      Text('Số ca quét phát hiện: ${a['cases']} lượt quét tuần này', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      const SizedBox(height: 4),
                      Text('Ghi chú thời tiết: ${a['note']}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF475569))),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
