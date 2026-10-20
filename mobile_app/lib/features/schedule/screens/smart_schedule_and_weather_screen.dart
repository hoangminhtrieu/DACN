import 'package:flutter/material.dart';
import 'package:urban_plants/core/theme.dart';
import 'package:urban_plants/features/garden/services/garden_api_service.dart';

class SmartScheduleAndWeatherScreen extends StatefulWidget {
  const SmartScheduleAndWeatherScreen({super.key});

  @override
  State<SmartScheduleAndWeatherScreen> createState() => _SmartScheduleAndWeatherScreenState();
}

class _SmartScheduleAndWeatherScreenState extends State<SmartScheduleAndWeatherScreen> {
  final GardenApiService _apiService = GardenApiService();

  Map<String, dynamic>? _weather;
  List<dynamic> _schedules = [];
  bool _isVacation = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      final weatherData = await _apiService.getWeather('TP. Hồ Chí Minh');
      final schedulesData = await _apiService.getSchedules();
      final vacationData = await _apiService.getVacationMode();

      setState(() {
        _weather = weatherData;
        _schedules = schedulesData;
        _isVacation = vacationData['is_vacation_mode'] ?? false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu lịch trình: $e'), backgroundColor: AppTheme.criticalRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // US-029: Thao tác nhanh Đã tưới hoặc Hoãn 1 ngày
  Future<void> _handleAction(String scheduleId, String action) async {
    try {
      await _apiService.performScheduleAction(scheduleId, action);
      _loadAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(action == 'COMPLETE' ? 'Đã đánh dấu hoàn thành nhiệm vụ!' : 'Đã hoãn lịch tưới thêm 1 ngày!'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  // US-036: Chế độ đi vắng
  Future<void> _toggleVacation(bool val) async {
    setState(() => _isVacation = val);
    await _apiService.updateVacationMode(val, val ? 'Chế độ nghỉ dưỡng đang bật' : null);
    _loadAll();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(val ? 'Đã kích hoạt chế độ Đi Vắng (Tạm dừng thông báo)' : 'Đã tắt chế độ Đi Vắng'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Chăm Sóc & Dự Báo Thời Tiết'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // US-031: Smart Weather Card
                  if (_weather != null) ...[
                    Card(
                      color: AppTheme.primaryGreen,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '📍 ${_weather!['city']}',
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${_weather!['temperature_celsius']}°C',
                                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${_weather!['weather_condition']} • Độ ẩm: ${_weather!['humidity_percent']}% • Khả năng mưa: ${_weather!['rain_probability_percent']}%',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // US-032, US-033, US-034: Cảnh báo thời tiết đặc biệt
                    if (_weather!['alerts'] != null && (_weather!['alerts'] as List).isNotEmpty)
                      ...(_weather!['alerts'] as List).map((alert) {
                        final isCritical = alert['severity'] == 'CRITICAL';
                        return Card(
                          color: isCritical ? Colors.red.shade50 : Colors.amber.shade50,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              isCritical ? Icons.warning_rounded : Icons.info_outline,
                              color: isCritical ? AppTheme.criticalRed : Colors.orange,
                              size: 32,
                            ),
                            title: Text(alert['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text('${alert['description']}\n💡 ${alert['recommended_action']}', style: const TextStyle(fontSize: 12)),
                          ),
                        );
                      }),
                  ],
                  const SizedBox(height: 12),

                  // US-036: Vacation Mode Switch
                  Card(
                    child: SwitchListTile(
                      secondary: const Icon(Icons.flight_takeoff, color: AppTheme.primaryGreen),
                      title: const Text('Chế độ Đi Vắng / Nghỉ Dưỡng', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Tự động tạm dừng chuông nhắc nhở khi bạn vắng nhà'),
                      value: _isVacation,
                      activeColor: AppTheme.primaryGreen,
                      onChanged: _toggleVacation,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section: Việc cần làm hôm nay (US-027..US-030)
                  const Text('Việc Cần Làm Hôm Nay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.neutralDark)),
                  const SizedBox(height: 10),

                  if (_schedules.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('Hôm nay khu vườn của bạn không có lịch cần tưới!')),
                    )
                  else
                    ..._schedules.map((sch) {
                      final bool isDone = sch['is_completed'];
                      final bool isSkipped = sch['weather_skip_flag'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.water_drop,
                                        color: isDone ? Colors.grey : (isSkipped ? Colors.orange : AppTheme.primaryGreen),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        sch['task_type'] == 'WATERING' ? 'Tưới Nước Cho Cây' : 'Chăm Sóc',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          decoration: isDone ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(sch['scheduled_time'], style: const TextStyle(color: AppTheme.neutralMuted, fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // US-032: Thông báo tự hoãn khi mưa
                              if (isSkipped && sch['skip_reason'] != null)
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.umbrella, size: 18, color: Colors.deepOrange),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          sch['skip_reason'],
                                          style: const TextStyle(fontSize: 12, color: Colors.deepOrange, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // US-029: Nút hành động nhanh
                              if (!isDone)
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primaryGreen,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                        ),
                                        onPressed: () => _handleAction(sch['id'], 'COMPLETE'),
                                        icon: const Icon(Icons.check, size: 18),
                                        label: const Text('Đã tưới', style: TextStyle(fontSize: 13)),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                        ),
                                        onPressed: () => _handleAction(sch['id'], 'POSTPONE'),
                                        icon: const Icon(Icons.update, size: 18),
                                        label: const Text('Hoãn 1 ngày', style: TextStyle(fontSize: 13)),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                const Row(
                                  children: [
                                    Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 18),
                                    SizedBox(width: 6),
                                    Text('Đã hoàn thành lúc sáng nay', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 13, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
