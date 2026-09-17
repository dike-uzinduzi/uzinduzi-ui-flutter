import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../widgets/uzinduzi_logo.dart';
import '../albums/album_detail_screen.dart';
import '../albums/albums_provider.dart';
import '../auth/auth_controller.dart';
import '../notifications/notifications_provider.dart';
import '../profile/edit_profile_screen.dart';
import 'home_providers.dart';
import 'widgets/featured_album_hero.dart';
import 'widgets/home_tile.dart';
import 'widgets/stat_row.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final featured = ref.watch(featuredAlbumProvider);
    final albums = ref.watch(albumsProvider);
    final liveCount = ref.watch(liveNowCountProvider);
    final stats = ref.watch(fanStatsProvider);
    final unread = ref.watch(unreadNotificationsProvider);

    return Scaffold(
      backgroundColor: kUzinduziWhite,
      appBar: AppBar(
        title: const UzinduziLogo(variant: LogoVariant.wordmark, height: 28),
        actions: [
          _AvatarAction(
            avatarUrl: user?.avatarUrl,
            unreadCount: unread.valueOrNull ?? 0,
            missingProfileFields: user?.missingProfileFields ?? 0,
            displayName: user?.displayName ?? user?.userName ?? '',
            email: user?.email ?? '',
            isAdmin: user?.role == 'admin' || user?.role == 'super_admin',
            onSignOut: () async {
              await ref.read(authControllerProvider.notifier).logout();
            },
            onNotificationsOpened: () {
              ref.invalidate(unreadNotificationsProvider);
              ref.invalidate(notificationsFeedProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: kUzinduziRed,
        onRefresh: () async {
          ref.invalidate(albumsProvider);
          ref.invalidate(fanStatsProvider);
          ref.invalidate(unreadNotificationsProvider);
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Text(
                  'Welcome,  ${user?.userName ?? "there"}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: kUzinduziBlack,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 16),

                const StatRow(),
                const SizedBox(height: 20),

                featured.when(
                  data: (album) {
                    if (album == null) return const _EmptyHero();
                    return Column(
                      children: [
                        FeaturedAlbumHero(
                          album: album,
                          onSupport: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AlbumDetailScreen(
                                  albumId: album.id,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child:
                          CircularProgressIndicator(color: kUzinduziRed),
                    ),
                  ),
                  error: (_, _) => const _EmptyHero(),
                ),

                const Text(
                  'Quick access',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kUzinduziBlack,
                  ),
                ),
                const SizedBox(height: 12),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 700;
                    final tileWidth = isWide
                        ? 220.0
                        : (constraints.maxWidth - 12) / 2;

                    Widget tile({required Widget child}) => SizedBox(
                          width: tileWidth,
                          height: 110,
                          child: child,
                        );

                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        tile(
                          child: HomeTile(
                            icon: Icons.album_outlined,
                            label: 'Albums',
                            badgeCount: albums.maybeWhen(
                              data: (a) => a.length,
                              orElse: () => null,
                            ),
                            onTap: () {},
                          ),
                        ),
                        tile(
                          child: HomeTile(
                            icon: Icons.podcasts,
                            label: 'Live Now',
                            accent: kStatusLive,
                            badgeCount: liveCount.maybeWhen(
                              data: (c) => c,
                              orElse: () => null,
                            ),
                            onTap: () {},
                          ),
                        ),
                        tile(
                          child: HomeTile(
                            icon: Icons.workspace_premium_outlined,
                            label: 'My Plaques',
                            accent: kTierGold,
                            badgeCount: stats.maybeWhen(
                              data: (s) => s.totalPlaques,
                              orElse: () => null,
                            ),
                            onTap: () {},
                          ),
                        ),
                        tile(
                          child: HomeTile(
                            icon: Icons.newspaper_outlined,
                            label: 'News',
                            accent: kTierSapphire,
                            onTap: () {},
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// AppBar avatar with dropdown menu
// ─────────────────────────────────────────────────────────────
class _AvatarAction extends StatelessWidget {
  const _AvatarAction({
    required this.avatarUrl,
    required this.unreadCount,
    required this.missingProfileFields,
    required this.displayName,
    required this.email,
    required this.onSignOut,
    this.isAdmin = false,
    this.onNotificationsOpened,
  });

  final String? avatarUrl;
  final int unreadCount;
  final int missingProfileFields;
  final String displayName;
  final String email;
  final bool isAdmin;
  final Future<void> Function() onSignOut;
  final VoidCallback? onNotificationsOpened;

  @override
  Widget build(BuildContext context) {
    final hasImage = avatarUrl != null && avatarUrl!.isNotEmpty;
    final showNotifications = unreadCount > 0;
    final showProfileNudge = missingProfileFields > 0;

    final avatar = Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: kUzinduziRed.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: kUzinduziDivider, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? CachedNetworkImage(
              imageUrl: avatarUrl!,
              fit: BoxFit.cover,
              width: 36,
              height: 36,
              placeholder: (_, _) => const Center(
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: kUzinduziRed,
                  ),
                ),
              ),
              errorWidget: (_, _, _) => const Icon(
                Icons.person,
                size: 20,
                color: kUzinduziRed,
              ),
            )
          : const Icon(
              Icons.person,
              size: 20,
              color: kUzinduziRed,
            ),
    );

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: PopupMenuButton<_AvatarMenuAction>(
        tooltip: 'Account',
        offset: const Offset(0, 48),
        position: PopupMenuPosition.under,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        color: Colors.white,
        elevation: 8,
        onSelected: (action) => _onMenuSelected(context, action),
        itemBuilder: (context) => [
          // ── Header ─────────────────────────────
          PopupMenuItem<_AvatarMenuAction>(
            enabled: false,
            height: 64,
            child: SizedBox(
              width: 220,
              child: Row(
                children: [
                  SizedBox(width: 40, height: 40, child: avatar),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: kUzinduziBlack,
                          ),
                        ),
                        Text(
                          email,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: kUzinduziGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const PopupMenuDivider(),

          // ── Notifications ──────────────────────
          PopupMenuItem<_AvatarMenuAction>(
            value: _AvatarMenuAction.notifications,
            child: _MenuRow(
              icon: Icons.notifications_none,
              label: 'Notifications',
              badge: showNotifications
                  ? _MiniBadge(
                      label: unreadCount > 99 ? '99+' : '$unreadCount',
                      color: kUzinduziRed,
                    )
                  : null,
            ),
          ),

          // ── Edit profile ───────────────────────
          PopupMenuItem<_AvatarMenuAction>(
            value: _AvatarMenuAction.editProfile,
            child: _MenuRow(
              icon: Icons.edit_outlined,
              label: 'Edit profile',
              badge: showProfileNudge
                  ? const _MiniBadge(
                      label: '!',
                      color: kStatusScheduled,
                    )
                  : null,
            ),
          ),

          // ── Wallet ─────────────────────────────
          const PopupMenuItem<_AvatarMenuAction>(
            value: _AvatarMenuAction.wallet,
            child: _MenuRow(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Wallet',
              trailing: 'Soon',
            ),
          ),

          // ── My plaques ─────────────────────────
          const PopupMenuItem<_AvatarMenuAction>(
            value: _AvatarMenuAction.plaques,
            child: _MenuRow(
              icon: Icons.emoji_events_outlined,
              label: 'My plaques',
            ),
          ),

          // ── Support history ────────────────────
          const PopupMenuItem<_AvatarMenuAction>(
            value: _AvatarMenuAction.supportHistory,
            child: _MenuRow(
              icon: Icons.receipt_long_outlined,
              label: 'Support history',
            ),
          ),

          // ── Settings ───────────────────────────
          const PopupMenuItem<_AvatarMenuAction>(
            value: _AvatarMenuAction.settings,
            child: _MenuRow(
              icon: Icons.settings_outlined,
              label: 'Settings',
            ),
          ),

          // ── Admin (only for admins) ────────────
          if (isAdmin) ...[
            const PopupMenuDivider(),
            const PopupMenuItem<_AvatarMenuAction>(
              value: _AvatarMenuAction.admin,
              child: _MenuRow(
                icon: Icons.dashboard_outlined,
                label: 'Admin dashboard',
              ),
            ),
          ],

          const PopupMenuDivider(),

          // ── Sign out ───────────────────────────
          const PopupMenuItem<_AvatarMenuAction>(
            value: _AvatarMenuAction.signOut,
            child: _MenuRow(
              icon: Icons.logout,
              label: 'Sign out',
              danger: true,
            ),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              avatar,
              if (showNotifications)
                Positioned(
                  top: -4,
                  right: -4,
                  child: _MiniBadge(
                    label: unreadCount > 99 ? '99+' : '$unreadCount',
                    color: kUzinduziRed,
                  ),
                ),
              if (!showNotifications && showProfileNudge)
                const Positioned(
                  top: -4,
                  right: -4,
                  child: _MiniBadge(
                    label: '!',
                    color: kStatusScheduled,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onMenuSelected(
    BuildContext context,
    _AvatarMenuAction action,
  ) async {
    switch (action) {
      case _AvatarMenuAction.notifications:
        await Navigator.of(context).pushNamed(AppRoutes.notifications);
        onNotificationsOpened?.call();
        break;

      case _AvatarMenuAction.editProfile:
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
        );
        break;

      case _AvatarMenuAction.wallet:
        _snack(context, 'Wallet coming soon');
        break;

      case _AvatarMenuAction.plaques:
        _snack(context, 'Plaques coming soon');
        break;

      case _AvatarMenuAction.supportHistory:
        _snack(context, 'Support history coming soon');
        break;

      case _AvatarMenuAction.settings:
        _snack(context, 'Settings coming soon');
        break;

      case _AvatarMenuAction.admin:
        await Navigator.of(context).pushNamed(AppRoutes.admin);
        break;

      case _AvatarMenuAction.signOut:
        await _confirmSignOut(context);
        break;
    }
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Sign out',
              style: TextStyle(
                color: kUzinduziRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (ok == true) {
      await onSignOut();
    }
  }
}

enum _AvatarMenuAction {
  notifications,
  editProfile,
  wallet,
  plaques,
  supportHistory,
  settings,
  admin,
  signOut,
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    this.badge,
    this.trailing,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final Widget? badge;
  final String? trailing;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? kUzinduziRed : kUzinduziBlack;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
        
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: kUzinduziGrey,
              letterSpacing: 0.8,
            ),
          ),
      ],
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kUzinduziWhite, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _EmptyHero extends StatelessWidget {
  const _EmptyHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: kUzinduziWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kUzinduziDivider),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.podcasts, size: 40, color: kUzinduziGrey),
            SizedBox(height: 8),
            Text(
              'Nothing live right now',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: kUzinduziBlack,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Follow artists to get notified',
              style: TextStyle(color: kUzinduziGrey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}