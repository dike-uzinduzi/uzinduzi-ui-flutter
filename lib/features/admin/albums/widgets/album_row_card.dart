import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme.dart';
import '../admin_album_model.dart';

class AlbumRowCard extends StatelessWidget {
  const AlbumRowCard({
    super.key,
    required this.album,
    this.onTap,
  });

  final AdminAlbumRow album;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: album.coverArt ?? '',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => Container(
                  width: 48,
                  height: 48,
                  color: kUzinduziDivider,
                  child: const Icon(Icons.album, color: kUzinduziGrey),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          album.title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: kUzinduziBlack,
                          ),
                        ),
                      ),
                      if (album.isFeatured) ...[
                        const SizedBox(width: 6),
                        const _Chip(label: 'FEATURED', color: kTierGold),
                      ],
                      if (album.isDeleted) ...[
                        const SizedBox(width: 6),
                        const _Chip(label: 'DELETED', color: kUzinduziRed),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${album.artistName} · ${album.trackCount} tracks · ${album.durationLabel}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: kUzinduziGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _Chip(
              label: album.isPublished ? 'PUBLISHED' : 'DRAFT',
              color: album.isPublished ? kStatusLive : kUzinduziGrey,
            ),
            const SizedBox(width: 8),
            _Chip(
              label: album.albumType.toUpperCase(),
              color: kTierSapphire,
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
