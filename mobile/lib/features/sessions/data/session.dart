import 'package:json_annotation/json_annotation.dart';
import '../../drills/data/drill.dart';

part 'session.g.dart';

/// Session status
enum SessionStatus {
  @JsonValue('IN_PROGRESS')
  inProgress,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('ABANDONED')
  abandoned,
}

/// Session drill model
/// Maps to backend: id, order, completed, starsEarned, verifiedAt, drill: {id, title, ...}
@JsonSerializable()
class SessionDrill {
  final String id;
  @JsonKey(name: 'order', defaultValue: 0)
  final int orderIndex;
  @JsonKey(name: 'completed', defaultValue: false)
  final bool isCompleted;
  @JsonKey(defaultValue: 0)
  final int starsEarned;
  @JsonKey(name: 'verifiedAt')
  final DateTime? completedAt;
  final Drill? drill;

  const SessionDrill({
    required this.id,
    required this.orderIndex,
    required this.isCompleted,
    required this.starsEarned,
    this.completedAt,
    this.drill,
  });

  /// Get the drill ID from the nested drill object
  String get drillId => drill?.id ?? id;

  factory SessionDrill.fromJson(Map<String, dynamic> json) =>
      _$SessionDrillFromJson(json);
  Map<String, dynamic> toJson() => _$SessionDrillToJson(this);

  SessionDrill copyWith({
    String? id,
    int? orderIndex,
    bool? isCompleted,
    int? starsEarned,
    DateTime? completedAt,
    Drill? drill,
  }) {
    return SessionDrill(
      id: id ?? this.id,
      orderIndex: orderIndex ?? this.orderIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      starsEarned: starsEarned ?? this.starsEarned,
      completedAt: completedAt ?? this.completedAt,
      drill: drill ?? this.drill,
    );
  }
}

/// Practice session model
/// Maps to backend: id, childId, status, totalStarsEarned, startedAt, completedAt, drills
@JsonSerializable()
class Session {
  final String id;
  final String childId;
  final SessionStatus status;
  @JsonKey(defaultValue: 0)
  final int totalStarsEarned;
  @JsonKey(name: 'startedAt')
  final DateTime createdAt;
  final DateTime? completedAt;
  @JsonKey(defaultValue: [])
  final List<SessionDrill> drills;

  const Session({
    required this.id,
    required this.childId,
    required this.status,
    required this.totalStarsEarned,
    required this.createdAt,
    this.completedAt,
    required this.drills,
  });

  /// Total possible stars (2 stars per drill)
  int get totalPossibleStars => drills.length * 2;

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);
  Map<String, dynamic> toJson() => _$SessionToJson(this);

  Session copyWith({
    String? id,
    String? childId,
    SessionStatus? status,
    int? totalStarsEarned,
    DateTime? createdAt,
    DateTime? completedAt,
    List<SessionDrill>? drills,
  }) {
    return Session(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      status: status ?? this.status,
      totalStarsEarned: totalStarsEarned ?? this.totalStarsEarned,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      drills: drills ?? this.drills,
    );
  }

  /// Get completed drills count
  int get completedDrillsCount =>
      drills.where((d) => d.isCompleted).length;

  /// Get total drills count
  int get totalDrillsCount => drills.length;

  /// Check if all drills are completed
  bool get allDrillsCompleted =>
      completedDrillsCount == totalDrillsCount;

  /// Get current drill (first incomplete)
  SessionDrill? get currentDrill {
    try {
      return drills.firstWhere((d) => !d.isCompleted);
    } catch (_) {
      return null;
    }
  }
}

/// Request to generate a new session
@JsonSerializable()
class GenerateSessionRequest {
  final String childId;
  final String durationMinutes;

  const GenerateSessionRequest({
    required this.childId,
    this.durationMinutes = '15',
  });

  factory GenerateSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateSessionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$GenerateSessionRequestToJson(this);
}

/// Response containing list of sessions with pagination
@JsonSerializable()
class SessionsResponse {
  final List<Session> sessions;
  final int total;
  final int limit;
  final int offset;

  const SessionsResponse({
    required this.sessions,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory SessionsResponse.fromJson(Map<String, dynamic> json) =>
      _$SessionsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SessionsResponseToJson(this);
}
