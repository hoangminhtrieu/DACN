import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GardenApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Options> _authOptions() async {
    final token = await _storage.read(key: 'jwt_token');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // US-016, US-017, US-018: Catalog
  Future<List<dynamic>> getCatalog({String? query, String? light, String? difficulty}) async {
    final Map<String, dynamic> params = {};
    if (query != null && query.isNotEmpty) params['q'] = query;
    if (light != null) params['light'] = light;
    if (difficulty != null) params['difficulty'] = difficulty;

    final response = await _dio.get('/garden/catalog', queryParameters: params);
    return response.data;
  }

  // US-019, US-025: Gardens & Plants
  Future<List<dynamic>> getMyGardens() async {
    final opts = await _authOptions();
    final response = await _dio.get('/garden/gardens', options: opts);
    return response.data;
  }

  Future<Map<String, dynamic>> createGarden(String name, String locationTag, bool isOutdoor) async {
    final opts = await _authOptions();
    final response = await _dio.post('/garden/gardens', options: opts, data: {
      'garden_name': name,
      'location_tag': locationTag,
      'is_outdoor': isOutdoor,
    });
    return response.data;
  }

  Future<List<dynamic>> getMyPlants() async {
    final opts = await _authOptions();
    final response = await _dio.get('/garden/plants', options: opts);
    return response.data;
  }

  Future<Map<String, dynamic>> addPlant({
    String? gardenId,
    String? catalogId,
    required String customName,
    String? photoUrl,
    required String locationTag,
    int potSizeCm = 25,
    int? customWaterIntervalDays,
  }) async {
    final opts = await _authOptions();
    final response = await _dio.post('/garden/plants', options: opts, data: {
      'garden_id': gardenId,
      'catalog_id': catalogId,
      'custom_name': customName,
      'photo_url': photoUrl,
      'location_tag': locationTag,
      'pot_size_cm': potSizeCm,
      'custom_water_interval_days': customWaterIntervalDays,
    });
    return response.data;
  }

  // US-022: Growth Logs
  Future<List<dynamic>> getGrowthLogs(String plantId) async {
    final opts = await _authOptions();
    final response = await _dio.get('/garden/plants/$plantId/growth-logs', options: opts);
    return response.data;
  }

  Future<Map<String, dynamic>> addGrowthLog({
    required String plantId,
    double? heightCm,
    String? milestone,
    String? note,
    String? photoUrl,
  }) async {
    final opts = await _authOptions();
    final response = await _dio.post('/garden/growth-logs', options: opts, data: {
      'user_plant_id': plantId,
      'height_cm': heightCm,
      'growth_milestone': milestone,
      'note': note,
      'photo_url': photoUrl,
    });
    return response.data;
  }

  // US-026: Export Report
  Future<Map<String, dynamic>> getPlantReport(String plantId) async {
    final opts = await _authOptions();
    final response = await _dio.get('/garden/plants/$plantId/report', options: opts);
    return response.data;
  }

  // US-027, US-029: Smart Schedules
  Future<List<dynamic>> getSchedules() async {
    final opts = await _authOptions();
    final response = await _dio.get('/garden/schedules', options: opts);
    return response.data;
  }

  Future<Map<String, dynamic>> performScheduleAction(String scheduleId, String action, {int postponeDays = 1}) async {
    final opts = await _authOptions();
    final response = await _dio.post('/garden/schedules/$scheduleId/action', options: opts, data: {
      'action': action,
      'postpone_days': postponeDays,
    });
    return response.data;
  }

  // US-031 .. US-034: Weather
  Future<Map<String, dynamic>> getWeather(String city) async {
    final response = await _dio.get('/weather/current', queryParameters: {'city': city});
    return response.data;
  }

  // US-036: Vacation Mode
  Future<Map<String, dynamic>> getVacationMode() async {
    final opts = await _authOptions();
    final response = await _dio.get('/garden/vacation', options: opts);
    return response.data;
  }

  Future<Map<String, dynamic>> updateVacationMode(bool isVacation, String? note) async {
    final opts = await _authOptions();
    final response = await _dio.put('/garden/vacation', options: opts, data: {
      'is_vacation_mode': isVacation,
      'vacation_note': note,
    });
    return response.data;
  }
}
