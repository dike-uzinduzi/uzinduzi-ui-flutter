import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../../../core/errors.dart';
import 'admin_tier_model.dart';

class AdminTiersRepository {
  final ApiClient _api;
  AdminTiersRepository(this._api);

  Future<List<AdminTier>> list() async {
    final res = await _api.get('/api/plaque-tiers/admin');
    if (res['success'] != true) {
      throw AppError(res['message']?.toString() ?? 'Could not load tiers');
    }
    final data = res['data'];
    final items = data is Map && data['items'] is List
        ? data['items'] as List
        : data is List
            ? data
            : const [];
    return items
        .whereType<Map>()
        .map((j) => AdminTier.fromJson(Map<String, dynamic>.from(j)))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<AdminTier> get(String id) async {
    final res = await _api.get('/api/plaque-tiers/$id');
    if (res['success'] != true || res['data'] == null) {
      throw AppError(res['message']?.toString() ?? 'Tier not found');
    }
    return AdminTier.fromJson(
      Map<String, dynamic>.from(res['data'] as Map),
    );
  }

  Future<AdminTier> create(AdminTier tier) async {
    final res = await _api.post(
      '/api/plaque-tiers',
      body: tier.toCreateBody(),
    );
    if (res['success'] != true || res['data'] == null) {
      throw AppError(res['message']?.toString() ?? 'Create failed');
    }
    return AdminTier.fromJson(
      Map<String, dynamic>.from(res['data'] as Map),
    );
  }

  Future<AdminTier> update(String id, AdminTier tier) async {
    final res = await _api.patch(
      '/api/plaque-tiers/$id',
      body: tier.toUpdateBody(),
    );
    if (res['success'] != true || res['data'] == null) {
      throw AppError(res['message']?.toString() ?? 'Update failed');
    }
    return AdminTier.fromJson(
      Map<String, dynamic>.from(res['data'] as Map),
    );
  }

  Future<void> delete(String id) async {
    final res = await _api.delete('/api/plaque-tiers/$id');
    if (res['success'] != true) {
      throw AppError(res['message']?.toString() ?? 'Delete failed');
    }
  }
}

final adminTiersRepositoryProvider = Provider<AdminTiersRepository>((ref) {
  return AdminTiersRepository(ref.watch(apiClientProvider));
});

final adminTiersProvider = FutureProvider<List<AdminTier>>((ref) async {
  return ref.watch(adminTiersRepositoryProvider).list();
});