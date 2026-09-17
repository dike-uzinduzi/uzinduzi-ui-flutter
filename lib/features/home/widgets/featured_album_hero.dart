import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../albums/album_models.dart';
import 'launch_countdown.dart';

class FeaturedAlbumHero extends StatefulWidget {
  final Album? album;
  final bool loading;
  final String emptyTitle;
  final String emptySubtitle;
  final String ctaLabel;
  final VoidCallback? onSupport;

  const FeaturedAlbumHero({
    super.key,
    this.album,
    this.loading = false,
    this.emptyTitle = 'No featured release',
    this.emptySubtitle = 'Set a featured album to display it here.',
    this.ctaLabel = 'Support this album',
    this.onSupport,
  });

  @override
  State<FeaturedAlbumHero> createState() => _FeaturedAlbumHeroState();
}

class _FeaturedAlbumHeroState extends State<FeaturedAlbumHero> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.local_fire_department, size: 14, color: kUzinduziRed),
            SizedBox(width: 6),
            Text(
              'Featured release',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kUzinduziBlack,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.loading)
          const _HeroSkeleton()
        else if (widget.album == null)
          _HeroEmpty(
            title: widget.emptyTitle,
            subtitle: widget.emptySubtitle,
          )
        else
          _HeroLoaded(
            album: widget.album!,
            ctaLabel: widget.ctaLabel,
            onSupport: widget.onSupport,
            liveFor: _formatElapsed(widget.album!.releaseDate),
          ),
      ],
    );
  }

  String _formatElapsed(DateTime? start) {
    if (start == null) return '—';
    final ms = DateTime.now().difference(start).inMilliseconds.abs();
    final d = ms ~/ 86400000;
    final h = (ms % 86400000) ~/ 3600000;
    final m = (ms % 3600000) ~/ 60000;
    final s = (ms % 60000) ~/ 1000;
    if (d > 0) return '${d}d ${h}h ${m}m ${s}s';
    if (h > 0) return '${h}h ${m}m ${s}s';
    return '${m}m ${s}s';
  }
}

class _HeroLoaded extends StatelessWidget {
  const _HeroLoaded({
    required this.album,
    required this.ctaLabel,
    required this.liveFor,
    this.onSupport,
  });

  final Album album;
  final String ctaLabel;
  final String liveFor;
  final VoidCallback? onSupport;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kUzinduziDivider),
        boxShadow: [
          BoxShadow(
            color: kUzinduziBlack.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final coverSize =
                  (constraints.maxWidth * 0.32).clamp(120.0, 200.0);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: album.coverImage,
                          width: coverSize,
                          height: coverSize,
                          fit: BoxFit.cover,
                          memCacheWidth: (coverSize * 2).toInt(),
                          errorWidget: (_, _, _) => Container(
                            width: coverSize,
                            height: coverSize,
                            color: kUzinduziDivider,
                            child: Icon(
                              Icons.album,
                              color: kUzinduziGrey,
                              size: coverSize * 0.35,
                            ),
                          ),
                        ),
                      ),
                      if (album.isLive)
                        const Positioned(
                          top: 6,
                          left: 6,
                          child: _LiveBadge(),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (album.genres.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: album.genres
                                .take(3)
                                .map((g) => _GenreChip(g))
                                .toList(),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          album.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: kUzinduziBlack,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          album.artistName,
                          style: const TextStyle(
                            color: kUzinduziGrey,
                            fontSize: 13,
                          ),
                        ),
                        if (album.description != null &&
                            album.description!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            album.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: kUzinduziGrey,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          if (album.launch != null) ...[
            const SizedBox(height: 12),
            LaunchCountdown(launch: album.launch!, dark: false),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1, color: kUzinduziDivider),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  label: 'Live for',
                  value: liveFor,
                  valueColor: kUzinduziRed,
                  mono: true,
                ),
              ),
              Expanded(
                child: _Stat(
                  label: 'Tracks',
                  value: '${album.trackCount}',
                ),
              ),
              Expanded(
                child: _Stat(
                  label: 'Released',
                  value: album.releaseDateFormatted,
                ),
              ),
            ],
          ),
          if (onSupport != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: onSupport,
                icon: const Icon(Icons.favorite, size: 18),
                label: Text(
                  ctaLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kUzinduziRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
class _LiveBadge extends StatefulWidget {
  const _LiveBadge();
  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: kUzinduziRed,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: Tween(begin: 1.0, end: 0.4).animate(_c),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'LIVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: kUzinduziRed.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kUzinduziRed.withValues(alpha: 0.3)),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: kUzinduziRed,
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    this.valueColor,
    this.mono = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: kUzinduziGrey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: mono ? 11 : 13,
            fontWeight: FontWeight.w900,
            color: valueColor ?? kUzinduziBlack,
            fontFeatures: mono ? const [FontFeature.tabularFigures()] : null,
          ),
        ),
      ],
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kUzinduziDivider),
        boxShadow: [
          BoxShadow(
            color: kUzinduziBlack.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: kUzinduziRed.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}

class _HeroEmpty extends StatelessWidget {
  const _HeroEmpty({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kUzinduziDivider),
        boxShadow: [
          BoxShadow(
            color: kUzinduziBlack.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.album_outlined, size: 32, color: kUzinduziGrey),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: kUzinduziGrey),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: kUzinduziGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}