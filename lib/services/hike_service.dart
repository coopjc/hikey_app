import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../config/api_config.dart';
import '../models/hike.dart';
import '../models/hike_point.dart';
import '../models/paged.dart';

class HikeService {
  HikeService({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<Paged<Hike>> getHikes({
    int page = 0,
    int size = 10,
    String sortBy = 'id',
    String direction = 'asc',
  }) async {
    final Map<String, dynamic> json = await _api.get(
      ApiConfig.getHikesPath,
      query: <String, String>{
        'page': '$page',
        'size': '$size',
        'sortBy': sortBy,
        'direction': direction,
      },
    );

    final Object? data = json['data'];

    if (data is! Map<String, dynamic> ||
        data['content'] is! List<dynamic> ||
        data['page'] is! Map<String, dynamic>) {
      throw ApiException('Unexpected hikes response from the server.');
    }

    return Paged<Hike>.fromJson(data, Hike.fromJson);
  }

  Future<Hike> getHike(int hikeId) async {
    final Map<String, dynamic> json = await _api.get(
      ApiConfig.hikePath(hikeId),
    );

    final Object? data = json['data'];

    if (data is! Map<String, dynamic>) {
      throw ApiException('Unexpected hike response from the server.');
    }

    return Hike.fromJson(data);
  }

  Future<Hike> startHike({required String name}) async {
    final Map<String, dynamic> json = await _api.post(
      ApiConfig.createHikePath,
      body: <String, dynamic>{'name': name},
    );

    final Object? data = json['data'];

    if (data is! Map<String, dynamic>) {
      throw ApiException('Unexpected create hike response from the server.');
    }

    return Hike.fromJson(data);
  }

  Future<Hike> pauseHike(int hikeId) =>
      _transitionHike(ApiConfig.pauseHikePath(hikeId), 'pause');

  Future<Hike> resumeHike(int hikeId) =>
      _transitionHike(ApiConfig.resumeHikePath(hikeId), 'resume');

  Future<Hike> completeHike(int hikeId) =>
      _transitionHike(ApiConfig.completeHikePath(hikeId), 'complete');

  Future<Hike> _transitionHike(String path, String action) async {
    final Map<String, dynamic> json = await _api.post(path);

    final Object? data = json['data'];

    if (data is! Map<String, dynamic>) {
      throw ApiException('Unexpected $action hike response from the server.');
    }

    return Hike.fromJson(data);
  }

  Future<void> updateHike(int hikeId, {String? name, String? notes}) async {
    await _api.patch(
      ApiConfig.hikePath(hikeId),
      body: <String, dynamic>{'name': ?name, 'notes': ?notes},
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

  Future<int> pushHikePoints(int hikeId, List<HikePoint> points) async {
    final Map<String, dynamic> json = await _api.post(
      ApiConfig.hikePointsPath(hikeId),
      body: <String, dynamic>{
        'hike_points': points.map((HikePoint p) => p.toJson()).toList(),
      },
    );

    final Object? data = json['data'];

    if (data is! List<dynamic>) {
      throw ApiException(
        'Unexpected push hike points response from the server.',
      );
    }

    return data.length;
  }
}
