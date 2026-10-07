import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Mapea errores de [Dio] y respuestas HTTP a [ApiException].
class ApiErrorHandler {
  ApiErrorHandler._();

  static ApiException fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'La solicitud tardó demasiado. Intenta de nuevo.',
          statusCode: error.response?.statusCode,
          code: 'timeout',
          originalError: error,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Sin conexión con el servidor.',
          code: 'connection_error',
          originalError: error,
        );
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Solicitud cancelada.',
          code: 'cancelled',
          originalError: error,
        );
      case DioExceptionType.badResponse:
        return _fromResponse(error.response, error);
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return ApiException(
          message: 'Ocurrió un error inesperado.',
          statusCode: error.response?.statusCode,
          code: 'unknown',
          originalError: error,
        );
    }
  }

  static ApiException fromResponse(Response<dynamic>? response) {
    return _fromResponse(response, null);
  }

  static ApiException _fromResponse(
    Response<dynamic>? response,
    DioException? error,
  ) {
    final statusCode = response?.statusCode;
    final data = response?.data;
    String message = 'Error en la solicitud.';
    String? code;

    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is Map<String, dynamic>) {
        message = detail['message']?.toString() ?? message;
        code = detail['code']?.toString();
      } else if (detail is String) {
        message = detail;
      } else if (detail is List && detail.isNotEmpty) {
        // Errores de validación FastAPI/Pydantic (422).
        final first = detail.first;
        if (first is Map) {
          final loc = first['loc'];
          final field = loc is List && loc.isNotEmpty
              ? loc.last.toString()
              : null;
          final rawMsg = first['msg']?.toString() ?? '';
          message = _validationMessage(field, rawMsg);
          code = 'validation_error';
        }
      }
    }

    if (statusCode == 401) {
      message = 'Sesión expirada o no autorizada.';
      code ??= 'not_authenticated';
    }

    if (statusCode == 422 && code == null) {
      message = 'Revisa los datos del formulario.';
      code = 'validation_error';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      code: code,
      originalError: error ?? response,
    );
  }

  static String _validationMessage(String? field, String rawMsg) {
    final lower = rawMsg.toLowerCase();
    if (field == 'email' || lower.contains('email')) {
      if (lower.contains('valid email') || lower.contains('not a valid email')) {
        return 'El correo no es válido. Usa un email real (ej. tu@gmail.com).';
      }
      return 'Revisa el correo electrónico.';
    }
    if (field == 'password') {
      if (lower.contains('at least') || lower.contains('min')) {
        return 'La contraseña debe tener al menos 8 caracteres.';
      }
      return 'Revisa la contraseña.';
    }
    if (field == 'full_name') {
      return 'El nombre debe tener al menos 2 caracteres.';
    }
    return rawMsg.isNotEmpty ? rawMsg : 'Revisa los datos del formulario.';
  }
}
