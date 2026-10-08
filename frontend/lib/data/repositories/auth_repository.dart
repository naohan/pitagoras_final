import '../api/auth_api.dart';
import '../dto/auth_dto.dart';
import '../mappers/auth_mapper.dart';
import '../models/auth_model.dart';
import 'base_repository.dart';

class AuthRepository extends BaseRepository {
  const AuthRepository(this._api);

  final AuthApi _api;

  Future<AuthSession> register(RegisterRequestDto request) async {
    final response = await _api.register(request);
    return AuthMapper.toSession(response.data);
  }

  Future<AuthSession> login(LoginRequestDto request) async {
    final response = await _api.login(request);
    return AuthMapper.toSession(response.data);
  }

  Future<AuthUser> getMe() async {
    final response = await _api.getMe();
    return AuthMapper.toUser(response.data);
  }
}
