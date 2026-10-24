import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_plants/core/theme.dart';
import 'package:urban_plants/core/app_state.dart';
import 'package:urban_plants/features/treatment/screens/safe_first_protocol_screen.dart';

class MyGardenScreen extends StatelessWidget {
  const MyGardenScreen({super.key});

  void _showAddPlantDialog(BuildContext context) {
    final appState = context.read<AppState>();
    final nameCtrl = TextEditingController();
    final sciCtrl = TextEditingController(text: 'Cây cảnh đô thị');
    String selectedLocation = 'Ban công hướng Đông';
    final potSizeCtrl = TextEditingController(text: '25');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Thêm Chậu Cây Mới Vào Vườn'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên cây (*)',
                    hintText: 'Ví dụ: Hoa Hồng Mon Coeur, Monstera...',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: sciCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên khoa học / Chủng loại',
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Vị trí đặt chậu (*):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedLocation,
                  items: const [
                    DropdownMenuItem(value: 'Ban công hướng Đông', child: Text('Ban công hướng Đông (Nắng sáng)')),
                    DropdownMenuItem(value: 'Ban công hướng Tây', child: Text('Ban công hướng Tây (Nắng gắt)')),
                    DropdownMenuItem(value: 'Sân thượng tầng cao', child: Text('Sân thượng tầng cao (Gió mạnh)')),
                    DropdownMenuItem(value: 'Bậu cửa sổ phòng khách', child: Text('Bậu cửa sổ phòng khách (Bán râm)')),
                    DropdownMenuItem(value: 'Phòng làm việc trong nhà', child: Text('Phòng làm việc trong nhà (Ánh sáng đèn)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedLocation = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: potSizeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Đường kính chậu (cm)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập tên chậu cây! Không được để trống.'),
                      backgroundColor: AppTheme.criticalRed,
                    ),
                  );
                  return;
                }

                appState.addPlant({
                  'id': 'plt_${DateTime.now().millisecondsSinceEpoch}',
                  'name': name,
                  'sci_name': sciCtrl.text.trim().isNotEmpty ? sciCtrl.text.trim() : 'Plantae',
                  'location': selectedLocation,
                  'soil_moisture': 75,
                  'health_status': 'KHỎE MẠNH',
                  'disease_name': null,
                  'image_url': 'https://images.unsplash.com/photo-1545241047-6083a3684587?auto=format&fit=crop&w=400&q=80',
                  'water_interval': 2,
                  'last_watered': 'Vừa thêm hôm nay',
                });

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã thêm "$name" vào Vườn của bạn thành công!'),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              },
              child: const Text('Thêm cây'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: Text('Vườn Của Tôi (${appState.plants.length} Chậu)'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 26),
            tooltip: 'Thêm chậu cây mới',
            onPressed: () => _showAddPlantDialog(context),
          ),
        ],
      ),
      body: appState.plants.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.yard_outlined, size: 64, color: AppTheme.neutralMuted),
                  const SizedBox(height: 12),
                  const Text('Chưa có cây nào trong khu vườn của bạn'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                    onPressed: () => _showAddPlantDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm cây đầu tiên'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appState.plants.length,
              itemBuilder: (ctx, index) {
                final plant = appState.plants[index];
                final String status = plant['health_status'] ?? 'KHỎE MẠNH';
                final bool isSick = status != 'KHỎE MẠNH';
                final int moisture = (plant['soil_moisture'] as num?)?.toInt() ?? 60;

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ảnh chậu cây
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                plant['image_url'] ?? '',
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 72,
                                  height: 72,
                                  color: AppTheme.mintSurface,
                                  child: const Icon(Icons.local_florist, color: AppTheme.primaryGreen),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Thông tin chậu cây
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          plant['name'] ?? '',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      _buildStatusBadge(status),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    plant['sci_name'] ?? '',
                                    style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.neutralMuted),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          plant['location'] ?? '',
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
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

                        // Thanh đo độ ẩm đất
                        Row(
                          children: [
                            const Icon(Icons.water_drop, size: 16, color: Colors.blue),
                            const SizedBox(width: 6),
                            const Text('Độ ẩm đất chậu:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: moisture / 100.0,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    moisture >= 70 ? Colors.blue : (moisture >= 40 ? Colors.green : Colors.orange),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('$moisture%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),

                        // Nếu cây đang bệnh, cho phép mở phác đồ ngay
                        if (isSick && plant['disease_name'] != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.amber.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.medical_services_outlined, size: 18, color: Colors.deepOrange),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Bệnh: ${plant['disease_name']}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                                  ),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () {
                                    appState.setActiveDiagnosis(
                                      plantId: plant['id'],
                                      plantName: plant['name'],
                                      diseaseName: plant['disease_name'],
                                      diseaseSci: 'Tổn thương vi sinh / vi nấm',
                                      confidence: 0.94,
                                      heatmapDesc: 'Vùng nhiệt Grad-CAM tập trung quanh bề mặt lá chậu ${plant['name']}.',
                                      imageUrl: plant['image_url'],
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const SafeFirstProtocolScreen()),
                                    );
                                  },
                                  child: const Text('Xem phác đồ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = Colors.green.shade100;
    Color fg = Colors.green.shade800;

    if (status == 'CẦN CHĂM SÓC') {
      bg = Colors.amber.shade100;
      fg = Colors.amber.shade900;
    } else if (status == 'ĐANG ĐIỀU TRỊ') {
      bg = Colors.purple.shade100;
      fg = Colors.purple.shade800;
    } else if (status == 'CẦN CÁCH LY GẤP') {
      bg = Colors.red.shade100;
      fg = Colors.red.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(
        status,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}
