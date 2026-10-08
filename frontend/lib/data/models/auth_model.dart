import '../enums.dart';
import 'base_model.dart';

class AuthUser extends BaseModel {
  const AuthUser({
    required this.id,
    required this.email,
    required this.role,
    this.studentId,
    this.fullName,
  });

  final int id;
  final String email;
  final UserRole role;
  final int? studentId;
  final String? fullName;
}

class AuthSession extends BaseModel {
  const AuthSession({
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
  final AuthUser user;
}
