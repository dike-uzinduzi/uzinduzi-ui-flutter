import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/errors.dart';
import 'auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStorageProvider),
  );
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthUser?>(AuthController.new);

class AuthController extends AsyncNotifier<AuthUser?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<AuthUser?> build() async {
    final token = await _repo.getStoredToken();
    if (token == null) return null;

    try {
      return await _repo.me();
    } catch (_) {
      await _repo.logout();
      return null;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.login(email: email, password: password);
      state = AsyncValue.data(user);
    } on AppError catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Registers and returns the email used. No state change.
  Future<String> register({
    required String userName,
    required String email,
    required String password,
    required String role,
  }) {
    return _repo.register(
      userName: userName,
      email: email,
      password: password,
      role: role,
    );
  }

  /// Verifies the OTP. On success, sets the session.
  Future<void> verifyEmail({
    required String email,
    required String otp,
  }) async {
    final user = await _repo.verifyEmail(email: email, otp: otp);
    state = AsyncValue.data(user);
  }

  Future<void> resendOtp({required String email}) =>
      _repo.resendOtp(email: email);

  Future<void> forgotPassword({required String email}) =>
      _repo.forgotPassword(email: email);

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) =>
      _repo.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );

  /// Attempts a Google sign-in. Returns a pending token if the user
  /// must complete signup (choose username + role). Otherwise sets
  /// the session and returns null.
  Future<String?> googleLogin() async {
    final result = await _repo.googleLogin();

    if (result.needsCompletion) {
      return result.token;
    }

    state = AsyncValue.data(result.user);
    return null;
  }

  Future<void> socialComplete({
    required String pendingToken,
    required String userName,
    required String role,
  }) async {
    final user = await _repo.socialComplete(
      pendingToken: pendingToken,
      userName: userName,
      role: role,
    );
    state = AsyncValue.data(user);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncValue.data(null);
  }

  // ─── Profile ─────────────────────────────────────────────

  Future<void> updateProfile({
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
    final current = state.valueOrNull;
    if (current == null) return;

    try {
      final updated = await _repo.updateProfile(
        firstName: firstName,
        lastName: lastName,
        contactEmail: contactEmail,
        phoneNumber: phoneNumber,
        whatsappNumber: whatsappNumber,
        nationalId: nationalId,
        dateOfBirth: dateOfBirth,
        gender: gender,
        countryOfResidence: countryOfResidence,
        address: address,
        bio: bio,
      );
      state = AsyncValue.data(updated);
    } on AppError {
      state = AsyncValue.data(current);
      rethrow;
    }
  }

  Future<void> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;
    try {
      final updated = await _repo.uploadAvatar(
        bytes: bytes,
        fileName: fileName,
      );
      state = AsyncValue.data(updated);
    } on AppError {
      state = AsyncValue.data(current);
      rethrow;
    }
  }
}