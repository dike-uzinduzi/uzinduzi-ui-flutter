import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../shared/admin_stat_card.dart';
import 'admin_stats_provider.dart';

class AdminOverviewScreen extends ConsumerWidget {
  const AdminOverviewScreen({super.key});

  String _fmtMoney(int cents) {
    final dollars = cents / 100;
    if (dollars >= 1000000) {
      return '\$${(dollars / 1000000).toStringAsFixed(1)}M';
    }
    if (dollars >= 1000) {
      return '\$${(dollars / 1000).toStringAsFixed(1)}K';
    }
    return '\$${dollars.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider);

    return RefreshIndicator(
      color: kUzinduziRed,
      onRefresh: () async => ref.invalidate(adminStatsProvider),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: kUzinduziBlack,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Platform health at a glance',
                style: TextStyle(fontSize: 14, color: kUzinduziGrey),
              ),
              const SizedBox(height: 24),

              stats.when(
                data: (s) => LayoutBuilder(
                  builder: (context, c) {
                    final cols = c.maxWidth >= 1100
                        ? 4
                        : c.maxWidth >= 700
                            ? 3
                            : c.maxWidth >= 450
                                ? 2
                                : 1;
                    final gap = 16.0;
                    final cardWidth =
                        (c.maxWidth - (cols - 1) * gap) / cols;

                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: AdminStatCard(
                            label: 'Total users',
                            value: '${s.totalUsers}',
                            subtitle: '+${s.newUsersThisWeek} this week',
                            icon: Icons.people_outline,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: AdminStatCard(
                            label: 'Artists',
                            value: '${s.totalArtists}',
                            icon: Icons.mic_none,
                            accent: kTierGold,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: AdminStatCard(
                            label: 'Albums',
                            value: '${s.totalAlbums}',
                            subtitle: '${s.publishedAlbums} published',
                            icon: Icons.album_outlined,
                            accent: kTierSapphire,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: AdminStatCard(
                            label: 'Active launches',
                            value: '${s.activeLaunches}',
                            subtitle: '${s.scheduledLaunches} scheduled',
                            icon: Icons.rocket_launch_outlined,
                            accent: kStatusLive,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: AdminStatCard(
                            label: 'Revenue (all time)',
                            value: _fmtMoney(s.revenueTotalCents),
                            subtitle:
                                '${_fmtMoney(s.revenueThisMonthCents)} this month',
                            icon: Icons.payments_outlined,
                            accent: kTierEmerald,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: AdminStatCard(
                            label: 'Pending payouts',
                            value: _fmtMoney(s.pendingPayoutsCents),
                            icon: Icons.schedule_outlined,
                            accent: kStatusScheduled,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: AdminStatCard(
                            label: 'Plaques',
                            value: '${s.totalPlaques}',
                            subtitle: '${s.pendingPlaques} awaiting shipment',
                            icon: Icons.workspace_premium_outlined,
                            accent: kTierGold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Center(
                    child: CircularProgressIndicator(color: kUzinduziRed),
                  ),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 32,
                          color: kUzinduziGrey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Could not load stats',
                          style: const TextStyle(color: kUzinduziGrey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$e',
                          style: const TextStyle(
                            fontSize: 11,
                            color: kUzinduziGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () =>
                              ref.invalidate(adminStatsProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
