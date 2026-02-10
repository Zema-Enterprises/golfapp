import 'package:json_annotation/json_annotation.dart';

part 'child.g.dart';

/// Age bands for children
enum AgeBand {
  @JsonValue('AGE_4_6')
  age4to6,
  @JsonValue('AGE_6_8')
  age6to8,
  @JsonValue('AGE_8_10')
  age8to10,
}

/// Skill levels
enum SkillLevel {
  @JsonValue('BEGINNER')
  beginner,
  @JsonValue('INTERMEDIATE')
  intermediate,
  @JsonValue('ADVANCED')
  advanced,
}

/// Child model from backend
@JsonSerializable()
class Child {
  final String id;
  @JsonKey(defaultValue: '')
  final String parentId;
  final String name;
  final AgeBand ageBand;
  final SkillLevel skillLevel;
  @JsonKey(defaultValue: 0)
  final int totalStars;
  @JsonKey(defaultValue: 0)
  final int availableStars;
  @JsonKey(defaultValue: {})
  final Map<String, dynamic> avatarState;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Child({
    required this.id,
    this.parentId = '',
    required this.name,
    required this.ageBand,
    required this.skillLevel,
    this.totalStars = 0,
    this.availableStars = 0,
    this.avatarState = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory Child.fromJson(Map<String, dynamic> json) => _$ChildFromJson(json);
  Map<String, dynamic> toJson() => _$ChildToJson(this);

  Child copyWith({
    String? id,
    String? parentId,
    String? name,
    AgeBand? ageBand,
    SkillLevel? skillLevel,
    int? totalStars,
    int? availableStars,
    Map<String, dynamic>? avatarState,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Child(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      ageBand: ageBand ?? this.ageBand,
      skillLevel: skillLevel ?? this.skillLevel,
      totalStars: totalStars ?? this.totalStars,
      availableStars: availableStars ?? this.availableStars,
      avatarState: avatarState ?? this.avatarState,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Display name for age band
  String get ageBandDisplayName {
    switch (ageBand) {
      case AgeBand.age4to6:
        return '4-6 years';
      case AgeBand.age6to8:
        return '6-8 years';
      case AgeBand.age8to10:
        return '8-10 years';
    }
  }

  /// Display name for skill level
  String get skillLevelDisplayName {
    switch (skillLevel) {
      case SkillLevel.beginner:
        return 'New to Golf';
      case SkillLevel.intermediate:
        return 'Some Experience';
      case SkillLevel.advanced:
        return 'Experienced';
    }
  }
}

/// Request to create a child
@JsonSerializable()
class CreateChildRequest {
  final String name;
  final AgeBand ageBand;
  final SkillLevel? skillLevel;
  final Map<String, dynamic>? avatarState;

  const CreateChildRequest({
    required this.name,
    required this.ageBand,
    this.skillLevel,
    this.avatarState,
  });

  factory CreateChildRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateChildRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateChildRequestToJson(this);
}

/// Request to update a child
@JsonSerializable()
class UpdateChildRequest {
  final String? name;
  final AgeBand? ageBand;
  final SkillLevel? skillLevel;

  const UpdateChildRequest({
    this.name,
    this.ageBand,
    this.skillLevel,
  });

  factory UpdateChildRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateChildRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateChildRequestToJson(this);
}
