import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/config/app_config.dart';
import '../../core/services/api_error_handler.dart';
import '../../core/services/api_exception.dart';
import 'base_response.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import '../../core/services/session_manager.dart';

/// Cliente HTTP centralizado. Sin llamadas de negocio.
class ApiClient {
  ApiClient({
    required SessionManager sessionManager,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio
      ..options = BaseOptions(
        baseUrl: AppConfig.apiRoot,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      )
      ..interceptors.addAll([
        AuthInterceptor(sessionManager),
        ErrorInterceptor(sessionManager, _dio),
        if (kDebugMode)
          LogInterceptor(
            requestHeader: true,
            requestBody: true,
            responseHeader: false,
            responseBody: true,
          ),
      ]);
  }

  final Dio _dio;

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Ejecuta una petición y devuelve [BaseResponse] o lanza [ApiException].
  Future<BaseResponse<T>> request<T>({
    required Future<Response<dynamic>> Function() call,
    required T Function(dynamic json) parser,
  }) async {
    try {
      final response = await call();
      return BaseResponse(
        data: parser(response.data),
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  /// Ejecuta una petición cuyo body es una lista JSON.
  Future<BaseResponse<List<T>>> requestList<T>({
    required Future<Response<dynamic>> Function() call,
    required T Function(Map<String, dynamic> json) itemParser,
  }) async {
    try {
      final response = await call();
      final raw = response.data as List<dynamic>? ?? [];
      final items = raw
          .map((e) => itemParser(e as Map<String, dynamic>))
          .toList();
      return BaseResponse(
        data: items,
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  ApiException _toApiException(DioException error) {
    final nested = readApiException(error.error);
    if (nested != null) return nested;
    return ApiErrorHandler.fromDioException(error);
  }
}
