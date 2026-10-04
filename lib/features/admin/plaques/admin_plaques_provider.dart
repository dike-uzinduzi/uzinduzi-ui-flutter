import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../../../core/errors.dart';
import 'admin_plaque_model.dart';

class PlaqueListResult {
  final List<AdminPlaque> items;
  final int total;
  final int page;
  final int pageCount;

  PlaqueListResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageCount,
  });
}

class AdminPlaquesQuery {
  final String status;
  final String search;
  final int page;

  const AdminPlaquesQuery({
    this.status = '',
    this.search = '',
    this.page = 1,
  });

  AdminPlaquesQuery copyWith({String? status, String? search, int? page}) =>
      AdminPlaquesQuery(
        status: status ?? this.status,
        search: search ?? this.search,
        page: page ?? this.page,
      );
}

class AdminPlaquesRepository {
  final ApiClient _api;
  AdminPlaquesRepository(this._api);

  Future<PlaqueListResult> list(AdminPlaquesQuery q) async {
    final params = <String, String>{
      'page': q.page.toString(),
      'limit': '25',
    };
    if (q.status.isNotEmpty) params['status'] = q.status;
    if (q.search.isNotEmpty) params['search'] = q.search;

    final query = params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final res = await _api.get('/api/admin/plaques?$query');
    if (res['success'] != true) {
      throw AppError(res['message']?.toString() ?? 'Could not load plaques');
    }

    final data = res['data'];
    final items = data is Map && data['items'] is List
        ? (data['items'] as List)
        : data is List
            ? data
            : const [];

    final total = data is Map
        ? (data['total'] as num?)?.toInt() ?? items.length
        : items.length;
    final page = data is Map ? (data['page'] as num?)?.toInt() ?? 1 : 1;
    final limit = data is Map ? (data['limit'] as num?)?.toInt() ?? 25 : 25;
    final pageCount = (total / limit).ceil().clamp(1, 1 << 30);

    return PlaqueListResult(
      items: items
          .whereType<Map>()
          .map((j) => AdminPlaque.fromJson(Map<String, dynamic>.from(j)))
          .toList(),
      total: total,
      page: page,
      pageCount: pageCount,
    );
  }

  Future<AdminPlaque> get(String id) async {
    final res = await _api.get('/api/admin/plaques/$id');
    if (res['success'] != true || res['data'] == null) {
      throw AppError(res['message']?.toString() ?? 'Plaque not found');
    }
    return AdminPlaque.fromJson(
      Map<String, dynamic>.from(res['data'] as Map),
    );
  }

  Future<AdminPlaque> updateStatus(
    String id, {
    required String status,
    String? trackingNumber,
    String? cancellationReason,
  }) async {
    final body = <String, dynamic>{'status': status};
    if (trackingNumber != null) body['trackingNumber'] = trackingNumber;
    if (cancellationReason != null) {
      body['cancellationReason'] = cancellationReason;
    }

    final res = await _api.dio.patch(
      '/api/admin/plaques/$id/status',
      data: body,
    );
    final data =
        res.data is Map ? Map<String, dynamic>.from(res.data as Map) : null;
    if (data == null || data['success'] != true || data['data'] == null) {
      throw AppError(data?['message']?.toString() ?? 'Update failed');
    }
    return AdminPlaque.fromJson(
      Map<String, dynamic>.from(data['data'] as Map),
    );
  }

  Future<AdminPlaque> updateNotes(String id, String adminNotes) async {
    final res = await _api.dio.patch(
      '/api/admin/plaques/$id/notes',
      data: {'adminNotes': adminNotes},
    );
    final data =
        res.data is Map ? Map<String, dynamic>.from(res.data as Map) : null;
    if (data == null || data['success'] != true || data['data'] == null) {
      throw AppError(data?['message']?.toString() ?? 'Save failed');
    }
    return AdminPlaque.fromJson(
      Map<String, dynamic>.from(data['data'] as Map),
    );
  }

  Future<AdminPlaque> updateShipping(
    String id, {
    String? shippingAddress,
    String? trackingNumber,
  }) async {
    final body = <String, dynamic>{};
    if (shippingAddress != null) body['shippingAddress'] = shippingAddress;
    if (trackingNumber != null) body['trackingNumber'] = trackingNumber;

    final res = await _api.dio.patch(
      '/api/admin/plaques/$id/shipping',
      data: body,
    );
    final data =
        res.data is Map ? Map<String, dynamic>.from(res.data as Map) : null;
    if (data == null || data['success'] != true || data['data'] == null) {
      throw AppError(data?['message']?.toString() ?? 'Save failed');
    }
    return AdminPlaque.fromJson(
      Map<String, dynamic>.from(data['data'] as Map),
    );
  }
}

final adminPlaquesRepositoryProvider =
    Provider<AdminPlaquesRepository>((ref) {
  return AdminPlaquesRepository(ref.watch(apiClientProvider));
});

final adminPlaquesQueryProvider =
    StateProvider<AdminPlaquesQuery>((ref) => const AdminPlaquesQuery());

final adminPlaquesProvider =
    FutureProvider<PlaqueListResult>((ref) async {
  final q = ref.watch(adminPlaquesQueryProvider);
  return ref.watch(adminPlaquesRepositoryProvider).list(q);
});