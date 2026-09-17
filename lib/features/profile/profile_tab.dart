import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../auth/auth_controller.dart';
import '../home/home_providers.dart';
import 'edit_profile_screen.dart';

class ProfileTab extends ConsumerWidget {
  /// When true, renders its own Scaffold + AppBar.
  /// When false (used inside `_ProfileRoute`), the outer route provides
  /// the AppBar with a back button.
  final bool showAppBar;

  const ProfileTab({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final stats = ref.watch(fanStatsProvider);

    final content = LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1000;

        if (!wide) {
          return _NarrowProfile(user: user, stats: stats, ref: ref);
        }

        return _WideProfile(user: user, stats: stats, ref: ref);
      },
    );

    if (!showAppBar) {
      return Container(
        color: kUzinduziWhite,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: kUzinduziWhite,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: content,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// WIDE — three columns
// ─────────────────────────────────────────────────────────────
class _WideProfile extends StatelessWidget {
  const _WideProfile({
    required this.user,
    required this.stats,
    required this.ref,
  });

  final dynamic user;
  final AsyncValue<dynamic> stats;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Left sidebar: identity ───────────────
        SizedBox(
          width: 300,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: _AvatarDisplay(radius: 60)),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    user?.displayName ?? user?.userName ?? '',
                    textAlign: TextAlign.center,
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
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: kUzinduziGrey,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
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
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text(
                      'Edit profile',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kUzinduziBlack,
                      side: const BorderSide(color: kUzinduziDivider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(color: kUzinduziDivider),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        ref.read(authControllerProvider.notifier).logout(),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text(
                      'Sign out',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kUzinduziBlack,
                      side: const BorderSide(color: kUzinduziDivider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const VerticalDivider(width: 1, color: kUzinduziDivider),

        // ── Center: stats cards grid ─────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: kUzinduziBlack,
                  ),
                ),
                const SizedBox(height: 16),
                stats.when(
                  data: (s) => LayoutBuilder(
                    builder: (context, c) {
                      final cols = c.maxWidth >= 700 ? 4 : 2;
                      return GridView.count(
                        crossAxisCount: cols,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.4,
                        children: [
                          _StatCard(
                            icon: Icons.workspace_premium,
                            color: kTierGold,
                            label: 'Plaques',
                            value: '${s.totalPlaques}',
                          ),
                          _StatCard(
                            icon: Icons.favorite,
                            color: kUzinduziRed,
                            label: 'Total backed',
                            value: formatMoney(s.totalSpent),
                          ),
                          _StatCard(
                            icon: Icons.person_add_alt,
                            color: kTierSapphire,
                            label: 'Following',
                            value: '${s.artistsFollowed}',
                          ),
                          _StatCard(
                            icon: Icons.mic_none,
                            color: kStatusLive,
                            label: 'Supported',
                            value: '${s.artistsSupported}',
                          ),
                        ],
                      );
                    },
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child:
                          CircularProgressIndicator(color: kUzinduziRed),
                    ),
                  ),
                  error: (_, _) => const Text(
                    'Could not load stats',
                    style: TextStyle(color: kUzinduziGrey),
                  ),
                ),
              ],
            ),
          ),
        ),

        const VerticalDivider(width: 1, color: kUzinduziDivider),

        // ── Right sidebar: quick links ───────────
        SizedBox(
          width: 300,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'More',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: kUzinduziBlack,
                  ),
                ),
                const SizedBox(height: 12),
                _QuickLink(
                  icon: Icons.emoji_events_outlined,
                  label: 'Badge wall',
                  onTap: null,
                ),
                _QuickLink(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Wallet',
                  onTap: null,
                ),
                _QuickLink(
                  icon: Icons.receipt_long_outlined,
                  label: 'Support history',
                  onTap: null,
                ),
                _QuickLink(
                  icon: Icons.settings_outlined,
                  label: 'Account settings',
                  onTap: null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// NARROW — stacked
// ─────────────────────────────────────────────────────────────
class _NarrowProfile extends StatelessWidget {
  const _NarrowProfile({
    required this.user,
    required this.stats,
    required this.ref,
  });

  final dynamic user;
  final AsyncValue<dynamic> stats;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Center(child: _AvatarDisplay(radius: 48)),
        const SizedBox(height: 16),
        Center(
          child: Text(
            user?.displayName ?? user?.userName ?? '',
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
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 5,
            ),
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
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const EditProfileScreen(),
              ),
            ),
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text(
              'Edit profile',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: kUzinduziBlack,
              side: const BorderSide(color: kUzinduziDivider),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Divider(color: kUzinduziDivider),
        const SizedBox(height: 16),
        const Text(
          'Your activity',
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
            child: Center(
              child: CircularProgressIndicator(color: kUzinduziRed),
            ),
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
          'More',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: kUzinduziBlack,
          ),
        ),
        const SizedBox(height: 8),
        _QuickLink(
          icon: Icons.emoji_events_outlined,
          label: 'Badge wall',
          onTap: null,
        ),
        _QuickLink(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Wallet',
          onTap: null,
        ),
        _QuickLink(
          icon: Icons.receipt_long_outlined,
          label: 'Support history',
          onTap: null,
        ),
        _QuickLink(
          icon: Icons.settings_outlined,
          label: 'Account settings',
          onTap: null,
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 44,
          child: OutlinedButton.icon(
            onPressed: () =>
                ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text(
              'Sign out',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: kUzinduziBlack,
              side: const BorderSide(color: kUzinduziDivider),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Avatar — reads from authController, falls back to placeholder
// ─────────────────────────────────────────────────────────────
class _AvatarDisplay extends ConsumerWidget {
  const _AvatarDisplay({required this.radius});
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final url = user?.avatarUrl;

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: kUzinduziRed.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: (url != null && url.isNotEmpty)
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              width: radius * 2,
              height: radius * 2,
              placeholder: (_, _) => const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: kUzinduziRed,
                  ),
                ),
              ),
              errorWidget: (_, _, _) => Icon(
                Icons.person,
                size: radius,
                color: kUzinduziRed,
              ),
            )
          : Icon(
              Icons.person,
              size: radius,
              color: kUzinduziRed,
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Small widgets
// ─────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kUzinduziDivider),
        boxShadow: [
          BoxShadow(
            color: kUzinduziBlack.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: kUzinduziBlack,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: kUzinduziGrey,
            ),
          ),
        ],
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
              style: const TextStyle(
                fontSize: 14,
                color: kUzinduziBlack,
              ),
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

class _QuickLink extends StatelessWidget {
  const _QuickLink({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: disabled ? kUzinduziDivider : kUzinduziBlack,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: disabled ? kUzinduziDivider : kUzinduziBlack,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (disabled)
              const Text(
                'Soon',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: kUzinduziGrey,
                  letterSpacing: 0.8,
                ),
              )
            else
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: kUzinduziGrey,
              ),
          ],
        ),
      ),
    );
  }
}