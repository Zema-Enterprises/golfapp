/// Environment configuration
class EnvConfig {
  EnvConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8100/api/v1',
  );

  static const bool isProduction = bool.fromEnvironment(
    'dart.vm.product',
    defaultValue: false,
  );
}

/// App constants
class AppConstants {
  AppConstants._();

  // API
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  // Local storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String pinHashKey = 'pin_hash';

  // Session durations (aligned with backend)
  static const String defaultSessionDuration = '15';
  static const List<String> sessionDurations = ['10', '15', '20'];
  static const Map<String, int> durationToDrillCount = {
    '10': 2,
    '15': 3,
    '20': 4,
  };

  // Gamification (aligned with backend)
  static const int starsPerDrill = 2;
  static const int maxOfflineDays = 7;

  // Streak goals
  static const List<String> streakGoals = [
    'DAILY',
    'FIVE_PER_WEEK',
    'THREE_PER_WEEK',
    'TWO_PER_WEEK',
  ];
  static const String defaultStreakGoal = 'THREE_PER_WEEK';
}
