class MapboxConfig {
  static const String token = String.fromEnvironment('MAPBOX_TOKEN');

  static bool get isConfigured => token.isNotEmpty;
}
