import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';

/// App theme
enum AppTheme {
  @JsonValue('light')
  light,
  @JsonValue('dark')
  dark,
  @JsonValue('system')
  system,
}

/// Supported languages
enum AppLanguage {
  @JsonValue('en')
  english,
  @JsonValue('es')
  spanish,
  @JsonValue('fr')
  french,
  @JsonValue('de')
  german,
}

/// User settings model
@JsonSerializable()
class UserSettings {
  final bool notificationsEnabled;
  final String? dailyReminderTime;
  final bool soundEnabled;
  final AppTheme theme;
  final AppLanguage language;
  final String? streakGoal;

  const UserSettings({
    required this.notificationsEnabled,
    this.dailyReminderTime,
    required this.soundEnabled,
    required this.theme,
    required this.language,
    this.streakGoal,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$UserSettingsToJson(this);

  /// Default settings
  factory UserSettings.defaults() => const UserSettings(
        notificationsEnabled: true,
        dailyReminderTime: null,
        soundEnabled: true,
        theme: AppTheme.system,
        language: AppLanguage.english,
        streakGoal: 'THREE_PER_WEEK',
      );

  UserSettings copyWith({
    bool? notificationsEnabled,
    String? dailyReminderTime,
    bool? soundEnabled,
    AppTheme? theme,
    AppLanguage? language,
    String? streakGoal,
  }) {
    return UserSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      streakGoal: streakGoal ?? this.streakGoal,
    );
  }

  /// Display name for theme
  String get themeDisplayName {
    switch (theme) {
      case AppTheme.light:
        return 'Light';
      case AppTheme.dark:
        return 'Dark';
      case AppTheme.system:
        return 'System';
    }
  }

  /// Display name for language
  String get languageDisplayName {
    switch (language) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.spanish:
        return 'Spanish';
      case AppLanguage.french:
        return 'French';
      case AppLanguage.german:
        return 'German';
    }
  }

  /// Display name for streak goal
  String get streakGoalDisplayName {
    switch (streakGoal) {
      case 'DAILY':
        return 'Daily';
      case 'FIVE_PER_WEEK':
        return '5x per week';
      case 'THREE_PER_WEEK':
        return '3x per week';
      case 'TWO_PER_WEEK':
        return '2x per week';
      default:
        return '3x per week';
    }
  }
}

/// Request to update settings
@JsonSerializable()
class UpdateSettingsRequest {
  final bool? notificationsEnabled;
  final String? dailyReminderTime;
  final bool? soundEnabled;
  final String? theme;
  final String? language;
  final String? streakGoal;

  const UpdateSettingsRequest({
    this.notificationsEnabled,
    this.dailyReminderTime,
    this.soundEnabled,
    this.theme,
    this.language,
    this.streakGoal,
  });

  factory UpdateSettingsRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateSettingsRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateSettingsRequestToJson(this);
}
