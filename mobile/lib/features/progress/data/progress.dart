import 'package:json_annotation/json_annotation.dart';

part 'progress.g.dart';

/// Streak goal type
enum StreakGoal {
  @JsonValue('DAILY')
  daily,
  @JsonValue('FIVE_PER_WEEK')
  fivePerWeek,
  @JsonValue('THREE_PER_WEEK')
  threePerWeek,
  @JsonValue('TWO_PER_WEEK')
  twoPerWeek,
}

/// Progress stats for a child
/// Backend returns: childId, name, totalStars, availableStars, totalSessions,
/// completedSessions, averageStarsPerSession, skillProgress
@JsonSerializable()
class ProgressStats {
  final String childId;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: 0)
  final int totalStars;
  @JsonKey(defaultValue: 0)
  final int availableStars;
  @JsonKey(defaultValue: 0)
  final int totalSessions;
  @JsonKey(defaultValue: 0)
  final int completedSessions;
  @JsonKey(defaultValue: 0)
  final int averageStarsPerSession;
  @JsonKey(defaultValue: {})
  final Map<String, dynamic> skillProgress;

  const ProgressStats({
    required this.childId,
    this.name = '',
    required this.totalStars,
    required this.availableStars,
    required this.totalSessions,
    this.completedSessions = 0,
    this.averageStarsPerSession = 0,
    this.skillProgress = const {},
  });

  factory ProgressStats.fromJson(Map<String, dynamic> json) =>
      _$ProgressStatsFromJson(json);
  Map<String, dynamic> toJson() => _$ProgressStatsToJson(this);

  ProgressStats copyWith({
    String? childId,
    String? name,
    int? totalStars,
    int? availableStars,
    int? totalSessions,
    int? completedSessions,
    int? averageStarsPerSession,
    Map<String, dynamic>? skillProgress,
  }) {
    return ProgressStats(
      childId: childId ?? this.childId,
      name: name ?? this.name,
      totalStars: totalStars ?? this.totalStars,
      availableStars: availableStars ?? this.availableStars,
      totalSessions: totalSessions ?? this.totalSessions,
      completedSessions: completedSessions ?? this.completedSessions,
      averageStarsPerSession: averageStarsPerSession ?? this.averageStarsPerSession,
      skillProgress: skillProgress ?? this.skillProgress,
    );
  }
}

/// Streak info for a child
@JsonSerializable()
class StreakInfo {
  final String childId;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastSessionDate;
  final int weeklySessionCount;
  final int weeklyGoal;
  final bool goalMet;
  final DateTime weekStartDate;

  const StreakInfo({
    required this.childId,
    required this.currentStreak,
    required this.longestStreak,
    this.lastSessionDate,
    required this.weeklySessionCount,
    required this.weeklyGoal,
    required this.goalMet,
    required this.weekStartDate,
  });

  factory StreakInfo.fromJson(Map<String, dynamic> json) =>
      _$StreakInfoFromJson(json);
  Map<String, dynamic> toJson() => _$StreakInfoToJson(this);

  StreakInfo copyWith({
    String? childId,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastSessionDate,
    int? weeklySessionCount,
    int? weeklyGoal,
    bool? goalMet,
    DateTime? weekStartDate,
  }) {
    return StreakInfo(
      childId: childId ?? this.childId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      weeklySessionCount: weeklySessionCount ?? this.weeklySessionCount,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
      goalMet: goalMet ?? this.goalMet,
      weekStartDate: weekStartDate ?? this.weekStartDate,
    );
  }

  /// Get progress towards weekly goal (0.0 - 1.0)
  double get weeklyProgress =>
      weeklyGoal > 0 ? (weeklySessionCount / weeklyGoal).clamp(0.0, 1.0) : 0.0;

  /// Sessions remaining to meet goal
  int get sessionsRemaining =>
      (weeklyGoal - weeklySessionCount).clamp(0, weeklyGoal);

  /// Display string for streak goal
  String get goalDisplayName {
    switch (weeklyGoal) {
      case 7:
        return 'Daily';
      case 5:
        return '5x per week';
      case 3:
        return '3x per week';
      case 2:
        return '2x per week';
      default:
        return '$weeklyGoal sessions';
    }
  }
}
