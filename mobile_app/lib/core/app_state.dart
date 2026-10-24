import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class CityWeatherInfo {
  final String name;
  final double lat;
  final double lon;

  const CityWeatherInfo(this.name, this.lat, this.lon);
}

class AppState extends ChangeNotifier {
  // 1. TÀI KHOẢN & VIP GATE
  bool _isVip = false;
  int _scansRemaining = 3;
  final String _userName = 'Hoàng Minh Triều';
  final String _userEmail = 'trieu.urbanplants@gmail.com';
  final String _userRole = 'USER';
  final List<Map<String, dynamic>> _invoices = [];

  bool get isVip => _isVip;
  int get scansRemaining => _scansRemaining;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userRole => _userRole;
  List<Map<String, dynamic>> get invoices => List.unmodifiable(_invoices);

  void upgradeToVip(String plan, String method, String txCode, int amount) {
    _isVip = true;
    _scansRemaining = 999999;
    _invoices.insert(0, {
      'invoice_code': 'INV-UP-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      'plan': plan == 'MONTHLY' ? 'VIP Pro 1 Tháng' : 'VIP Pro 1 Năm',
      'amount_vnd': amount,
      'payment_method': method,
      'tx_code': txCode,
      'created_at': DateTime.now().toString().substring(0, 16),
      'status': 'THÀNH CÔNG',
    });
    notifyListeners();
  }

  void resetToFreeUser() {
    _isVip = false;
    _scansRemaining = 3;
    notifyListeners();
  }

  void decrementScan() {
    if (!_isVip && _scansRemaining > 0) {
      _scansRemaining--;
      notifyListeners();
    }
  }

  // 2. THỜI TIẾT THỰC TẾ & GPS THIẾT BỊ TRỰC TIẾP (OPEN-METEO)
  double _currentLatitude = 10.8231;
  double _currentLongitude = 106.6297;
  String _currentLocationName = 'Đang định vị GPS máy...';
  bool _isGpsActive = false;
  bool _isLocatingGps = false;
  String? _gpsErrorMessage;

  double _temperature = 29.5;
  int _humidity = 72;
  int _rainProbability = 20;
  double _windSpeed = 12.0;
  final String _weatherDescription = 'Mây rải rác, trời dịu';
  String _weatherAdvice = 'Thời tiết lý tưởng cho cây ban công quang hợp.';
  String _weatherAlertTitle = '';
  String _weatherAlertSeverity = 'NORMAL'; // NORMAL, WARNING, CRITICAL
  bool _isLoadingWeather = false;

  double get currentLatitude => _currentLatitude;
  double get currentLongitude => _currentLongitude;
  String get currentLocationName => _currentLocationName;
  bool get isGpsActive => _isGpsActive;
  bool get isLocatingGps => _isLocatingGps;
  String? get gpsErrorMessage => _gpsErrorMessage;

  CityWeatherInfo get selectedCity => CityWeatherInfo(_currentLocationName, _currentLatitude, _currentLongitude);
  double get temperature => _temperature;
  int get humidity => _humidity;
  int get rainProbability => _rainProbability;
  double get windSpeed => _windSpeed;
  String get weatherDescription => _weatherDescription;
  String get weatherAdvice => _weatherAdvice;
  String get weatherAlertTitle => _weatherAlertTitle;
  String get weatherAlertSeverity => _weatherAlertSeverity;
  bool get isLoadingWeather => _isLoadingWeather;

  /// Tự động cập nhật vị trí GPS trực tiếp từ điện thoại & lấy thời tiết Open-Meteo
  Future<void> updateCurrentDeviceLocation() async {
    _isLocatingGps = true;
    _gpsErrorMessage = null;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _gpsErrorMessage = 'GPS thiết bị chưa bật';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _gpsErrorMessage = 'Chưa cấp quyền truy cập vị trí';
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );

      _currentLatitude = position.latitude;
      _currentLongitude = position.longitude;
      _isGpsActive = true;
      _gpsErrorMessage = null;

      // Reverse geocode tìm tên địa danh tiếng Việt thực tế
      try {
        final geoDio = Dio();
        final geoUrl =
            'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$_currentLatitude&longitude=$_currentLongitude&localityLanguage=vi';
        final geoRes = await geoDio.get(geoUrl, options: Options(receiveTimeout: const Duration(seconds: 4)));
        if (geoRes.statusCode == 200 && geoRes.data != null) {
          final data = geoRes.data;
          final locality = data['locality'] as String? ?? '';
          final city = data['city'] as String? ?? data['principalSubdivision'] as String? ?? '';
          if (locality.isNotEmpty && city.isNotEmpty && locality != city) {
            _currentLocationName = '$locality, $city';
          } else if (city.isNotEmpty) {
            _currentLocationName = city;
          } else {
            _currentLocationName = 'Vị trí máy (${_currentLatitude.toStringAsFixed(2)}°, ${_currentLongitude.toStringAsFixed(2)}°)';
          }
        } else {
          _currentLocationName = 'Vị trí máy (${_currentLatitude.toStringAsFixed(2)}°, ${_currentLongitude.toStringAsFixed(2)}°)';
        }
      } catch (_) {
        _currentLocationName = 'Vị trí máy (${_currentLatitude.toStringAsFixed(2)}°, ${_currentLongitude.toStringAsFixed(2)}°)';
      }
    } catch (e) {
      debugPrint('[AppState] Định vị GPS thiết bị: $e');
      if (_currentLocationName == 'Đang định vị GPS máy...') {
        _currentLocationName = 'Vị trí thiết bị (Tự động)';
      }
      _isGpsActive = false;
    } finally {
      _isLocatingGps = false;
      notifyListeners();
      await fetchLiveWeather();
    }
  }

  Future<void> fetchLiveWeather() async {
    _isLoadingWeather = true;
    notifyListeners();

    try {
      final dio = Dio();
      final url =
          'https://api.open-meteo.com/v1/forecast?latitude=$_currentLatitude&longitude=$_currentLongitude&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,rain,weather_code,wind_speed_10m&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max&timezone=Asia%2FBangkok';
      final response = await dio.get(url, options: Options(receiveTimeout: const Duration(seconds: 8)));

      if (response.statusCode == 200 && response.data != null) {
        final current = response.data['current'] ?? {};
        final daily = response.data['daily'] ?? {};

        _temperature = (current['temperature_2m'] as num?)?.toDouble() ?? 30.0;
        _humidity = (current['relative_humidity_2m'] as num?)?.toInt() ?? 70;
        _windSpeed = (current['wind_speed_10m'] as num?)?.toDouble() ?? 10.0;

        final rainList = daily['precipitation_probability_max'] as List?;
        if (rainList != null && rainList.isNotEmpty) {
          _rainProbability = (rainList[0] as num).toInt();
        } else {
          final rainVal = (current['rain'] as num?)?.toDouble() ?? 0.0;
          _rainProbability = rainVal > 0 ? 80 : 20;
        }

        // Logic ràng buộc cảnh báo theo dữ liệu thật (US-032, US-033, US-034)
        if (_temperature >= 35.0) {
          _weatherAlertSeverity = 'CRITICAL';
          _weatherAlertTitle = 'CẢNH BÁO NẮNG NÓNG / SỐC NHIỆT (>= 35°C)';
          _weatherAdvice =
              'Nắng gắt gay gắt. Kéo lưới lan che chắn, KHÔNG tưới đẫm lên lá giữa trưa kẻo cháy lá. Dời lịch tưới sang 17h30 chiều.';
        } else if (_rainProbability >= 60 || ((current['rain'] as num?)?.toDouble() ?? 0) > 0) {
          _weatherAlertSeverity = 'WARNING';
          _weatherAlertTitle = 'ĐỀ XUẤT HOÃN TƯỚI NƯỚC (Xác suất mưa $_rainProbability%)';
          _weatherAdvice =
              'Độ ẩm cao và sắp có mưa giông. Tự động đề xuất hoãn tưới chậu ban công hôm nay để phòng ngừa thối rễ, úng nước.';
        } else if (_temperature <= 16.0) {
          _weatherAlertSeverity = 'WARNING';
          _weatherAlertTitle = 'RÉT ĐẬM & GIÓ LẠNH';
          _weatherAdvice = 'Nhiệt độ hạ thấp. Cần di chuyển kiểng lá nhiệt đới (Monstera, trầu bà) vào góc khuất gió.';
        } else {
          _weatherAlertSeverity = 'NORMAL';
          _weatherAlertTitle = 'THỜI TIẾT LÝ TƯỞNG CHO CÂY BAN CÔNG';
          _weatherAdvice =
              'Điều kiện môi trường mát mẻ, nắng dịu. Thích hợp tưới định kỳ theo độ ẩm chậu và quang hợp tự nhiên.';
        }
      }
    } catch (e) {
      debugPrint('[AppState] Lỗi gọi Open-Meteo, sử dụng dữ liệu mặc định an toàn: $e');
    } finally {
      _isLoadingWeather = false;
      notifyListeners();
    }
  }

  // 3. VƯỜN CỦA TÔI & DANH SÁCH CHẬU CÂY
  final List<Map<String, dynamic>> _plants = [
    {
      'id': 'plt_01',
      'name': 'Hoa Hồng Mon Coeur',
      'sci_name': 'Rosa hybrida',
      'location': 'Ban công hướng Đông',
      'soil_moisture': 55,
      'health_status': 'CẦN CHĂM SÓC',
      'disease_name': 'Bệnh Phấn Trắng (Powdery Mildew)',
      'image_url': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=400&q=80',
      'water_interval': 1,
      'last_watered': 'Hôm qua',
    },
    {
      'id': 'plt_02',
      'name': 'Cà Chua Bi Ban Công',
      'sci_name': 'Solanum lycopersicum',
      'location': 'Sân thượng tầng 3',
      'soil_moisture': 78,
      'health_status': 'KHỎE MẠNH',
      'disease_name': null,
      'image_url': 'https://images.unsplash.com/photo-1592841200221-a6898f307baa?auto=format&fit=crop&w=400&q=80',
      'water_interval': 2,
      'last_watered': 'Sáng nay lúc 07:15',
    },
    {
      'id': 'plt_03',
      'name': 'Sen Đá Kim Cương',
      'sci_name': 'Haworthia cooperi',
      'location': 'Bậu cửa sổ phòng khách',
      'soil_moisture': 42,
      'health_status': 'KHỎE MẠNH',
      'disease_name': null,
      'image_url': 'https://images.unsplash.com/photo-1509423350716-97f9360b4e09?auto=format&fit=crop&w=400&q=80',
      'water_interval': 5,
      'last_watered': '3 ngày trước',
    },
    {
      'id': 'plt_04',
      'name': 'Monstera Trầu Bà Nam Mỹ',
      'sci_name': 'Monstera deliciosa',
      'location': 'Góc ban công râm mát',
      'soil_moisture': 65,
      'health_status': 'KHỎE MẠNH',
      'disease_name': null,
      'image_url': 'https://images.unsplash.com/photo-1614594975525-e45190c55d0b?auto=format&fit=crop&w=400&q=80',
      'water_interval': 3,
      'last_watered': 'Hôm qua lúc 18:00',
    },
  ];

  List<Map<String, dynamic>> get plants => List.unmodifiable(_plants);

  void addPlant(Map<String, dynamic> plant) {
    _plants.add(plant);
    notifyListeners();
  }

  void updatePlantHealth(String plantId, String status, {String? diseaseName}) {
    for (var p in _plants) {
      if (p['id'] == plantId) {
        p['health_status'] = status;
        p['disease_name'] = diseaseName;
        break;
      }
    }
    notifyListeners();
  }

  // 4. LỊCH TƯỚI & VIỆC CẦN LÀM (US-027 .. US-030)
  bool _isVacationMode = false;
  bool get isVacationMode => _isVacationMode;

  void toggleVacationMode(bool val) {
    _isVacationMode = val;
    notifyListeners();
  }

  final List<Map<String, dynamic>> _schedules = [
    {
      'id': 'sch_01',
      'plant_id': 'plt_01',
      'plant_name': 'Hoa Hồng Mon Coeur',
      'task_type': 'WATERING',
      'title': 'Tưới nước ban công hướng Đông',
      'scheduled_time': '07:30 Sáng',
      'is_completed': false,
      'is_postponed': false,
      'skip_reason': null,
    },
    {
      'id': 'sch_02',
      'plant_id': 'plt_04',
      'plant_name': 'Monstera Trầu Bà Nam Mỹ',
      'task_type': 'WATERING',
      'title': 'Tưới ẩm gốc và lau bụi mặt lá',
      'scheduled_time': '17:30 Chiều',
      'is_completed': false,
      'is_postponed': false,
      'skip_reason': null,
    },
  ];

  List<Map<String, dynamic>> get schedules => List.unmodifiable(_schedules);

  int get pendingTasksCount =>
      _schedules.where((s) => !s['is_completed'] && !s['is_postponed']).length;

  void markWateringCompleted(String scheduleId) {
    for (var s in _schedules) {
      if (s['id'] == scheduleId) {
        s['is_completed'] = true;
        // Cập nhật độ ẩm chậu cây tương ứng
        final pId = s['plant_id'];
        for (var p in _plants) {
          if (p['id'] == pId) {
            p['soil_moisture'] = 85;
            p['last_watered'] = 'Vừa tưới lúc ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
            break;
          }
        }
        break;
      }
    }
    notifyListeners();
  }

  void markAllWateringCompleted() {
    for (var s in _schedules) {
      if (s['task_type'] == 'WATERING') {
        s['is_completed'] = true;
      }
    }
    for (var p in _plants) {
      p['soil_moisture'] = 85;
      p['last_watered'] = 'Vừa tưới lúc ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    }
    notifyListeners();
  }

  void postponeSchedule(String scheduleId) {
    for (var s in _schedules) {
      if (s['id'] == scheduleId) {
        s['is_postponed'] = true;
        s['skip_reason'] = 'Đã hoãn lịch sang ngày mai theo yêu cầu người dùng';
        break;
      }
    }
    notifyListeners();
  }

  void addSprayReminderSchedule(String diseaseName, int delayDays) {
    final nextDate = DateTime.now().add(Duration(days: delayDays));
    _schedules.add({
      'id': 'sch_spray_${DateTime.now().millisecondsSinceEpoch}',
      'plant_id': _activeDiagnosedPlantId ?? 'plt_01',
      'plant_name': _activeDiagnosedPlantName,
      'task_type': 'SPRAY_REMINDER',
      'title': 'Xịt nhắc phác đồ Safe-First: $diseaseName (Lần 2)',
      'scheduled_time': '17:30 Chiều (${nextDate.day}/${nextDate.month})',
      'is_completed': false,
      'is_postponed': false,
      'skip_reason': null,
    });
    notifyListeners();
  }

  // 5. CA BỆNH ĐANG CHẨN ĐOÁN & PHÁC ĐỒ AN TOÀN (SAFE-FIRST)
  bool _hasActiveDiagnosis = false;
  String? _activeDiagnosedPlantId;
  String _activeDiagnosedPlantName = 'Hoa Hồng Mon Coeur';
  String _activeDiseaseName = 'Bệnh Phấn Trắng (Powdery Mildew)';
  String _activeDiseaseSci = 'Podosphaera pannosa';
  double _activeConfidence = 0.942;
  String _activeHeatmapDescription =
      'Bản đồ nhiệt Grad-CAM phát hiện cụm phấn nấm trắng mật độ cao phân bố chủ yếu ở phiến lá và gân lá non.';
  String? _activeLeafImageUrl;

  bool _step1Completed = false;
  bool _step2Completed = false;
  bool _step3Unlocked = false;
  double _sprayBottleVolumeLiters = 1.0; // 0.5, 1.0, 2.0
  bool _hasScheduledSprayReminder = false;

  bool get hasActiveDiagnosis => _hasActiveDiagnosis;
  String? get activeDiagnosedPlantId => _activeDiagnosedPlantId;
  String get activeDiagnosedPlantName => _activeDiagnosedPlantName;
  String get activeDiseaseName => _activeDiseaseName;
  String get activeDiseaseSci => _activeDiseaseSci;
  double get activeConfidence => _activeConfidence;
  String get activeHeatmapDescription => _activeHeatmapDescription;
  String? get activeLeafImageUrl => _activeLeafImageUrl;

  bool get step1Completed => _step1Completed;
  bool get step2Completed => _step2Completed;
  bool get step3Unlocked => _step3Unlocked;
  double get sprayBottleVolumeLiters => _sprayBottleVolumeLiters;
  bool get hasScheduledSprayReminder => _hasScheduledSprayReminder;

  void setActiveDiagnosis({
    required String plantId,
    required String plantName,
    required String diseaseName,
    required String diseaseSci,
    required double confidence,
    required String heatmapDesc,
    String? imageUrl,
  }) {
    _hasActiveDiagnosis = true;
    _activeDiagnosedPlantId = plantId;
    _activeDiagnosedPlantName = plantName;
    _activeDiseaseName = diseaseName;
    _activeDiseaseSci = diseaseSci;
    _activeConfidence = confidence;
    _activeHeatmapDescription = heatmapDesc;
    _activeLeafImageUrl = imageUrl;

    // Reset các bước phác đồ cho ca bệnh mới
    _step1Completed = false;
    _step2Completed = false;
    _step3Unlocked = false;
    _hasScheduledSprayReminder = false;

    // Cập nhật trạng thái cây trong vườn
    updatePlantHealth(plantId, 'ĐANG ĐIỀU TRỊ', diseaseName: diseaseName);
    notifyListeners();
  }

  void completeStep1() {
    _step1Completed = true;
    notifyListeners();
  }

  void setSprayVolume(double volume) {
    _sprayBottleVolumeLiters = volume;
    notifyListeners();
  }

  void completeStep2() {
    _step2Completed = true;
    _step3Unlocked = true;
    notifyListeners();
  }

  void markDiseaseWorsened() {
    _step3Unlocked = true;
    if (_activeDiagnosedPlantId != null) {
      updatePlantHealth(_activeDiagnosedPlantId!, 'CẦN CÁCH LY GẤP', diseaseName: _activeDiseaseName);
    }
    notifyListeners();
  }

  void markDiseaseCured() {
    _step1Completed = true;
    _step2Completed = true;
    _step3Unlocked = true;
    if (_activeDiagnosedPlantId != null) {
      updatePlantHealth(_activeDiagnosedPlantId!, 'KHỎE MẠNH', diseaseName: null);
    }
    notifyListeners();
  }

  void setScheduledSprayReminder(bool val) {
    _hasScheduledSprayReminder = val;
    notifyListeners();
  }
}
