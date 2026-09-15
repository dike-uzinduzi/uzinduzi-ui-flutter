import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/errors.dart';
import 'auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider), ref.watch(tokenStorageProvider));
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

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.login(email: email, password: password);
      state = AsyncValue.data(user);
    } on AppError catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncValue.data(null);
  }
}
