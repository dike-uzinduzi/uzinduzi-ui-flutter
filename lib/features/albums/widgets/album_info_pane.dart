import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/config.dart';
import '../../../core/theme.dart';
import '../../home/widgets/launch_countdown.dart';
import '../album_models.dart';
import 'social_row.dart';

class AlbumInfoPane extends StatelessWidget {
  final Album album;
  final int likeCount;
  final bool liked;
  final int viewCount;
  final bool socialBusy;
  final VoidCallback onLike;
  final VoidCallback onShare;
  final VoidCallback? onFollow;

  const AlbumInfoPane({
    super.key,
    required this.album,
    required this.likeCount,
    required this.liked,
    required this.viewCount,
    required this.socialBusy,
    required this.onLike,
    required this.onShare,
    this.onFollow,
  });

  String get _coverUrl {
    final raw = album.coverArt;
    if (raw == null || raw.isEmpty) return AppConfig.defaultAlbumCover;
    if (raw.startsWith('http')) return raw;
    return '${AppConfig.cdnBase}/$raw';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: _coverUrl,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              memCacheWidth: 600,
              errorWidget: (_, _, _) => Container(
                height: 220,
                color: kUzinduziDivider,
                child: const Icon(Icons.album, size: 64, color: kUzinduziGrey),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            album.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: kUzinduziBlack,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  album.artist?.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, color: kUzinduziGrey),
                ),
              ),
              if (onFollow != null)
                TextButton(
                  onPressed: onFollow,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text(
                    'Follow',
                    style: TextStyle(
                      color: kUzinduziRed,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _MetadataRow(
            items: [
              if (album.trackCount > 0) '${album.trackCount} tracks',
              if (album.duration > 0) _formatDuration(album.duration),
              if (album.genre != null && album.genre!.isNotEmpty) album.genre!,
            ],
          ),
          if (album.launch != null) ...[
            const SizedBox(height: 16),
            LaunchCountdown(launch: album.launch!),
          ],
          const SizedBox(height: 20),
          SocialRow(
            likeCount: likeCount,
            liked: liked,
            viewCount: viewCount,
            busy: socialBusy,
            onLike: onLike,
            onShare: onShare,
          ),
          if (album.description != null && album.description!.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(color: kUzinduziDivider),
            const SizedBox(height: 16),
            const Text(
              'About',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: kUzinduziGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              album.description!,
              style: const TextStyle(fontSize: 14, color: kUzinduziBlack, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}

class _MetadataRow extends StatelessWidget {
  final List<String> items;

  const _MetadataRow({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final joined = items.join('  ·  ');
    return Text(
      joined,
      style: const TextStyle(fontSize: 13, color: kUzinduziGrey, height: 1.5),
    );
  }
}