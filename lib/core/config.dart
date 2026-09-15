import 'api_base_stub.dart'
    if (dart.library.io) 'api_base_io.dart'
    if (dart.library.html) 'api_base_web.dart';

class AppConfig {
  static const String _override = String.fromEnvironment('API_BASE');

  static String get apiBase {
    if (_override.isNotEmpty) return _override;
    return platformDefaultApiBase();
  }

  static const String cdnBase = String.fromEnvironment(
    'CDN_BASE',
    defaultValue: 'https://pub-969b935d3cad4df4a4e9c86a6c18588c.r2.dev',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  static const String defaultAvatar = '$cdnBase/placeholders/avatar-default.png';
  static const String defaultCover  = '$cdnBase/placeholders/cover-default.jpg';
  static const String defaultAlbumCover = '$cdnBase/placeholders/album-cover-default.jpg';
}