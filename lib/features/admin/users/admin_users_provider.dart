import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import 'admin_user_model.dart';

class AdminUsersQuery {
  final String search;
  final String role;
  final bool? suspended;
  final bool? verified;
  final int page;
  final int limit;

  const AdminUsersQuery({
    this.search = '',
    this.role = '',
    this.suspended,
    this.verified,
    this.page = 1,
    this.limit = 25,
  });

  AdminUsersQuery copyWith({
    String? search,
    String? role,
    Object? suspended = _sentinel,
    Object? verified = _sentinel,
    int? page,
    int? limit,
  }) =>
      AdminUsersQuery(
        search: search ?? this.search,
        role: role ?? this.role,
        suspended:
            identical(suspended, _sentinel) ? this.suspended : suspended as bool?,
        verified:
            identical(verified, _sentinel) ? this.verified : verified as bool?,
        page: page ?? this.page,
        limit: limit ?? this.limit,
      );

  Map<String, dynamic> toQueryParams() => {
        if (search.isNotEmpty) 'search': search,
        if (role.isNotEmpty) 'role': role,
        if (suspended != null) 'suspended': suspended.toString(),
        if (verified != null) 'verified': verified.toString(),
        'page': page.toString(),
        'limit': limit.toString(),
      };
}

const _sentinel = Object();

class AdminUsersResult {
  final List<AdminUserRow> users;
  final int total;
  final int page;
  final int limit;

  const AdminUsersResult({
    required this.users,
    required this.total,
    required this.page,
    required this.limit,
  });

  int get pageCount => (total + limit - 1) ~/ limit;
}

class AdminUsersQueryNotifier extends StateNotifier<AdminUsersQuery> {
  AdminUsersQueryNotifier() : super(const AdminUsersQuery());

  void setSearch(String s) => state = state.copyWith(search: s, page: 1);
  void setRole(String r) => state = state.copyWith(role: r, page: 1);
  void setSuspended(bool? v) => state = state.copyWith(suspended: v, page: 1);
  void setVerified(bool? v) => state = state.copyWith(verified: v, page: 1);
  void setPage(int p) => state = state.copyWith(page: p);
  void reset() => state = const AdminUsersQuery();
}

final adminUsersQueryProvider =
    StateNotifierProvider<AdminUsersQueryNotifier, AdminUsersQuery>(
  (ref) => AdminUsersQueryNotifier(),
);

final adminUsersProvider = FutureProvider<AdminUsersResult>((ref) async {
  final query = ref.watch(adminUsersQueryProvider);
  final api = ref.read(apiClientProvider);

  final res = await api.get(
    '/api/admin/users',
    query: query.toQueryParams(),
  );

  if (res['success'] != true || res['data'] == null) {
    throw Exception(res['message'] ?? 'Could not load users');
  }

  final data = Map<String, dynamic>.from(res['data'] as Map);
  final items = (data['items'] as List?) ?? const [];

  return AdminUsersResult(
    users: items
        .whereType<Map>()
        .map((m) => AdminUserRow.fromJson(Map<String, dynamic>.from(m)))
        .toList(),
    total: (data['total'] as num?)?.toInt() ?? items.length,
    page: (data['page'] as num?)?.toInt() ?? 1,
    limit: (data['limit'] as num?)?.toInt() ?? 25,
  );
});
