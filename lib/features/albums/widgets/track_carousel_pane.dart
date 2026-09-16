import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/config.dart';
import '../../../core/theme.dart';
import '../album_models.dart';

class TrackCarouselPane extends StatefulWidget {
  final Album album;
  final Set<String> likedTrackIds;
  final Map<String, int> trackLikeCounts;
  final void Function(String trackId) onToggleLike;

  const TrackCarouselPane({
    super.key,
    required this.album,
    required this.likedTrackIds,
    required this.trackLikeCounts,
    required this.onToggleLike,
  });

  @override
  State<TrackCarouselPane> createState() => _TrackCarouselPaneState();
}

class _TrackCarouselPaneState extends State<TrackCarouselPane> {
  int _index = 0;

  List<Track> get _tracks {
    final t = widget.album.tracks ?? [];
    final sorted = [...t]..sort((a, b) => a.trackNumber.compareTo(b.trackNumber));
    return sorted;
  }

  void _prev() {
    if (_index > 0) setState(() => _index--);
  }

  void _next() {
    if (_index < _tracks.length - 1) setState(() => _index++);
  }

  String _artUrl(Track t) {
    final raw = (t as dynamic).trackArt as String?;
    if (raw != null && raw.isNotEmpty) {
      if (raw.startsWith('http')) return raw;
      return '${AppConfig.cdnBase}/$raw';
    }
    final cover = widget.album.coverArt;
    if (cover == null || cover.isEmpty) return AppConfig.defaultAlbumCover;
    if (cover.startsWith('http')) return cover;
    return '${AppConfig.cdnBase}/$cover';
  }

  @override
  Widget build(BuildContext context) {
    final tracks = _tracks;
    if (tracks.isEmpty) {
      return const Center(
        child: Text(
          'No tracks available',
          style: TextStyle(color: kUzinduziGrey),
        ),
      );
    }

    final track = tracks[_index];
    final liked = widget.likedTrackIds.contains(track.id);
    final likeCount = widget.trackLikeCounts[track.id] ?? track.likeCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _index > 0 ? _prev : null,
                icon: const Icon(Icons.chevron_left),
                color: _index > 0 ? kUzinduziBlack : kUzinduziGrey,
              ),
              Text(
                'Track ${_index + 1} of ${tracks.length}  ·  ${track.formattedDuration}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kUzinduziGrey,
                  letterSpacing: 0.2,
                ),
              ),
              IconButton(
                onPressed: _index < tracks.length - 1 ? _next : null,
                icon: const Icon(Icons.chevron_right),
                color: _index < tracks.length - 1 ? kUzinduziBlack : kUzinduziGrey,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: _artUrl(track),
              width: 280,
              height: 280,
              fit: BoxFit.cover,
              memCacheWidth: 600,
              errorWidget: (_, _, _) => Container(
                width: 280,
                height: 280,
                color: kUzinduziDivider,
                child: const Icon(Icons.music_note, size: 64, color: kUzinduziGrey),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            track.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: kUzinduziBlack,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => widget.onToggleLike(track.id),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: liked ? kUzinduziRed.withValues(alpha: 0.08) : kUzinduziWhite,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: liked ? kUzinduziRed.withValues(alpha: 0.3) : kUzinduziDivider,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    liked ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: liked ? kUzinduziRed : kUzinduziBlack,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$likeCount',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: liked ? kUzinduziRed : kUzinduziBlack,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (track.trackDescription != null && track.trackDescription!.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(color: kUzinduziDivider),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'About this track',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: kUzinduziGrey,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                track.trackDescription!,
                style: const TextStyle(fontSize: 14, color: kUzinduziBlack, height: 1.5),
              ),
            ),
          ],
          const SizedBox(height: 24),
          _AttributeList(track: track),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(tracks.length, (i) {
              final active = i == _index;
              return GestureDetector(
                onTap: () => setState(() => _index = i),
                child: Container(
                  width: active ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: active ? kUzinduziRed : kUzinduziDivider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _AttributeList extends StatelessWidget {
  final Track track;
  const _AttributeList({required this.track});

  @override
  Widget build(BuildContext context) {
    final t = track as dynamic;
    final rows = <MapEntry<String, String>>[];

    void add(String label, dynamic value) {
      if (value == null) return;
      final s = value.toString().trim();
      if (s.isEmpty) return;
      rows.add(MapEntry(label, s));
    }

    add('Featured', t.featuredArtists);
    add('Written by', t.writer);
    add('Performed by', t.performedBy);
    add('Backing vocals', t.backingVocals);
    add('Instruments', t.instrumentation);
    add('Produced by', t.producer);
    add('Mixing', t.mixingEngineer);
    add('Mastering', t.masteringEngineer);
    add('Special credits', t.specialCredits);

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: kUzinduziDivider),
        const SizedBox(height: 16),
        ...rows.map((r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      r.key,
                      style: const TextStyle(fontSize: 12, color: kUzinduziGrey),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      r.value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kUzinduziBlack,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}