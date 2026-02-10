import '../../../core/api/api_client.dart';
import 'settings.dart';

/// Settings repository for API calls
class SettingsRepository {
  final ApiClient _apiClient;

  SettingsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get user settings
  Future<UserSettings> getSettings() async {
    final response = await _apiClient.get('/settings');
    return UserSettings.fromJson(response.data['data']['settings']);
  }

  /// Update user settings
  Future<UserSettings> updateSettings(UpdateSettingsRequest request) async {
    // Remove null values to avoid Fastify schema validation errors
    // (null is not accepted for non-nullable fields like theme, language)
    final data = request.toJson()..removeWhere((_, v) => v == null);
    final response = await _apiClient.patch(
      '/settings',
      data: data,
    );
    return UserSettings.fromJson(response.data['data']['settings']);
  }

  /// Update notification settings
  Future<UserSettings> updateNotifications({
    required bool enabled,
    String? reminderTime,
  }) async {
    return updateSettings(UpdateSettingsRequest(
      notificationsEnabled: enabled,
      dailyReminderTime: reminderTime,
    ));
  }

  /// Update sound settings
  Future<UserSettings> updateSound({required bool enabled}) async {
    return updateSettings(UpdateSettingsRequest(soundEnabled: enabled));
  }

  /// Update theme
  Future<UserSettings> updateTheme(AppTheme theme) async {
    return updateSettings(UpdateSettingsRequest(theme: theme.name));
  }

  /// Update language
  Future<UserSettings> updateLanguage(AppLanguage language) async {
    return updateSettings(UpdateSettingsRequest(language: language.name));
  }

  /// Update streak goal
  Future<UserSettings> updateStreakGoal(String goal) async {
    return updateSettings(UpdateSettingsRequest(streakGoal: goal));
  }
}
