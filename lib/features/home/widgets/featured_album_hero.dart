import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/config.dart';
import '../../../core/theme.dart';
import '../../albums/album_models.dart';
import 'launch_countdown.dart';

class FeaturedAlbumHero extends StatelessWidget {
  final Album album;
  final VoidCallback? onSupport;

  const FeaturedAlbumHero({super.key, required this.album, this.onSupport});

  String get _coverUrl {
    final raw = album.coverArt;
    if (raw == null || raw.isEmpty) return AppConfig.defaultAlbumCover;
    if (raw.startsWith('http')) return raw;
    return '${AppConfig.cdnBase}/$raw';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kUzinduziBlack,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kUzinduziBlack.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: _coverUrl,
              fit: BoxFit.cover,
              memCacheWidth: 800,
              errorWidget: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: _coverUrl,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    memCacheWidth: 200,
                    errorWidget: (_, _, _) => Container(
                      width: 96,
                      height: 96,
                      color: kUzinduziRed.withValues(alpha: 0.3),
                      child: const Icon(Icons.album, color: Colors.white54),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'FEATURED',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        album.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        album.artist?.name ?? '',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      if (album.launch != null) ...[
                        const SizedBox(height: 10),
                        LaunchCountdown(launch: album.launch!, dark: true),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (onSupport != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: onSupport,
                  icon: const Icon(Icons.favorite, size: 18),
                  label: const Text(
                    'Support this album',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kUzinduziRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}