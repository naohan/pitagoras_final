/// Configuración global de la aplicación.
///
/// Backend local (Windows/Web): `http://127.0.0.1:8000`
/// (se evita `localhost` porque en Windows a menudo resuelve a IPv6 y falla).
/// Emulador Android:           `http://10.0.2.2:8000`
/// Modo sin servidor:          `--dart-define=OFFLINE_MODE=true`
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  /// Cuando es `true`, auth y examen usan datos mock locales (sin HTTP).
  ///
  /// Por defecto `false`: la app habla con FastAPI en [apiBaseUrl].
  /// Solo activa offline si no tienes backend:
  ///   flutter run --dart-define=OFFLINE_MODE=true
  static const bool offlineMode = bool.fromEnvironment(
    'OFFLINE_MODE',
    defaultValue: false,
  );

  static const String apiPrefix = '/api/v1';

  static String get apiRoot => '$apiBaseUrl$apiPrefix';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 30);

  /// Plantilla de examen demo (ver `python -m scripts.seed_demo` en backend).
  static const int examTemplateId = int.fromEnvironment(
    'EXAM_TEMPLATE_ID',
    defaultValue: 1,
  );
}
