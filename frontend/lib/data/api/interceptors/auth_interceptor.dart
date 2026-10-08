import 'package:dio/dio.dart';

import '../../../core/services/session_manager.dart';

/// Añade el JWT Bearer a cada solicitud saliente.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._sessionManager);

  final SessionManager _sessionManager;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _sessionManager.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
