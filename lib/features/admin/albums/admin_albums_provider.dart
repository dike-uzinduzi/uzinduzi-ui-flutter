import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import 'admin_album_model.dart';

class AdminAlbumsQuery {
  final String search;
  final String albumType;
  final bool? published;
  final bool? featured;
  final bool deleted;
  final int page;
  final int limit;

  const AdminAlbumsQuery({
    this.search = '',
    this.albumType = '',
    this.published,
    this.featured,
    this.deleted = false,
    this.page = 1,
    this.limit = 25,
  });

  AdminAlbumsQuery copyWith({
    String? search,
    String? albumType,
    Object? published = _sentinel,
    Object? featured = _sentinel,
    bool? deleted,
    int? page,
    int? limit,
  }) =>
      AdminAlbumsQuery(
        search: search ?? this.search,
        albumType: albumType ?? this.albumType,
        published:
            identical(published, _sentinel) ? this.published : published as bool?,
        featured:
            identical(featured, _sentinel) ? this.featured : featured as bool?,
        deleted: deleted ?? this.deleted,
        page: page ?? this.page,
        limit: limit ?? this.limit,
      );

  Map<String, dynamic> toQueryParams() => {
        if (search.isNotEmpty) 'search': search,
        if (albumType.isNotEmpty) 'albumType': albumType,
        if (published != null) 'published': published.toString(),
        if (featured != null) 'featured': featured.toString(),
        'deleted': deleted.toString(),
        'page': page.toString(),
        'limit': limit.toString(),
      };
}

const _sentinel = Object();

class AdminAlbumsResult {
  final List<AdminAlbumRow> albums;
  final int total;
  final int page;
  final int limit;

  const AdminAlbumsResult({
    required this.albums,
    required this.total,
    required this.page,
    required this.limit,
  });

  int get pageCount => (total + limit - 1) ~/ limit;
}

class AdminAlbumsQueryNotifier extends StateNotifier<AdminAlbumsQuery> {
  AdminAlbumsQueryNotifier() : super(const AdminAlbumsQuery());

  void setSearch(String s) => state = state.copyWith(search: s, page: 1);
  void setAlbumType(String t) => state = state.copyWith(albumType: t, page: 1);
  void setPublished(bool? v) => state = state.copyWith(published: v, page: 1);
  void setFeatured(bool? v) => state = state.copyWith(featured: v, page: 1);
  void setDeleted(bool v) => state = state.copyWith(deleted: v, page: 1);
  void setPage(int p) => state = state.copyWith(page: p);
  void reset() => state = const AdminAlbumsQuery();
}

final adminAlbumsQueryProvider =
    StateNotifierProvider<AdminAlbumsQueryNotifier, AdminAlbumsQuery>(
  (ref) => AdminAlbumsQueryNotifier(),
);

final adminAlbumsProvider = FutureProvider<AdminAlbumsResult>((ref) async {
  final query = ref.watch(adminAlbumsQueryProvider);
  final api = ref.read(apiClientProvider);

  final res = await api.get(
    '/api/admin/albums',
    query: query.toQueryParams(),
  );

  if (res['success'] != true || res['data'] == null) {
    throw Exception(res['message'] ?? 'Could not load albums');
  }

  final data = Map<String, dynamic>.from(res['data'] as Map);
  final items = (data['items'] as List?) ?? const [];

  return AdminAlbumsResult(
    albums: items
        .whereType<Map>()
        .map((m) => AdminAlbumRow.fromJson(Map<String, dynamic>.from(m)))
        .toList(),
    total: (data['total'] as num?)?.toInt() ?? items.length,
    page: (data['page'] as num?)?.toInt() ?? 1,
    limit: (data['limit'] as num?)?.toInt() ?? 25,
  );
});
