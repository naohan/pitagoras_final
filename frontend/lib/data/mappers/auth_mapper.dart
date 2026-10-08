import '../dto/auth_dto.dart';
import '../enums.dart';
import '../models/auth_model.dart';

class AuthMapper {
  const AuthMapper._();

  static AuthUser toUser(UserResponseDto dto) {
    return AuthUser(
      id: dto.id,
      email: dto.email,
      role: UserRole.fromString(dto.role),
      studentId: dto.studentId,
      fullName: dto.fullName,
    );
  }

  static AuthSession toSession(TokenResponseDto dto) {
    return AuthSession(
      accessToken: dto.accessToken,
      tokenType: dto.tokenType,
      expiresIn: dto.expiresIn,
      refreshToken: dto.refreshToken,
      user: toUser(dto.user),
    );
  }
}
