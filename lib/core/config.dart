import 'api_base_stub.dart'
    if (dart.library.io) 'api_base_io.dart'
    if (dart.library.html) 'api_base_web.dart';

class AppConfig {
  static const String _apiOverride = String.fromEnvironment('API_BASE');

  static String get apiBase {
    if (_apiOverride.isNotEmpty) return _apiOverride;
    return platformDefaultApiBase();
  }

  static const String cdnBase = String.fromEnvironment(
    'CDN_BASE',
    defaultValue: 'https://pub-969b935d3cad4df4a4e9c86a6c18588c.r2.dev',
  );

  /// Google OAuth Web client ID.
  /// Same value on every platform — the mobile SDKs use it as the
  /// `serverClientId` so the ID token has the right audience for our backend.
  static const String googleWebClientId =
      '815412778395-4b52220u7uh66lnhlr3ev55sh6t54g4f.apps.googleusercontent.com';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  static const String defaultAvatar     = '$cdnBase/placeholders/avatar-default.png';
  static const String defaultCover      = '$cdnBase/placeholders/cover-default.jpg';
  static const String defaultAlbumCover = '$cdnBase/placeholders/album-cover-default.jpg';
}