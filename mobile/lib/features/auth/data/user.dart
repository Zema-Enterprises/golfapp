import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// User model from backend
/// Backend returns: id, email, isActive, isVerified, role: {id, name}, parent: {id, hasPin}
@JsonSerializable()
class User {
  final String id;
  final String email;
  @JsonKey(defaultValue: true)
  final bool isActive;
  @JsonKey(defaultValue: false)
  final bool isVerified;

  const User({
    required this.id,
    required this.email,
    this.isActive = true,
    this.isVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? email,
    bool? isActive,
    bool? isVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

/// Auth tokens response
@JsonSerializable()
class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
  Map<String, dynamic> toJson() => _$AuthTokensToJson(this);
}

/// Login response containing user and tokens
/// Backend returns: { user: {...}, tokens: { accessToken, refreshToken, expiresIn } }
class AuthResponse {
  final User user;
  final String accessToken;
  final String refreshToken;

  const AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  /// Custom fromJson to handle nested tokens structure
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final user = User.fromJson(json['user'] as Map<String, dynamic>);
    final tokens = json['tokens'] as Map<String, dynamic>;
    return AuthResponse(
      user: user,
      accessToken: tokens['accessToken'] as String,
      refreshToken: tokens['refreshToken'] as String,
    );
  }
}
