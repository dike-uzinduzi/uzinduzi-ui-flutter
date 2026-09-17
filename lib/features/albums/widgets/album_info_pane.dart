import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
              imageUrl: album.coverImage,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              memCacheWidth: 600,
              errorWidget: (_, _, _) => Container(
                height: 220,
                color: kUzinduziDivider,
                child: const Icon(
                  Icons.album,
                  size: 64,
                  color: kUzinduziGrey,
                ),
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
                  album.artistName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    color: kUzinduziGrey,
                  ),
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
          const SizedBox(height: 12),

          // ── Type chip + metadata line ───────────────
          _MetadataRow(
            items: [
              album.albumTypeLabel, // "Album" / "EP" / "Single"
              if (album.trackCount > 0) '${album.trackCount} tracks',
              if (album.duration > 0) album.durationLabel,
              if (album.genres.isNotEmpty) album.genres.join(' · '),
            ],
          ),

          // ── Release info ────────────────────────────
          const SizedBox(height: 8),
          _InfoLine(
            icon: Icons.event_outlined,
            text: 'Released ${album.releaseDateFormatted}',
          ),
          if (album.viewCount > 0)
            _InfoLine(
              icon: Icons.visibility_outlined,
              text: _formatViews(album.viewCount),
            ),

          // ── Launch countdown ────────────────────────
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

          // ── About ───────────────────────────────────
          if (album.description != null && album.description!.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(color: kUzinduziDivider),
            const SizedBox(height: 16),
            const _SectionTitle('About'),
            const SizedBox(height: 8),
            Text(
              album.description!,
              style: const TextStyle(
                fontSize: 14,
                color: kUzinduziBlack,
                height: 1.5,
              ),
            ),
          ],

          // ── Credits & rights ────────────────────────
          if (_hasCredits) ...[
            const SizedBox(height: 24),
            const Divider(color: kUzinduziDivider),
            const SizedBox(height: 16),
            const _SectionTitle('Credits & rights'),
            const SizedBox(height: 8),
            if (album.publisher != null && album.publisher!.isNotEmpty)
              _KeyValueRow(label: 'Publisher', value: album.publisher!),
            if (album.affiliation != null && album.affiliation!.isNotEmpty)
              _KeyValueRow(label: 'Affiliation', value: album.affiliation!),
            if (album.copyrightInfo != null &&
                album.copyrightInfo!.isNotEmpty)
              _KeyValueRow(label: 'Copyright', value: album.copyrightInfo!),
            if (album.credits != null && album.credits!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                album.credits!,
                style: const TextStyle(
                  fontSize: 13,
                  color: kUzinduziGrey,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  bool get _hasCredits =>
      (album.publisher?.isNotEmpty ?? false) ||
      (album.affiliation?.isNotEmpty ?? false) ||
      (album.copyrightInfo?.isNotEmpty ?? false) ||
      (album.credits?.isNotEmpty ?? false);

  static String _formatViews(int views) {
    if (views >= 1000000) return '${(views / 1000000).toStringAsFixed(1)}M views';
    if (views >= 1000) return '${(views / 1000).toStringAsFixed(1)}K views';
    return '$views views';
  }
}

class _MetadataRow extends StatelessWidget {
  final List<String> items;

  const _MetadataRow({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Text(
      items.join('  ·  '),
      style: const TextStyle(
        fontSize: 13,
        color: kUzinduziGrey,
        height: 1.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: kUzinduziGrey),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: kUzinduziGrey,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: kUzinduziGrey,
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kUzinduziGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: kUzinduziBlack,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}