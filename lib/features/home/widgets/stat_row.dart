import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../home_providers.dart';
import 'stat_card.dart';

class StatRow extends ConsumerWidget {
  const StatRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(liveNowCountProvider);
    final stats = ref.watch(fanStatsProvider);

    String s(AsyncValue<dynamic> v, String Function(dynamic) fn) => v.when(
          data: (d) => fn(d),
          loading: () => '—',
          error: (_, _) => '—',
        );

    return Row(
      children: [
        Expanded(
          child: StatCard(
            value: s(live, (v) => '$v'),
            label: 'Live',
            icon: Icons.podcasts,
            color: kStatusLive,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            value: s(stats, (x) => '${x.totalPlaques}'),
            label: 'Plaques',
            icon: Icons.workspace_premium,
            color: kTierGold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            value: s(stats, (x) => formatMoney(x.totalSpent)),
            label: 'Backed',
            icon: Icons.favorite,
            color: kUzinduziRed,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            value: s(stats, (x) => '${x.artistsFollowed}'),
            label: 'Following',
            icon: Icons.person_add_alt,
            color: kTierSapphire,
          ),
        ),
      ],
    );
  }
}