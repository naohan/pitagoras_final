import '../dto/auth_dto.dart';
import 'api_client.dart';
import 'api_paths.dart';
import 'base_response.dart';

/// Llamadas HTTP de autenticación (CU-01).
class AuthApi {
  const AuthApi(this._client);

  final ApiClient _client;

  Future<BaseResponse<TokenResponseDto>> register(RegisterRequestDto request) {
    return _client.request(
      call: () => _client.post(ApiPaths.authRegister, data: request.toJson()),
      parser: (json) => TokenResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BaseResponse<TokenResponseDto>> login(LoginRequestDto request) {
    return _client.request(
      call: () => _client.post(ApiPaths.authLogin, data: request.toJson()),
      parser: (json) => TokenResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BaseResponse<TokenResponseDto>> refresh(RefreshRequestDto request) {
    return _client.request(
      call: () => _client.post(ApiPaths.authRefresh, data: request.toJson()),
      parser: (json) => TokenResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BaseResponse<UserResponseDto>> getMe() {
    return _client.request(
      call: () => _client.get(ApiPaths.authMe),
      parser: (json) => UserResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
