import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../auth/auth_controller.dart';
import '../home/home_providers.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final stats = ref.watch(fanStatsProvider);

    return Scaffold(
      backgroundColor: kUzinduziWhite,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: kUzinduziRed.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 48, color: kUzinduziRed),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  user?.userName ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: kUzinduziBlack,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  user?.email ?? '',
                  style: const TextStyle(fontSize: 14, color: kUzinduziGrey),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: kUzinduziRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    (user?.role ?? '').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: kUzinduziRed,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              const Divider(color: kUzinduziDivider),
              const SizedBox(height: 16),

              const Text(
                'Stats',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kUzinduziBlack,
                ),
              ),
              const SizedBox(height: 12),

              stats.when(
                data: (s) => Column(
                  children: [
                    _StatLine(
                      icon: Icons.workspace_premium,
                      color: kTierGold,
                      label: 'Plaques earned',
                      value: '${s.totalPlaques}',
                    ),
                    _StatLine(
                      icon: Icons.favorite,
                      color: kUzinduziRed,
                      label: 'Total backed',
                      value: formatMoney(s.totalSpent),
                    ),
                    _StatLine(
                      icon: Icons.person_add_alt,
                      color: kTierSapphire,
                      label: 'Artists following',
                      value: '${s.artistsFollowed}',
                    ),
                    _StatLine(
                      icon: Icons.mic_none,
                      color: kStatusLive,
                      label: 'Artists supported',
                      value: '${s.artistsSupported}',
                    ),
                  ],
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator(color: kUzinduziRed)),
                ),
                error: (_, _) => const Text(
                  'Could not load stats',
                  style: TextStyle(color: kUzinduziGrey),
                ),
              ),

              const SizedBox(height: 32),
              const Divider(color: kUzinduziDivider),
              const SizedBox(height: 16),

              const Text(
                'Coming soon',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kUzinduziBlack,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Profile editing · Avatar upload · Badge wall · Wallet',
                style: TextStyle(fontSize: 13, color: kUzinduziGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatLine({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: kUzinduziBlack),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kUzinduziBlack,
            ),
          ),
        ],
      ),
    );
  }
}