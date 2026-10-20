import 'package:flutter/material.dart';
import 'package:urban_plants/core/theme.dart';
import 'package:urban_plants/features/garden/services/garden_api_service.dart';

class PlantCatalogScreen extends StatefulWidget {
  const PlantCatalogScreen({super.key});

  @override
  State<PlantCatalogScreen> createState() => _PlantCatalogScreenState();
}

class _PlantCatalogScreenState extends State<PlantCatalogScreen> {
  final GardenApiService _apiService = GardenApiService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _catalogItems = [];
  bool _isLoading = true;
  String? _selectedLight;

  final List<Map<String, String>> _lightFilters = [
    {'label': 'Tất cả', 'value': ''},
    {'label': '☀️ Nắng trực tiếp', 'value': 'DIRECT_SUN'},
    {'label': '⛅ Bán phần', 'value': 'PARTIAL_SHADE'},
    {'label': '🌿 Ánh sáng tán xạ', 'value': 'INDIRECT_BRIGHT'},
    {'label': '🏠 Trong nhà', 'value': 'LOW_LIGHT'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    setState(() => _isLoading = true);
    try {
      final items = await _apiService.getCatalog(
        query: _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null,
        light: (_selectedLight != null && _selectedLight!.isNotEmpty) ? _selectedLight : null,
      );
      setState(() => _catalogItems = items);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh mục: $e'), backgroundColor: AppTheme.criticalRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPlantDetailSheet(Map<String, dynamic> plant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                plant['common_name_vi'],
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.neutralDark),
              ),
              Text(
                plant['scientific_name'] ?? '',
                style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppTheme.neutralMuted),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _infoBadge(Icons.wb_sunny_outlined, 'Ánh sáng: ${plant['light_requirement']}'),
                  const SizedBox(width: 8),
                  _infoBadge(Icons.water_drop_outlined, 'Tưới: ${plant['standard_water_interval_days']} ngày/lần'),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Mô tả sinh học', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(plant['description'] ?? 'Đang cập nhật...', style: const TextStyle(fontSize: 14, height: 1.4)),
              const SizedBox(height: 16),
              const Text('Hướng dẫn chăm sóc ban công đô thị', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(plant['care_instructions'] ?? 'Đang cập nhật...', style: const TextStyle(fontSize: 14, height: 1.4)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _apiService.addPlant(
                    catalogId: plant['id'],
                    customName: plant['common_name_vi'],
                    locationTag: 'Ban công hướng Đông',
                    customWaterIntervalDays: plant['standard_water_interval_days'],
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã thêm "${plant['common_name_vi']}" vào Vườn của bạn!'),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Thêm cây này vào Vườn của tôi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppTheme.mintSurface, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryGreen),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bách Khoa Cây Trồng Đô Thị'),
      ),
      body: Column(
        children: [
          // US-017: Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm hoa hồng, sen đá, monstera, cà chua...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _loadCatalog();
                  },
                ),
              ),
              onSubmitted: (_) => _loadCatalog(),
            ),
          ),

          // US-018: Thanh lọc theo ánh sáng
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _lightFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, idx) {
                final f = _lightFilters[idx];
                final isSelected = (_selectedLight ?? '') == f['value'];
                return ChoiceChip(
                  label: Text(f['label']!),
                  selected: isSelected,
                  selectedColor: AppTheme.mintSurface,
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primaryGreen : AppTheme.neutralDark,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (val) {
                    setState(() => _selectedLight = val ? f['value'] : null);
                    _loadCatalog();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Danh sách cây
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                : _catalogItems.isEmpty
                    ? const Center(child: Text('Không tìm thấy loại cây phù hợp.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _catalogItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) {
                          final plant = _catalogItems[i];
                          return Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  color: AppTheme.mintSurface,
                                  child: const Icon(Icons.local_florist, color: AppTheme.primaryGreen, size: 32),
                                ),
                              ),
                              title: Text(
                                plant['common_name_vi'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(plant['scientific_name'] ?? '', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Chu kỳ tưới: ${plant['standard_water_interval_days']} ngày/lần • Ánh sáng: ${plant['light_requirement']}',
                                    style: const TextStyle(fontSize: 11, color: AppTheme.primaryGreen),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => _showPlantDetailSheet(plant),
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
