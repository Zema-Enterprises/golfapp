import '../../../core/api/api_client.dart';
import 'progress.dart';

/// Progress repository for API calls
class ProgressRepository {
  final ApiClient _apiClient;

  ProgressRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get child progress stats
  Future<ProgressStats> getStats(String childId) async {
    final response = await _apiClient.get('/progress/$childId');
    return ProgressStats.fromJson(response.data['data']['stats']);
  }

  /// Get child streak info
  Future<StreakInfo> getStreak(String childId) async {
    final response = await _apiClient.get('/progress/$childId/streak');
    return StreakInfo.fromJson(response.data['data']['streak']);
  }

  /// Update child streak (called after completing a session)
  Future<StreakInfo> updateStreak(String childId) async {
    final response = await _apiClient.post(
      '/progress/$childId/streak',
      data: {},
    );
    return StreakInfo.fromJson(response.data['data']['streak']);
  }
}
