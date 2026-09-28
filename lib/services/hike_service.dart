import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../config/api_config.dart';
import '../models/hike.dart';
import '../models/hike_point.dart';

class HikeService {
  HikeService({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<List<Hike>> getHikes() async {
    final Map<String, dynamic> json = await _api.get(ApiConfig.getHikesPath);

    final Object? data = json['data'];

    if (data is! Map<String, dynamic> || data['hikes'] is! List<dynamic>) {
      throw ApiException('Unexpected hikes response from the server.');
    }

    return (data['hikes'] as List<dynamic>)
        .map((dynamic h) => Hike.fromJson(h as Map<String, dynamic>))
        .toList();
  }

  Future<Hike> createHike({required String name, String? notes}) async {
    final Map<String, dynamic> json = await _api.post(
      ApiConfig.createHikePath,
      body: <String, dynamic>{'name': name, 'notes': notes},
    );

    final Object? data = json['data'];

    if (data is! Map<String, dynamic>) {
      throw ApiException('Unexpected create hike response from the server.');
    }

    return Hike.fromJson(data);
  }

  Future<void> updateHike(
    int hikeId, {
    String? name,
    String? notes,
    HikeStatus? status,
    double? distanceMiles,
    Duration? duration,
  }) async {
    await _api.patch(
      ApiConfig.hikePath(hikeId),
      body: <String, dynamic>{
        'name': ?name,
        'notes': ?notes,
        'status': ?status,
        'distance_miles': ?distanceMiles,
        if (duration != null)
          'duration_min':
              duration.inMilliseconds / Duration.millisecondsPerMinute,
      },
    );
  }

  Future<void> deleteHike(int hikeId) async {
    await _api.delete(ApiConfig.hikePath(hikeId));
  }

  Future<List<HikePoint>> getHikePoints(int hikeId) async {
    final Map<String, dynamic> json = await _api.get(
      ApiConfig.hikePointsPath(hikeId),
    );

    final Object? data = json['data'];

    if (data is! Map<String, dynamic> ||
        data['hike_points'] is! List<dynamic>) {
      throw ApiException('Unexpected hike points response from the server.');
    }

    return (data['hike_points'] as List<dynamic>)
        .map((dynamic h) => HikePoint.fromJson(h as Map<String, dynamic>))
        .toList();
  }

  Future<void> pushHikePoints(int hikeId, List<HikePoint> points) async {
    await _api.post(
      ApiConfig.hikePointsPath(hikeId),
      body: <String, dynamic>{
        'hike_points': points.map((HikePoint p) => p.toJson()).toList(),
      },
    );
  }
}
