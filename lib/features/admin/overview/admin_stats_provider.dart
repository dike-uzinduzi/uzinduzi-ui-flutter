import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';

class AdminStats {
  final int totalUsers;
  final int totalArtists;
  final int totalAlbums;
  final int publishedAlbums;
  final int activeLaunches;
  final int scheduledLaunches;
  final int totalPlaques;
  final int pendingPlaques;
  final int revenueTotalCents;
  final int revenueThisMonthCents;
  final int pendingPayoutsCents;
  final int newUsersThisWeek;

  const AdminStats({
    required this.totalUsers,
    required this.totalArtists,
    required this.totalAlbums,
    required this.publishedAlbums,
    required this.activeLaunches,
    required this.scheduledLaunches,
    required this.totalPlaques,
    required this.pendingPlaques,
    required this.revenueTotalCents,
    required this.revenueThisMonthCents,
    required this.pendingPayoutsCents,
    required this.newUsersThisWeek,
  });

  factory AdminStats.fromJson(Map<String, dynamic> j) {
    final users = (j['users'] as Map?) ?? {};
    final albums = (j['albums'] as Map?) ?? {};
    final launches = (j['launches'] as Map?) ?? {};
    final revenue = (j['revenue'] as Map?) ?? {};
    final plaques = (j['plaques'] as Map?) ?? {};

    return AdminStats(
      totalUsers: (users['total'] as num?)?.toInt() ?? 0,
      totalArtists: (users['artists'] as num?)?.toInt() ?? 0,
      newUsersThisWeek: (users['newThisWeek'] as num?)?.toInt() ?? 0,
      totalAlbums: (albums['total'] as num?)?.toInt() ?? 0,
      publishedAlbums: (albums['published'] as num?)?.toInt() ?? 0,
      activeLaunches: (launches['active'] as num?)?.toInt() ?? 0,
      scheduledLaunches: (launches['scheduled'] as num?)?.toInt() ?? 0,
      totalPlaques: (plaques['total'] as num?)?.toInt() ?? 0,
      pendingPlaques: (plaques['pendingShipment'] as num?)?.toInt() ?? 0,
      revenueTotalCents: (revenue['totalCents'] as num?)?.toInt() ?? 0,
      revenueThisMonthCents:
          (revenue['thisMonthCents'] as num?)?.toInt() ?? 0,
      pendingPayoutsCents:
          (revenue['pendingPayoutsCents'] as num?)?.toInt() ?? 0,
    );
  }
}

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  final api = ref.read(apiClientProvider);
  final res = await api.get('/api/admin/stats');
  if (res['success'] != true || res['data'] == null) {
    throw Exception(res['message'] ?? 'Could not load stats');
  }
  return AdminStats.fromJson(
    Map<String, dynamic>.from(res['data'] as Map),
  );
});
