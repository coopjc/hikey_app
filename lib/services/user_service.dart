import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../config/api_config.dart';
import '../models/hike_stats.dart';

class UserService {
  UserService({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<HikeStats> getStats() async {
    final Map<String, dynamic> json = await _api.get(
      ApiConfig.currentUserStatsPath,
    );

    final Object? data = json['data'];

    if (data is! Map<String, dynamic>) {
      throw ApiException('Unexpected stats response from the server.');
    }

    return HikeStats.fromJson(data);
  }
}
