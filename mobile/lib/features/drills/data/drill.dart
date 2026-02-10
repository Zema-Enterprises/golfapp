import 'package:json_annotation/json_annotation.dart';
import '../../children/data/child.dart';

part 'drill.g.dart';

/// Drill model from backend
/// Supports both full drill responses (from /drills) and partial drill data
/// embedded in session responses (which only include id, title, skillCategory, durationMinutes)
@JsonSerializable()
class Drill {
  final String id;
  @JsonKey(name: 'title', defaultValue: '')
  final String name;
  @JsonKey(defaultValue: '')
  final String description;
  @JsonKey(defaultValue: '')
  final String instructions;
  @JsonKey(defaultValue: null)
  final AgeBand? ageBand;
  @JsonKey(defaultValue: '')
  final String skillCategory;
  @JsonKey(defaultValue: 5)
  final int durationMinutes;
  final String? equipmentNeeded;
  final String? videoUrl;
  final String? imageUrl;
  @JsonKey(defaultValue: false)
  final bool isPremium;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Drill({
    required this.id,
    required this.name,
    required this.description,
    required this.instructions,
    this.ageBand,
    required this.skillCategory,
    required this.durationMinutes,
    this.equipmentNeeded,
    this.videoUrl,
    this.imageUrl,
    required this.isPremium,
    this.createdAt,
    this.updatedAt,
  });

  factory Drill.fromJson(Map<String, dynamic> json) => _$DrillFromJson(json);
  Map<String, dynamic> toJson() => _$DrillToJson(this);

  Drill copyWith({
    String? id,
    String? name,
    String? description,
    String? instructions,
    AgeBand? ageBand,
    String? skillCategory,
    int? durationMinutes,
    String? equipmentNeeded,
    String? videoUrl,
    String? imageUrl,
    bool? isPremium,
  }) {
    return Drill(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      ageBand: ageBand ?? this.ageBand,
      skillCategory: skillCategory ?? this.skillCategory,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      equipmentNeeded: equipmentNeeded ?? this.equipmentNeeded,
      videoUrl: videoUrl ?? this.videoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Response containing list of drills with pagination
@JsonSerializable()
class DrillsResponse {
  final List<Drill> drills;
  final int total;
  final int limit;
  final int offset;

  const DrillsResponse({
    required this.drills,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory DrillsResponse.fromJson(Map<String, dynamic> json) =>
      _$DrillsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DrillsResponseToJson(this);
}

/// Skill category with drill count
@JsonSerializable()
class SkillCategory {
  final String name;
  final int count;

  const SkillCategory({
    required this.name,
    required this.count,
  });

  factory SkillCategory.fromJson(Map<String, dynamic> json) =>
      _$SkillCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$SkillCategoryToJson(this);
}
