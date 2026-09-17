import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/api_client.dart';
import '../../core/config.dart';
import '../../core/errors.dart';
import '../../core/token_storage.dart';

class AuthUser {
  final String id;
  final String userName;
  final String email;
  final String role;
  final bool isEmailVerified;

  // Avatar / cover
  final String? avatarUrl;
  final String? coverUrl;
  final bool hasCustomProfilePic;
  final bool hasCustomCoverPhoto;

  // Personal
  final String? firstName;
  final String? lastName;
  final String? contactEmail;
  final String? phoneNumber;
  final String? whatsappNumber;
  final String? nationalId;
  final DateTime? dateOfBirth;
  final String? gender; // 'male' | 'female' | 'other'
  final String? countryOfResidence;
  final String? address;
  final String? bio;

  AuthUser({
    required this.id,
    required this.userName,
    required this.email,
    required this.role,
    required this.isEmailVerified,
    this.avatarUrl,
    this.coverUrl,
    this.hasCustomProfilePic = false,
    this.hasCustomCoverPhoto = false,
    this.firstName,
    this.lastName,
    this.contactEmail,
    this.phoneNumber,
    this.whatsappNumber,
    this.nationalId,
    this.dateOfBirth,
    this.gender,
    this.countryOfResidence,
    this.address,
    this.bio,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final profile = json['Profile'] as Map?;
    final src = profile ?? json;

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return AuthUser(
      id: json['id'] as String,
      userName: json['userName'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,

      avatarUrl: src['profilePic'] as String?,
      coverUrl: src['coverPhoto'] as String?,
      hasCustomProfilePic: src['hasCustomProfilePic'] as bool? ?? false,
      hasCustomCoverPhoto: src['hasCustomCoverPhoto'] as bool? ?? false,

      firstName: src['firstName'] as String?,
      lastName: src['lastName'] as String?,
      contactEmail: src['contactEmail'] as String?,
      phoneNumber: src['phoneNumber'] as String?,
      whatsappNumber: src['whatsappNumber'] as String?,
      nationalId: src['nationalId'] as String?,
      dateOfBirth: parseDate(src['dateOfBirth']),
      gender: src['gender'] as String?,
      countryOfResidence: src['countryOfResidence'] as String?,
      address: src['address'] as String?,
      bio: src['bio'] as String?,
    );
  }

  /// Best-effort display name with sensible fallbacks.
  String get displayName {
    final parts = [firstName, lastName]
        .where((s) => s != null && s.trim().isNotEmpty)
        .map((s) => s!.trim())
        .toList();
    if (parts.isNotEmpty) return parts.join(' ');
    return userName;
  }

  // ── Profile completion ──────────────────────────────────

  /// Fields the user can set from Edit Profile that count toward
  /// "profile complete". Adjust this list to match your policy.
  List<bool> get _completionChecks => [
        (firstName ?? '').trim().isNotEmpty,
        (lastName ?? '').trim().isNotEmpty,
        hasCustomProfilePic,
        (contactEmail ?? '').trim().isNotEmpty,
        (phoneNumber ?? '').trim().isNotEmpty,
        (countryOfResidence ?? '').trim().isNotEmpty,
        (bio ?? '').trim().isNotEmpty,
        dateOfBirth != null,
        gender != null,
      ];

  /// 0.0 → empty, 1.0 → complete.
  double get profileCompletion {
    final checks = _completionChecks;
    if (checks.isEmpty) return 1.0;
    return checks.where((c) => c).length / checks.length;
  }

  /// True when at least one required field is missing.
  bool get needsProfileCompletion => missingProfileFields > 0;

  /// How many required fields are still empty.
  int get missingProfileFields =>
      _completionChecks.where((c) => !c).length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'email': email,
        'role': role,
        'isEmailVerified': isEmailVerified,
      };
}

class SocialLoginResult {
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

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
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
    final res = await _api.post(
      '/api/auth/resend-otp',
      body: {'email': email},
    );
    if (res['success'] != true) {
      throw AppError((res['message'] ?? 'Could not resend').toString());
    }
  }

  Future<void> forgotPassword({required String email}) async {
    final res = await _api.post(
      '/api/auth/forgot-password',
      body: {'email': email},
    );
    if (res['success'] != true) {
      throw AppError(
        (res['message'] ?? 'Could not send reset code').toString(),
      );
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

  Future<SocialLoginResult> googleLogin() async {
    String? idToken;

    if (kIsWeb) {
      final auth = fb.FirebaseAuth.instance;
      final provider = fb.GoogleAuthProvider();
      provider.addScope('email');
      provider.addScope('profile');

      final credential = await auth.signInWithPopup(provider);
      idToken = await credential.user?.getIdToken();
    } else {
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
      await _storage.save(
        access: token,
        userId: user.id,
        userRole: user.role,
      );
    }

    return SocialLoginResult(
      needsCompletion: needsCompletion,
      token: token,
      user: user,
    );
  }

  Future<AuthUser> socialComplete({
    required String pendingToken,
    required String userName,
    required String role,
  }) async {
    final res = await _api.dio.patch(
      '/api/auth/social-complete',
      data: {'userName': userName, 'role': role},
      options: _bearerOverride(pendingToken),
    );

    final data = res.data is Map
        ? Map<String, dynamic>.from(res.data as Map)
        : <String, dynamic>{};

    if (data['success'] != true) {
      throw AppError(
        (data['message'] ?? 'Could not complete signup').toString(),
      );
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
    return AuthUser.fromJson(
      Map<String, dynamic>.from(res['user'] as Map),
    );
  }

  Future<void> logout() async {
    await _storage.clear();
  }

  Future<String?> getStoredToken() => _storage.access;

  // ─── Profile ─────────────────────────────────────────────

  Future<AuthUser> updateProfile({
    String? firstName,
    String? lastName,
    String? contactEmail,
    String? phoneNumber,
    String? whatsappNumber,
    String? nationalId,
    DateTime? dateOfBirth,
    String? gender,
    String? countryOfResidence,
    String? address,
    String? bio,
  }) async {
    final body = <String, dynamic>{};
    if (firstName != null) body['firstName'] = firstName;
    if (lastName != null) body['lastName'] = lastName;
    if (contactEmail != null) body['contactEmail'] = contactEmail;
    if (phoneNumber != null) body['phoneNumber'] = phoneNumber;
    if (whatsappNumber != null) body['whatsappNumber'] = whatsappNumber;
    if (nationalId != null) body['nationalId'] = nationalId;
    if (dateOfBirth != null) {
      body['dateOfBirth'] = dateOfBirth.toIso8601String().split('T').first;
    }
    if (gender != null) body['gender'] = gender;
    if (countryOfResidence != null) {
      body['countryOfResidence'] = countryOfResidence;
    }
    if (address != null) body['address'] = address;
    if (bio != null) body['bio'] = bio;

    final res = await _api.dio.put(
      '/api/profiles/me',
      data: body,
      options: Options(validateStatus: (s) => s != null && s < 500),
    );

    if (res.statusCode != 200) {
      final msg = res.data is Map
          ? res.data['message']?.toString()
          : 'Could not update profile';
      throw AppError(msg ?? 'Could not update profile');
    }

    return await me();
  }

  /// Upload an avatar. Takes bytes + filename so it works on both
  /// web (blob URLs) and native platforms.
  Future<AuthUser> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
  }) async {
    debugPrint('UPLOAD: start file=$fileName bytes=${bytes.length}');

    final contentType = _guessContentType(fileName);
    debugPrint('UPLOAD: contentType=$contentType');

    // 1. Presign
    debugPrint('UPLOAD: calling presign');
    final presignRes = await _api.post(
      '/api/users/me/media/avatar/presign',
      body: {
        'contentType': contentType,
        'contentLength': bytes.length,
      },
    );
    debugPrint('UPLOAD: presign response=$presignRes');

    if (presignRes['success'] != true) {
      throw AppError(
        presignRes['message']?.toString() ?? 'Could not start upload',
      );
    }
    final uploadUrl = presignRes['uploadUrl'] as String;
    final key = presignRes['key'] as String;

    // 2. PUT to R2 — raw Dio without interceptors
    debugPrint('UPLOAD: PUT to $uploadUrl');
    final rawDio = Dio();
    try {
      final putRes = await rawDio.put(
        uploadUrl,
        data: Stream.fromIterable([bytes]),
        options: Options(
          headers: {
            Headers.contentTypeHeader: contentType,
            Headers.contentLengthHeader: bytes.length,
          },
        ),
      );
      debugPrint('UPLOAD: PUT status=${putRes.statusCode}');
    } catch (e, st) {
      debugPrint('UPLOAD: PUT failed $e');
      debugPrint('UPLOAD: PUT stack $st');
      rethrow;
    }

    // 3. Confirm
    debugPrint('UPLOAD: calling confirm');
    final confirmRes = await _api.post(
      '/api/users/me/media/avatar',
      body: {'key': key},
    );
    debugPrint('UPLOAD: confirm response=$confirmRes');

    if (confirmRes['success'] != true) {
      throw AppError(
        confirmRes['message']?.toString() ?? 'Could not save avatar',
      );
    }

    // 4. Refetch
    debugPrint('UPLOAD: refetching me');
    return await me();
  }

  String _guessContentType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}

Options _bearerOverride(String token) => Options(
      headers: {'Authorization': 'Bearer $token'},
    );