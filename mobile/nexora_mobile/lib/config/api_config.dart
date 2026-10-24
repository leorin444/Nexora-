class ApiConfig {
  /// Base API URL. Can be overridden at build time via:
  /// --dart-define=API_URL=https://your-domain/api
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://leorinofficial.dpdns.org/api',
  );
}
