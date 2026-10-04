import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../../../core/errors.dart';
import '../../../features/albums/album_models.dart';

class AdminLaunchRepository {
  final ApiClient _api;
  AdminLaunchRepository(this._api);

  Future<AlbumLaunch?> get(String albumId) async {
    final res = await _api.get('/api/albums/$albumId/launch');
    if (res['success'] != true) {
      // 404 = no launch scheduled yet
      return null;
    }
    final data = res['data'];
    if (data == null) return null;
    return AlbumLaunch.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<AlbumLaunch> create(
    String albumId, {
    required DateTime startsAt,
    required DateTime endsAt,
    DateTime? physicalLaunchAt,
    required List<TierThreshold> tierThresholds,
  }) async {
    final body = <String, dynamic>{
      'startsAt': startsAt.toUtc().toIso8601String(),
      'endsAt': endsAt.toUtc().toIso8601String(),
      'status': startsAt.isAfter(DateTime.now()) ? 'scheduled' : 'active',
      'tierThresholds': tierThresholds
          .map((t) => {'tier': t.tier, 'minAmount': t.minAmount})
          .toList(),
      if (physicalLaunchAt != null)
        'physicalLaunchAt': physicalLaunchAt.toUtc().toIso8601String(),
    };

    final res = await _api.post('/api/albums/$albumId/launch', body: body);
    if (res['success'] != true || res['data'] == null) {
      throw AppError(res['message']?.toString() ?? 'Could not create launch');
    }
    return AlbumLaunch.fromJson(
      Map<String, dynamic>.from(res['data'] as Map),
    );
  }

  Future<AlbumLaunch> update(
    String albumId, {
    String? status,
    DateTime? startsAt,
    DateTime? endsAt,
    DateTime? physicalLaunchAt,
    List<TierThreshold>? tierThresholds,
  }) async {
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;
    if (startsAt != null) body['startsAt'] = startsAt.toUtc().toIso8601String();
    if (endsAt != null) body['endsAt'] = endsAt.toUtc().toIso8601String();
    if (physicalLaunchAt != null) {
      body['physicalLaunchAt'] = physicalLaunchAt.toUtc().toIso8601String();
    }
    if (tierThresholds != null) {
      body['tierThresholds'] = tierThresholds
          .map((t) => {'tier': t.tier, 'minAmount': t.minAmount})
          .toList();
    }

    final res = await _api.patch('/api/albums/$albumId/launch', body: body);
    if (res['success'] != true || res['data'] == null) {
      throw AppError(res['message']?.toString() ?? 'Could not update launch');
    }
    return AlbumLaunch.fromJson(
      Map<String, dynamic>.from(res['data'] as Map),
    );
  }

  Future<void> cancel(String albumId) async {
    final res = await _api.delete('/api/albums/$albumId/launch');
    if (res['success'] != true) {
      throw AppError(res['message']?.toString() ?? 'Could not cancel launch');
    }
  }
}

final adminLaunchRepositoryProvider = Provider<AdminLaunchRepository>((ref) {
  return AdminLaunchRepository(ref.watch(apiClientProvider));
});

/// Fetch the launch for an album (nullable — most albums have none).
final adminAlbumLaunchProvider =
    FutureProvider.family<AlbumLaunch?, String>((ref, albumId) async {
  return ref.watch(adminLaunchRepositoryProvider).get(albumId);
});