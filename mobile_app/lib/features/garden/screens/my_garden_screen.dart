import 'package:flutter/material.dart';
import 'package:urban_plants/core/theme.dart';
import 'package:urban_plants/features/garden/services/garden_api_service.dart';
import 'package:urban_plants/features/garden/screens/plant_detail_and_growth_log_screen.dart';

class MyGardenScreen extends StatefulWidget {
  const MyGardenScreen({super.key});

  @override
  State<MyGardenScreen> createState() => _MyGardenScreenState();
}

class _MyGardenScreenState extends State<MyGardenScreen> {
  final GardenApiService _apiService = GardenApiService();
  List<dynamic> _plants = [];
  List<dynamic> _gardens = [];
  bool _isLoading = true;
  String? _selectedGardenFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final plants = await _apiService.getMyPlants();
      final gardens = await _apiService.getMyGardens();
      setState(() {
        _plants = plants;
        _gardens = gardens;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: $e'), backgroundColor: AppTheme.criticalRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddPlantDialog() {
    final nameCtrl = TextEditingController();
    final locationCtrl = TextEditingController(text: 'Ban công hướng Đông');
    final potSizeCtrl = TextEditingController(text: '25');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm Cây Mới Vào Vườn'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên cây (vd: Hoa Hồng Mon Coeur)')),
              const SizedBox(height: 12),
              TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Gắn thẻ vị trí (Ban công, Sân thượng...)')),
              const SizedBox(height: 12),
              TextField(controller: potSizeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Đường kính chậu (cm)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await _apiService.addPlant(
                customName: nameCtrl.text.trim(),
                locationTag: locationCtrl.text.trim(),
                potSizeCm: int.tryParse(potSizeCtrl.text) ?? 25,
              );
              _loadData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã thêm cây mới thành công!'), backgroundColor: AppTheme.primaryGreen),
                );
              }
            },
            child: const Text('Thêm cây'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vườn Của Tôi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28, color: AppTheme.primaryGreen),
            onPressed: _showAddPlantDialog,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : _plants.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.yard_outlined, size: 64, color: AppTheme.neutralMuted),
                      const SizedBox(height: 16),
                      const Text('Khu vườn của bạn chưa có cây nào.', style: TextStyle(fontSize: 16, color: AppTheme.neutralMuted)),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _showAddPlantDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm cây đầu tiên ngay'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    if (_gardens.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            FilterChip(
                              label: const Text('Tất cả'),
                              selected: _selectedGardenFilter == null,
                              onSelected: (_) => setState(() => _selectedGardenFilter = null),
                            ),
                            ..._gardens.map((g) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: FilterChip(
                                label: Text(g['name'] ?? 'Vườn'),
                                selected: _selectedGardenFilter == g['id']?.toString(),
                                onSelected: (val) => setState(() => _selectedGardenFilter = val ? g['id']?.toString() : null),
                              ),
                            )),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _selectedGardenFilter == null 
                            ? _plants.length 
                            : _plants.where((p) => p['garden_id']?.toString() == _selectedGardenFilter).length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) {
                          final filteredList = _selectedGardenFilter == null
                              ? _plants
                              : _plants.where((p) => p['garden_id']?.toString() == _selectedGardenFilter).toList();
                          final plant = filteredList[i];
                          return Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: const CircleAvatar(
                                radius: 28,
                                backgroundColor: AppTheme.mintSurface,
                                child: Icon(Icons.eco, color: AppTheme.primaryGreen, size: 30),
                              ),
                              title: Text(
                                plant['custom_name'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('📍 Vị trí: ${plant['location_tag']}'),
                            const SizedBox(height: 4),
                            Text('Chậu: ${plant['pot_size_cm']}cm • Trạng thái: ${plant['health_status']}'),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlantDetailAndGrowthLogScreen(plant: plant),
                            ),
                          ).then((_) => _loadData());
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
    );
  }
}
