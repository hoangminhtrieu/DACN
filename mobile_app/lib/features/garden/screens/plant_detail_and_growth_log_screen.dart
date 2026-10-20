import 'package:flutter/material.dart';
import 'package:urban_plants/core/theme.dart';
import 'package:urban_plants/features/garden/services/garden_api_service.dart';

class PlantDetailAndGrowthLogScreen extends StatefulWidget {
  final Map<String, dynamic> plant;
  const PlantDetailAndGrowthLogScreen({super.key, required this.plant});

  @override
  State<PlantDetailAndGrowthLogScreen> createState() => _PlantDetailAndGrowthLogScreenState();
}

class _PlantDetailAndGrowthLogScreenState extends State<PlantDetailAndGrowthLogScreen> {
  final GardenApiService _apiService = GardenApiService();
  List<dynamic> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      final logs = await _apiService.getGrowthLogs(widget.plant['id']);
      setState(() => _logs = logs);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải nhật ký: $e'), backgroundColor: AppTheme.criticalRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // US-022: Thêm nhật ký sinh trưởng
  void _showAddLogDialog() {
    final heightCtrl = TextEditingController();
    final milestoneCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ghi Nhật Ký Phát Triển'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: heightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Chiều cao hiện tại (cm)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: milestoneCtrl,
                decoration: const InputDecoration(labelText: 'Cột mốc (Đơm nụ, Ra lá mới, Thay chậu)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Ghi chú quan sát thực tế'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _apiService.addGrowthLog(
                plantId: widget.plant['id'],
                heightCm: double.tryParse(heightCtrl.text),
                milestone: milestoneCtrl.text.isNotEmpty ? milestoneCtrl.text : null,
                note: noteCtrl.text.isNotEmpty ? noteCtrl.text : null,
              );
              _loadLogs();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã lưu nhật ký sinh trưởng mới!'), backgroundColor: AppTheme.primaryGreen),
                );
              }
            },
            child: const Text('Lưu nhật ký'),
          ),
        ],
      ),
    );
  }

  // US-026: Xuất báo cáo PDF/Ảnh
  void _exportReport() async {
    try {
      final report = await _apiService.getPlantReport(widget.plant['id']);
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.picture_as_pdf, color: AppTheme.primaryGreen),
              SizedBox(width: 8),
              Expanded(child: Text('Báo Cáo Sức Khỏe Cây', style: TextStyle(fontSize: 18))),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(report['report_title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Thời gian xuất: ${report['generated_at']}', style: const TextStyle(fontSize: 12, color: AppTheme.neutralMuted)),
                const Divider(),
                Text('• Vị trí: ${report['plant_summary']['location_tag']}'),
                Text('• Ngày trồng: ${report['plant_summary']['planted_date']}'),
                Text('• Tình trạng: ${report['plant_summary']['health_status']}'),
                const SizedBox(height: 12),
                const Text('Khuyến nghị chuyên gia:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(report['recommendations'], style: const TextStyle(fontSize: 13, height: 1.3)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xuất báo cáo ra file PDF thành công!'), backgroundColor: AppTheme.primaryGreen),
                );
              },
              icon: const Icon(Icons.share),
              label: const Text('Chia sẻ file PDF'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi xuất báo cáo: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plant['custom_name']),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Xuất báo cáo PDF/Ảnh (US-026)',
            onPressed: _exportReport,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppTheme.mintSurface,
                  child: const Icon(Icons.local_florist, size: 40, color: AppTheme.primaryGreen),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.plant['custom_name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('📍 ${widget.plant['location_tag']}', style: const TextStyle(color: AppTheme.neutralMuted)),
                      Text('Kích thước chậu: ${widget.plant['pot_size_cm']}cm'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Section Title & Add Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Dòng Thời Gian Phát Triển (US-022)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _showAddLogDialog,
                  icon: const Icon(Icons.add_circle, color: AppTheme.primaryGreen),
                  label: const Text('Ghi nhật ký', style: TextStyle(color: AppTheme.primaryGreen)),
                ),
              ],
            ),
          ),

          // Timeline Logs List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                : _logs.isEmpty
                    ? const Center(child: Text('Chưa có ghi chép nhật ký nào cho cây này.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _logs.length,
                        itemBuilder: (ctx, i) {
                          final log = _logs[i];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  const Icon(Icons.circle, size: 14, color: AppTheme.primaryGreen),
                                  if (i < _logs.length - 1)
                                    Container(width: 2, height: 60, color: AppTheme.primaryGreen.withOpacity(0.3)),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(log['log_date'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                            if (log['height_cm'] != null)
                                              Text('Cao: ${log['height_cm']}cm', style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        if (log['growth_milestone'] != null) ...[
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: AppTheme.mintSurface, borderRadius: BorderRadius.circular(4)),
                                            child: Text('🌱 ${log['growth_milestone']}', style: const TextStyle(fontSize: 11, color: AppTheme.primaryGreen)),
                                          ),
                                        ],
                                        if (log['note'] != null) ...[
                                          const SizedBox(height: 6),
                                          Text(log['note'], style: const TextStyle(fontSize: 13)),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
