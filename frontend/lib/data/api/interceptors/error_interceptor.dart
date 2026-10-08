import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/services/api_error_handler.dart';
import '../../../core/services/api_exception.dart';
import '../../../core/services/session_manager.dart';
import '../api_paths.dart';

/// Convierte errores Dio en [ApiException].
/// Ante 401 intenta refresh una vez; si falla, limpia sesión.
class ErrorInterceptor extends Interceptor {
  ErrorInterceptor(this._sessionManager, this._dio);

  final SessionManager _sessionManager;
  final Dio _dio;
  bool _refreshing = false;

  static const _retriedKey = 'auth_retried';

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;
    final alreadyRetried = err.requestOptions.extra[_retriedKey] == true;
    final isAuthPublic = path.contains(ApiPaths.authLogin) ||
        path.contains(ApiPaths.authRegister) ||
        path.contains(ApiPaths.authRefresh) ||
        path.contains(ApiPaths.authLogout);

    if (statusCode == 401 && !isAuthPublic && !alreadyRetried && !_refreshing) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        try {
          final request = err.requestOptions;
          request.extra[_retriedKey] = true;
          final token = await _sessionManager.getAccessToken();
          if (token != null && token.isNotEmpty) {
            request.headers['Authorization'] = 'Bearer $token';
          }
          final response = await _dio.fetch<dynamic>(request);
          handler.resolve(response);
          return;
        } on DioException catch (retryError) {
          final apiException = ApiErrorHandler.fromDioException(retryError);
          if (apiException.isUnauthorized) {
            await _sessionManager.clearSession();
          }
          handler.reject(_wrap(retryError, apiException));
          return;
        }
      } else {
        await _sessionManager.clearSession();
      }
    } else if (statusCode == 401 && !isAuthPublic) {
      await _sessionManager.clearSession();
    }

    final apiException = ApiErrorHandler.fromDioException(err);
    handler.reject(_wrap(err, apiException));
  }

  Future<bool> _tryRefresh() async {
    final refreshToken = await _sessionManager.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }
    _refreshing = true;
    try {
      final bare = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiRoot,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      final response = await bare.post<Map<String, dynamic>>(
        ApiPaths.authRefresh,
        data: {'refresh_token': refreshToken},
      );
      final data = response.data;
      if (data == null) return false;
      final access = data['access_token'] as String?;
      final newRefresh = data['refresh_token'] as String?;
      if (access == null || access.isEmpty) return false;
      await _sessionManager.saveAccessToken(access);
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await _sessionManager.saveRefreshToken(newRefresh);
      }
      return true;
    } catch (_) {
      return false;
    } finally {
      _refreshing = false;
    }
  }

  DioException _wrap(DioException err, ApiException apiException) {
    return DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: apiException,
      message: apiException.message,
    );
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final statusCode = response.statusCode ?? 0;
    if (statusCode >= 400) {
      final apiException = ApiErrorHandler.fromResponse(response);
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: apiException,
          message: apiException.message,
        ),
      );
      return;
    }
    handler.next(response);
  }
}

/// Expone utilidad para extraer [ApiException] desde cualquier error.
ApiException? readApiException(Object? error) {
  if (error is ApiException) return error;
  if (error is DioException && error.error is ApiException) {
    return error.error as ApiException;
  }
  return null;
}
