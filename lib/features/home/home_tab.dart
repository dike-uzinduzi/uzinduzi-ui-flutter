import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../albums/album_detail_screen.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../widgets/badge_dot.dart';
import './widgets/home_tile.dart';
import '../../widgets/uzinduzi_logo.dart';
import '../auth/auth_controller.dart';
import '../albums/albums_provider.dart';
import '../notifications/notifications_provider.dart';
import 'home_providers.dart';
import 'widgets/featured_album_hero.dart';
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
        title: const UzinduziLogo(variant: LogoVariant.launchSymbol, height: 28),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: BadgeDot(
              count: unread.valueOrNull ?? 0,
              child: IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () async {
                  await Navigator.of(context).pushNamed(AppRoutes.notifications);
                  ref.invalidate(unreadNotificationsProvider);
                  ref.invalidate(notificationsFeedProvider);
                },
              ),
            ),
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
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Text(
                  'Welcome back, ${user?.userName ?? "there"} 👋',
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
                    if (album == null) {
                      return const _EmptyHero();
                    }
                    return Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: FeaturedAlbumHero(
                            album: album,
                           onSupport: () {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => AlbumDetailScreen(albumId: album.id),
    ),
  );
},
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: CircularProgressIndicator(color: kUzinduziRed),
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
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.2,
                  children: [
                    HomeTile(
                      icon: Icons.album_outlined,
                      label: 'Albums',
                      badgeCount: albums.maybeWhen(
                        data: (a) => a.length,
                        orElse: () => null,
                      ),
                      onTap: () {},
                    ),
                    HomeTile(
                      icon: Icons.podcasts,
                      label: 'Live Now',
                      accent: kStatusLive,
                      badgeCount: liveCount.maybeWhen(
                        data: (c) => c,
                        orElse: () => null,
                      ),
                      onTap: () {},
                    ),
                    HomeTile(
                      icon: Icons.workspace_premium_outlined,
                      label: 'My Plaques',
                      accent: kTierGold,
                      badgeCount: stats.maybeWhen(
                        data: (s) => s.totalPlaques,
                        orElse: () => null,
                      ),
                      onTap: () {},
                    ),
                    HomeTile(
                      icon: Icons.newspaper_outlined,
                      label: 'News',
                      accent: kTierSapphire,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
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
              style: TextStyle(fontWeight: FontWeight.w700, color: kUzinduziBlack),
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