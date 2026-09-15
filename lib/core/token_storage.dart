import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _accessKey = 'access_token';
  static const _userIdKey = 'user_id';
  static const _userRoleKey = 'user_role';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<String?> get access async => _storage.read(key: _accessKey);
  Future<String?> get userId async => _storage.read(key: _userIdKey);
  Future<String?> get userRole async => _storage.read(key: _userRoleKey);

  Future<void> save({
    required String access,
    required String userId,
    required String userRole,
  }) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _userRoleKey, value: userRole);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userRoleKey);
  }
}
