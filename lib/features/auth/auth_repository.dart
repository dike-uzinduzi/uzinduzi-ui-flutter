import '../../core/api_client.dart';
import '../../core/errors.dart';
import '../../core/token_storage.dart';

class AuthUser {
  final String id;
  final String userName;
  final String email;
  final String role;
  final bool isEmailVerified;

  AuthUser({
    required this.id,
    required this.userName,
    required this.email,
    required this.role,
    required this.isEmailVerified,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        userName: json['userName'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      );
}

class AuthRepository {
  final ApiClient _api;
  final TokenStorage _storage;

  AuthRepository(this._api, this._storage);

  Future<AuthUser> login({required String email, required String password}) async {
    final res = await _api.post('/api/auth/login', body: {
      'email': email,
      'password': password,
    });

    if (res['success'] != true) {
      throw AppError((res['message'] ?? 'Login failed').toString());
    }

    final token = res['token'] as String?;
    final userJson = res['user'] as Map?;
    if (token == null || userJson == null) {
      throw AppError('Malformed login response');
    }

    final user = AuthUser.fromJson(Map<String, dynamic>.from(userJson));

    await _storage.save(access: token, userId: user.id, userRole: user.role);
    return user;
  }

  Future<AuthUser> me() async {
    final res = await _api.get('/api/auth/me');
    if (res['success'] != true || res['user'] == null) {
      throw AppError('Not authenticated');
    }
    return AuthUser.fromJson(Map<String, dynamic>.from(res['user'] as Map));
  }

  Future<void> logout() async {
    await _storage.clear();
  }

  Future<String?> getStoredToken() => _storage.access;
}
