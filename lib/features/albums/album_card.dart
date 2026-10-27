import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/config.dart';
import '../../core/theme.dart';
import 'album_models.dart';

class AlbumCard extends StatelessWidget {
  final Album album;
  final VoidCallback onTap;

  const AlbumCard({super.key, required this.album, required this.onTap});

  String get _coverUrl {
    final raw = album.coverArt;
    if (raw == null || raw.isEmpty) return AppConfig.defaultAlbumCover;
    if (raw.startsWith('http')) return raw;
    return '${AppConfig.cdnBase}/$raw';
  }

  /// Always returns a label — defaults to UPCOMING when no launch
  /// or an unrecognised status is present.
  String _statusLabel(Album album) {
    final launch = album.launch;
    if (launch != null) {
      if (launch.isActive) return 'LIVE';
      if (launch.isScheduled) return 'UPCOMING';
      if (launch.isEnded) return 'ENDED';
    }
    return 'UPCOMING';
  }

  Color _statusColor(String label) => switch (label) {
        'LIVE' => kStatusLive,
        'UPCOMING' => kUzinduziRed,
        'ENDED' => kUzinduziGrey,
        _ => kUzinduziGrey,
      };

  @override
  Widget build(BuildContext context) {
    final status = _statusLabel(album);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover with status badge (always visible)
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: _coverUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 600,
                      errorWidget: (_, _, _) => Container(
                        color: kUzinduziDivider,
                        child: const Icon(
                          Icons.album,
                          color: kUzinduziGrey,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(status),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (status == 'LIVE') ...[
                          const Icon(
                            Icons.circle,
                            size: 6,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            album.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: kUzinduziBlack,
            ),
          ),
          Text(
            album.artist?.name ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: kUzinduziGrey),
          ),
        ],
      ),
    );
  }
}