import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_plants/core/theme.dart';
import 'package:urban_plants/core/app_state.dart';
import 'package:urban_plants/features/voice/screens/voice_assistant_screen.dart';
import 'package:urban_plants/features/diagnosis/screens/ai_camera_scanner_screen.dart';

class SmartScheduleAndWeatherScreen extends StatelessWidget {
  const SmartScheduleAndWeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text('Lịch Chăm Sóc & Thời Tiết'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.mic_none_outlined),
            tooltip: 'Trợ lý Giọng nói tiếng Việt',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VoiceAssistantScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            tooltip: 'Quét AI Chẩn Đoán',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AICameraScannerScreen()),
              );
            },
          ),
          IconButton(
            icon: appState.isLoadingWeather
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Làm mới thời tiết thời gian thực',
            onPressed: () => appState.fetchLiveWeather(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. THẺ THỜI TIẾT THỰC TẾ (OPEN-METEO API) & VỊ TRÍ GPS ĐIỆN THOẠI TRỰC TIẾP
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: AppTheme.primaryGreen,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Vị trí GPS trực tiếp từ điện thoại (Không dùng chọn thành phố cứng)
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              appState.updateCurrentDeviceLocation();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (appState.isLocatingGps) ...[
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    ),
                                    const SizedBox(width: 6),
                                  ] else ...[
                                    const Icon(Icons.my_location, color: Colors.lightGreenAccent, size: 16),
                                    const SizedBox(width: 6),
                                  ],
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                appState.isGpsActive ? 'GPS TRỰC TIẾP' : 'VỊ TRÍ THIẾT BỊ',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.white.withValues(alpha: 0.85),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 9,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.refresh, color: Colors.white70, size: 12),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          appState.currentLocationName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Nhiệt độ hiện tại
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${appState.temperature.toStringAsFixed(1)}°C',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              appState.isLoadingWeather ? 'Đang tải...' : 'Thời gian thực',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Chỉ số thời tiết thật
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildWeatherMetric(Icons.water_drop, 'Độ ẩm', '${appState.humidity}%'),
                        _buildWeatherMetric(Icons.umbrella, 'Xác suất mưa', '${appState.rainProbability}%'),
                        _buildWeatherMetric(Icons.air, 'Sức gió', '${appState.windSpeed.toStringAsFixed(1)} km/h'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 2. RÀNG BUỘC CẢNH BÁO THỜI TIẾT DỰA TRÊN DỮ LIỆU THẬT (US-032, US-033, US-034)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: appState.weatherAlertSeverity == 'CRITICAL'
                    ? const Color(0xFFFEF2F2)
                    : (appState.weatherAlertSeverity == 'WARNING' ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4)),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: appState.weatherAlertSeverity == 'CRITICAL'
                      ? AppTheme.criticalRed.withValues(alpha: 0.4)
                      : (appState.weatherAlertSeverity == 'WARNING' ? Colors.amber.shade400 : AppTheme.primaryGreen.withValues(alpha: 0.4)),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    appState.weatherAlertSeverity == 'CRITICAL'
                        ? Icons.warning_rounded
                        : (appState.weatherAlertSeverity == 'WARNING' ? Icons.info_outline : Icons.check_circle_outline),
                    color: appState.weatherAlertSeverity == 'CRITICAL'
                        ? AppTheme.criticalRed
                        : (appState.weatherAlertSeverity == 'WARNING' ? Colors.deepOrange : AppTheme.primaryGreen),
                    size: 26,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.weatherAlertTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: appState.weatherAlertSeverity == 'CRITICAL'
                                ? AppTheme.criticalRed
                                : (appState.weatherAlertSeverity == 'WARNING' ? Colors.deepOrange : AppTheme.primaryDark),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appState.weatherAdvice,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. CHẾ ĐỘ ĐI VẮNG / NGHỈ DƯỠNG (US-036)
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: SwitchListTile(
                secondary: const Icon(Icons.flight_takeoff, color: AppTheme.primaryGreen),
                title: const Text('Chế độ Đi Vắng / Nghỉ Dưỡng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Tự động tạm dừng chuông nhắc nhở và tối ưu chu kỳ ẩm', style: TextStyle(fontSize: 12)),
                value: appState.isVacationMode,
                activeThumbColor: AppTheme.primaryGreen,
                onChanged: (val) {
                  appState.toggleVacationMode(val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(val ? 'Đã BẬT Chế độ Đi Vắng!' : 'Đã TẮT Chế độ Đi Vắng.'),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // 4. DANH SÁCH VIỆC CẦN LÀM HÔM NAY (US-027 .. US-030)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Việc Cần Làm Hôm Nay',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.neutralDark),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: appState.pendingTasksCount > 0 ? AppTheme.primaryGreen : AppTheme.neutralMuted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${appState.pendingTasksCount} việc',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                if (appState.pendingTasksCount > 0)
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: AppTheme.primaryGreen),
                    onPressed: () {
                      appState.markAllWateringCompleted();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã tưới nước cho toàn bộ chậu cây ban công!'),
                          backgroundColor: AppTheme.primaryGreen,
                        ),
                      );
                    },
                    icon: const Icon(Icons.done_all, size: 16),
                    label: const Text('Tưới tất cả', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            if (appState.schedules.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Khu vườn của bạn chưa có lịch cần thực hiện hôm nay.')),
              )
            else
              ...appState.schedules.map((sch) {
                final bool isDone = sch['is_completed'] == true;
                final bool isPostponed = sch['is_postponed'] == true;
                final bool isSpray = sch['task_type'] == 'SPRAY_REMINDER';

                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    isSpray ? Icons.medication_outlined : Icons.water_drop,
                                    color: isDone ? AppTheme.neutralMuted : (isSpray ? Colors.purple : AppTheme.primaryGreen),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      sch['title'] ?? 'Nhiệm vụ',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        decoration: isDone ? TextDecoration.lineThrough : null,
                                        color: isDone ? AppTheme.neutralMuted : AppTheme.neutralDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              sch['scheduled_time'] ?? '',
                              style: const TextStyle(color: AppTheme.neutralMuted, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Chậu cây: ${sch['plant_name']}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        if (isPostponed && sch['skip_reason'] != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            sch['skip_reason'],
                            style: const TextStyle(fontSize: 11, color: Colors.deepOrange, fontStyle: FontStyle.italic),
                          ),
                        ],
                        const SizedBox(height: 10),

                        // Nút hành động với ràng buộc trạng thái thật
                        if (!isDone && !isPostponed)
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSpray ? Colors.purple : AppTheme.primaryGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    appState.markWateringCompleted(sch['id']);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(isSpray ? 'Đã hoàn thành xịt phác đồ!' : 'Đã tưới nước cho chậu cây thành công!'),
                                        backgroundColor: AppTheme.primaryGreen,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.check, size: 16),
                                  label: Text(isSpray ? 'Đã xịt xong' : 'Đã tưới', style: const TextStyle(fontSize: 12)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    appState.postponeSchedule(sch['id']);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Đã dời lịch sang ngày mai!'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.update, size: 16),
                                  label: const Text('Hoãn 1 ngày', style: TextStyle(fontSize: 12)),
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Icon(
                                isDone ? Icons.check_circle : Icons.schedule,
                                color: isDone ? AppTheme.primaryGreen : Colors.deepOrange,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isDone ? '✓ Đã hoàn tất hôm nay' : 'Đã dời sang ngày mai',
                                style: TextStyle(
                                  color: isDone ? AppTheme.primaryGreen : Colors.deepOrange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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

  Widget _buildWeatherMetric(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
