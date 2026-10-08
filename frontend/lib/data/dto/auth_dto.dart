import 'base_dto.dart';

class LoginRequestDto extends BaseDto {
  const LoginRequestDto({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class RegisterRequestDto extends BaseDto {
  const RegisterRequestDto({
    required this.email,
    required this.password,
    required this.fullName,
  });

  final String email;
  final String password;
  final String fullName;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'full_name': fullName,
      };
}

class UserResponseDto extends BaseDto {
  const UserResponseDto({
    required this.id,
    required this.email,
    required this.role,
    this.studentId,
    this.fullName,
  });

  final int id;
  final String email;
  final String role;
  final int? studentId;
  final String? fullName;

  factory UserResponseDto.fromJson(Map<String, dynamic> json) {
    return UserResponseDto(
      id: json['id'] as int,
      email: json['email'] as String,
      role: json['role'] as String,
      studentId: json['student_id'] as int?,
      fullName: json['full_name'] as String?,
    );
  }
}

class TokenResponseDto extends BaseDto {
  const TokenResponseDto({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
    this.refreshToken,
  });

  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String? refreshToken;
  final UserResponseDto user;

  factory TokenResponseDto.fromJson(Map<String, dynamic> json) {
    return TokenResponseDto(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: json['expires_in'] as int,
      refreshToken: json['refresh_token'] as String?,
      user: UserResponseDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class RefreshRequestDto extends BaseDto {
  const RefreshRequestDto({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() => {'refresh_token': refreshToken};
}
