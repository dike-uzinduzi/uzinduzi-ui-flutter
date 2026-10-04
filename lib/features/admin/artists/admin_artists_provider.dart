import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../../../core/errors.dart';
import 'admin_artist_model.dart';

class AdminArtistsRepository {
  final ApiClient _api;
  AdminArtistsRepository(this._api);

  Future<List<AdminArtist>> list({String? search}) async {
    final query = search != null && search.trim().isNotEmpty
        ? '?search=${Uri.encodeComponent(search.trim())}'
        : '';
    final res = await _api.get('/api/artists$query');
    if (res['success'] != true) {
      throw AppError(res['message']?.toString() ?? 'Could not load artists');
    }
    final data = res['data'];
    final items = data is Map && data['items'] is List
        ? data['items'] as List
        : data is List
            ? data
            : const [];
    return items
        .whereType<Map>()
        .map((j) => AdminArtist.fromJson(Map<String, dynamic>.from(j)))
        .toList();
  }

  Future<AdminArtist> get(String id) async {
    final res = await _api.get('/api/artists/$id');
    if (res['success'] != true || res['data'] == null) {
      throw AppError(res['message']?.toString() ?? 'Artist not found');
    }
    return AdminArtist.fromJson(
      Map<String, dynamic>.from(res['data'] as Map),
    );
  }

  Future<AdminArtist> create(AdminArtist artist) async {
    final res = await _api.post(
      '/api/artists',
      body: artist.toCreateBody(),
    );
    if (res['success'] != true || res['data'] == null) {
      throw AppError(res['message']?.toString() ?? 'Create failed');
    }
    return AdminArtist.fromJson(
      Map<String, dynamic>.from(res['data'] as Map),
    );
  }

  Future<AdminArtist> update(String id, AdminArtist artist) async {
    final res = await _api.dio.put(
      '/api/artists/$id',
      data: artist.toUpdateBody(),
    );
    final data = res.data is Map ? Map<String, dynamic>.from(res.data as Map) : null;
    if (data == null || data['success'] != true || data['data'] == null) {
      throw AppError(data?['message']?.toString() ?? 'Update failed');
    }
    return AdminArtist.fromJson(
      Map<String, dynamic>.from(data['data'] as Map),
    );
  }

  Future<void> delete(String id) async {
    final res = await _api.delete('/api/artists/$id');
    if (res['success'] != true) {
      throw AppError(res['message']?.toString() ?? 'Delete failed');
    }
  }
}

final adminArtistsRepositoryProvider =
    Provider<AdminArtistsRepository>((ref) {
  return AdminArtistsRepository(ref.watch(apiClientProvider));
});

final adminArtistsQueryProvider = StateProvider<String>((ref) => '');

final adminArtistsProvider =
    FutureProvider<List<AdminArtist>>((ref) async {
  final search = ref.watch(adminArtistsQueryProvider);
  return ref.watch(adminArtistsRepositoryProvider).list(search: search);
});