import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../../core/config.dart';
import '../../core/errors.dart';
import '../../core/token_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart' as fb;

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

/// Result of a social login attempt.
class SocialLoginResult {
  /// True when the user is new and must pick a username + role.
  final bool needsCompletion;
  final String token;
  final AuthUser user;

  SocialLoginResult({
    required this.needsCompletion,
    required this.token,
    required this.user,
  });
}

class AuthRepository {
  final ApiClient _api;
  final TokenStorage _storage;

  AuthRepository(this._api, this._storage);

  // ─── Email / password ────────────────────────────────────

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

  /// Registers a new user. Returns the email the OTP was sent to.
  /// Does NOT persist a token — the user must verify first.
  Future<String> register({
    required String userName,
    required String email,
    required String password,
    required String role,
  }) async {
    final res = await _api.post('/api/auth/register', body: {
      'userName': userName,
      'email': email,
      'password': password,
      'role': role,
    });

    if (res['success'] != true) {
      throw AppError((res['message'] ?? 'Registration failed').toString());
    }

    return email;
  }

  /// Verifies the email with the OTP. Returns the logged-in user on success.
  Future<AuthUser> verifyEmail({
    required String email,
    required String otp,
  }) async {
    final res = await _api.post('/api/auth/verify-email', body: {
      'email': email,
      'otp': otp,
    });

    if (res['success'] != true) {
      throw AppError((res['message'] ?? 'Verification failed').toString());
    }

    final token = res['token'] as String?;
    final userJson = res['user'] as Map?;
    if (token == null || userJson == null) {
      throw AppError('Malformed verify response');
    }

    final user = AuthUser.fromJson(Map<String, dynamic>.from(userJson));
    await _storage.save(access: token, userId: user.id, userRole: user.role);
    return user;
  }

  Future<void> resendOtp({required String email}) async {
    final res = await _api.post('/api/auth/resend-otp', body: {'email': email});
    if (res['success'] != true) {
      throw AppError((res['message'] ?? 'Could not resend').toString());
    }
  }

  Future<void> forgotPassword({required String email}) async {
    final res = await _api.post('/api/auth/forgot-password', body: {'email': email});
    // Server always returns 200 for privacy; only surface real errors.
    if (res['success'] != true) {
      throw AppError((res['message'] ?? 'Could not send reset code').toString());
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final res = await _api.post('/api/auth/reset-password', body: {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
    });
    if (res['success'] != true) {
      throw AppError((res['message'] ?? 'Reset failed').toString());
    }
  }

  // ─── Google ──────────────────────────────────────────────

  /// Signs in with Google. Returns a result that either has
  /// a session token (existing user) or a signup-pending token
  /// (new user, must complete signup).

Future<SocialLoginResult> googleLogin() async {
  String? idToken;

  if (kIsWeb) {
    // Web: use Firebase Auth popup
    final auth = fb.FirebaseAuth.instance;
    final provider = fb.GoogleAuthProvider();
    provider.addScope('email');
    provider.addScope('profile');

    final credential = await auth.signInWithPopup(provider);
    idToken = (await credential.user?.getIdToken());
  } else {
    // Mobile: use google_sign_in (v7)
    final google = GoogleSignIn.instance;
    await google.initialize(
      clientId: AppConfig.googleWebClientId,
      serverClientId: AppConfig.googleWebClientId,
    );

    if (!google.supportsAuthenticate()) {
      throw AppError('Google sign-in not supported on this platform');
    }

    final account = await google.authenticate();
    idToken = account.authentication.idToken;
  }

  if (idToken == null) {
    throw AppError('Google did not return an ID token');
  }

  // Send to your backend — same as before
  final res = await _api.post('/api/auth/social-login', body: {
    'idToken': idToken,
  });

  if (res['success'] != true) {
    throw AppError((res['message'] ?? 'Google login failed').toString());
  }

  final token = res['token'] as String?;
  final userJson = res['user'] as Map?;
  final needsCompletion = res['needsCompletion'] == true;

  if (token == null || userJson == null) {
    throw AppError('Malformed social login response');
  }

  final user = AuthUser.fromJson(Map<String, dynamic>.from(userJson));

  if (!needsCompletion) {
    await _storage.save(access: token, userId: user.id, userRole: user.role);
  }

  return SocialLoginResult(
    needsCompletion: needsCompletion,
    token: token,
    user: user,
  );
}
  /// Completes a Google signup by setting a username and role.
  /// Requires the signup-pending token to be passed as `pendingToken`.
  Future<AuthUser> socialComplete({
    required String pendingToken,
    required String userName,
    required String role,
  }) async {
    // The ApiClient attaches the stored token — but for social-complete
    // the caller is using a pending token that we don't store. So pass
    // it explicitly via the Authorization header by overriding dio options.
    final res = await _api.dio.patch(
      '/api/auth/social-complete',
      data: {'userName': userName, 'role': role},
      options: _bearerOverride(pendingToken),
    );

    final data = res.data is Map
        ? Map<String, dynamic>.from(res.data as Map)
        : <String, dynamic>{};

    if (data['success'] != true) {
      throw AppError((data['message'] ?? 'Could not complete signup').toString());
    }

    final token = data['token'] as String?;
    final userJson = data['user'] as Map?;
    if (token == null || userJson == null) {
      throw AppError('Malformed complete response');
    }

    final user = AuthUser.fromJson(Map<String, dynamic>.from(userJson));
    await _storage.save(access: token, userId: user.id, userRole: user.role);
    return user;
  }

  // ─── Session ─────────────────────────────────────────────

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

// ─── Helper for passing a one-off Authorization header ──────
// Uses Dio's Options so the request-level header wins over the
// interceptor-set header.
Options _bearerOverride(String token) => Options(
      headers: {'Authorization': 'Bearer $token'},
    );