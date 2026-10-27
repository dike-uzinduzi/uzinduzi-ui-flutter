import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../../../core/errors.dart';
import 'admin_payment_model.dart';

class PaymentListResult {
  final List<AdminPayment> items;
  final int total;
  final int page;
  final int pageCount;

  PaymentListResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageCount,
  });
}

class PaymentsStats {
  final int total;
  final int success;
  final int pending;
  final int failed;
  final int revenueCents;

  PaymentsStats({
    required this.total,
    required this.success,
    required this.pending,
    required this.failed,
    required this.revenueCents,
  });

  factory PaymentsStats.fromJson(Map<String, dynamic> j) {
    final centsRaw = (j['revenueCents'] as num?)?.toInt();
    final dollarsRaw = (j['revenue'] as num?)?.toDouble();
    final cents = centsRaw ?? ((dollarsRaw ?? 0) * 100).round();

    return PaymentsStats(
      total: (j['total'] as num?)?.toInt() ?? 0,
      success: (j['success'] as num?)?.toInt() ?? 0,
      pending: (j['pending'] as num?)?.toInt() ?? 0,
      failed: (j['failed'] as num?)?.toInt() ?? 0,
      revenueCents: cents,
    );
  }

  String get revenueLabel => '\$${(revenueCents / 100).toStringAsFixed(2)}';
}

class AdminPaymentsQuery {
  final String status;
  final String method;
  final String search;
  final int page;

  const AdminPaymentsQuery({
    this.status = '',
    this.method = '',
    this.search = '',
    this.page = 1,
  });

  AdminPaymentsQuery copyWith({
    String? status,
    String? method,
    String? search,
    int? page,
  }) =>
      AdminPaymentsQuery(
        status: status ?? this.status,
        method: method ?? this.method,
        search: search ?? this.search,
        page: page ?? this.page,
      );

  Map<String, dynamic> toQueryParams() => {
        'page': page.toString(),
        'limit': '25',
        if (status.isNotEmpty) 'status': status,
        if (method.isNotEmpty) 'method': method,
        if (search.isNotEmpty) 'search': search,
      };
}

class AdminPaymentsRepository {
  final ApiClient _api;
  AdminPaymentsRepository(this._api);

  Future<PaymentListResult> list(AdminPaymentsQuery q) async {
    final res = await _api.get(
      '/api/admin/payments',
      query: q.toQueryParams(),
    );
    if (res['success'] != true || res['data'] == null) {
      throw AppError(res['message']?.toString() ?? 'Could not load payments');
    }
    final data = Map<String, dynamic>.from(res['data'] as Map);
    final items = (data['items'] as List?) ?? const [];
    final total = (data['total'] as num?)?.toInt() ?? items.length;
    final page = (data['page'] as num?)?.toInt() ?? 1;
    final limit = (data['limit'] as num?)?.toInt() ?? 25;

    return PaymentListResult(
      items: items
          .whereType<Map>()
          .map((m) => AdminPayment.fromJson(Map<String, dynamic>.from(m)))
          .toList(),
      total: total,
      page: page,
      pageCount: ((total + limit - 1) ~/ limit).clamp(1, 1 << 30),
    );
  }

  Future<PaymentsStats> stats() async {
    final res = await _api.get('/api/admin/payments/stats');
    if (res['success'] != true || res['data'] == null) {
      throw AppError(res['message']?.toString() ?? 'Could not load stats');
    }
    return PaymentsStats.fromJson(
      Map<String, dynamic>.from(res['data'] as Map),
    );
  }

  Future<AdminPayment> get(String id) async {
    final res = await _api.get('/api/admin/payments/$id');
    if (res['success'] != true || res['data'] == null) {
      throw AppError(res['message']?.toString() ?? 'Payment not found');
    }
    return AdminPayment.fromJson(
      Map<String, dynamic>.from(res['data'] as Map),
    );
  }

  Future<AdminPayment> updateStatus(
    String id, {
    required String status,
    String? reason,
  }) async {
    final body = <String, dynamic>{'status': status};
    if (reason != null) body['reason'] = reason;

    final res = await _api.dio.patch(
      '/api/admin/payments/$id/status',
      data: body,
    );
    final data =
        res.data is Map ? Map<String, dynamic>.from(res.data as Map) : null;
    if (data == null || data['success'] != true || data['data'] == null) {
      throw AppError(data?['message']?.toString() ?? 'Update failed');
    }
    return AdminPayment.fromJson(
      Map<String, dynamic>.from(data['data'] as Map),
    );
  }
}

final adminPaymentsRepositoryProvider =
    Provider<AdminPaymentsRepository>((ref) {
  return AdminPaymentsRepository(ref.watch(apiClientProvider));
});

final adminPaymentsQueryProvider =
    StateProvider<AdminPaymentsQuery>((ref) => const AdminPaymentsQuery());

final adminPaymentsProvider =
    FutureProvider<PaymentListResult>((ref) async {
  final q = ref.watch(adminPaymentsQueryProvider);
  return ref.watch(adminPaymentsRepositoryProvider).list(q);
});

final adminPaymentsStatsProvider =
    FutureProvider<PaymentsStats>((ref) async {
  return ref.watch(adminPaymentsRepositoryProvider).stats();
});