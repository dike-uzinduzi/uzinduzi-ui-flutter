import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme.dart';
import 'album_detail_provider.dart';
import 'album_models.dart';
import 'plaque_tier_models.dart';
import 'tiers_provider.dart';
import 'widgets/album_info_pane.dart';
import 'widgets/support_slider_block.dart';
import 'widgets/tier_preview.dart';
import 'widgets/track_carousel_pane.dart';

class AlbumDetailScreen extends ConsumerStatefulWidget {
  final String albumId;
  const AlbumDetailScreen({super.key, required this.albumId});

  @override
  ConsumerState<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends ConsumerState<AlbumDetailScreen> {
  bool _socialBusy = false;
  int _likeCount = 0;
  bool _liked = false;
  final int _viewCount = 0;
  final Set<String> _likedTrackIds = {};
  final Map<String, int> _trackLikeCounts = {};

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
     
      ref.invalidate(tiersProvider);
      
    });
    
  }

  Future<void> _toggleAlbumLike() async {
    if (_socialBusy) return;
    setState(() => _socialBusy = true);
    try {
      setState(() {
        _liked = !_liked;
        _likeCount += _liked ? 1 : -1;
      });
    } finally {
      if (mounted) setState(() => _socialBusy = false);
    }
  }

  Future<void> _share() async {
    final album = ref.read(albumDetailProvider(widget.albumId)).valueOrNull;
    final url = 'https://app.uzinduziafrica.com/album/${widget.albumId}';
    final text = album != null
        ? '${album.title} by ${album.artist?.name ?? "an artist"} on Uzinduzi — $url'
        : url;
    await Share.share(text, subject: album?.title);
  }

  Future<void> _toggleTrackLike(String trackId) async {
    setState(() {
      final liked = _likedTrackIds.contains(trackId);
      if (liked) {
        _likedTrackIds.remove(trackId);
        _trackLikeCounts[trackId] = (_trackLikeCounts[trackId] ?? 1) - 1;
      } else {
        _likedTrackIds.add(trackId);
        _trackLikeCounts[trackId] = (_trackLikeCounts[trackId] ?? 0) + 1;
      }
    });
  }

  void _onSupport(Album album, PlaqueTier? tier, double amount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Checkout for \$${amount.toStringAsFixed(0)} — coming in M2c',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(albumDetailProvider(widget.albumId));

    return Scaffold(
      backgroundColor: kUzinduziWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: detail.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: kUzinduziRed),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              '$e',
              textAlign: TextAlign.center,
              style: const TextStyle(color: kUzinduziGrey),
            ),
          ),
        ),
        data: (album) => LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1100;

            if (!wide) {
              return _MobileLayout(
                album: album,
                liked: _liked,
                likeCount: _likeCount,
                viewCount: _viewCount,
                socialBusy: _socialBusy,
                onLike: _toggleAlbumLike,
                onShare: _share,
                likedTrackIds: _likedTrackIds,
                trackLikeCounts: _trackLikeCounts,
                onToggleTrackLike: _toggleTrackLike,
                onSupport: (tier, amount) => _onSupport(album, tier, amount),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 320,
                        child: SingleChildScrollView(
                          child: AlbumInfoPane(
                            album: album,
                            likeCount: _likeCount,
                            liked: _liked,
                            viewCount: _viewCount,
                            socialBusy: _socialBusy,
                            onLike: _toggleAlbumLike,
                            onShare: _share,
                            onFollow: null,
                          ),
                        ),
                      ),
                      const VerticalDivider(width: 1, color: kUzinduziDivider),
                      Expanded(
                        child: SingleChildScrollView(
                          child: TrackCarouselPane(
                            album: album,
                            likedTrackIds: _likedTrackIds,
                            trackLikeCounts: _trackLikeCounts,
                            onToggleLike: _toggleTrackLike,
                          ),
                        ),
                      ),
                      const VerticalDivider(width: 1, color: kUzinduziDivider),
                      SizedBox(
                        width: 380,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Consumer(
                              builder: (context, ref, _) {
                                final tier = ref.watch(
                                  
                                  selectedTierProvider(widget.albumId),
                                );
                                debugPrint('TIER PREVIEW BUILD: tier=${tier?.slug}');
                                return TierPreview(tier: tier);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SupportSliderBlock(
                  albumId: widget.albumId,
                  onSupport: () {
                    final amount =
                        ref.read(selectedAmountProvider(widget.albumId));
                    final tier =
                        ref.read(selectedTierProvider(widget.albumId));
                    _onSupport(album, tier, amount);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MobileLayout extends ConsumerWidget {
  final Album album;
  final bool liked;
  final int likeCount;
  final int viewCount;
  final bool socialBusy;
  final VoidCallback onLike;
  final VoidCallback onShare;
  final Set<String> likedTrackIds;
  final Map<String, int> trackLikeCounts;
  final void Function(String) onToggleTrackLike;
  final void Function(PlaqueTier?, double) onSupport;

  const _MobileLayout({
    required this.album,
    required this.liked,
    required this.likeCount,
    required this.viewCount,
    required this.socialBusy,
    required this.onLike,
    required this.onShare,
    required this.likedTrackIds,
    required this.trackLikeCounts,
    required this.onToggleTrackLike,
    required this.onSupport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(selectedTierProvider(album.id));
    final amount = ref.watch(selectedAmountProvider(album.id));

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              AlbumInfoPane(
                album: album,
                likeCount: likeCount,
                liked: liked,
                viewCount: viewCount,
                socialBusy: socialBusy,
                onLike: onLike,
                onShare: onShare,
                onFollow: null,
              ),
              const Divider(height: 1, color: kUzinduziDivider),
              Padding(
                padding: const EdgeInsets.all(20),
                child: TierPreview(tier: tier),
              ),
              const Divider(height: 1, color: kUzinduziDivider),
              TrackCarouselPane(
                album: album,
                likedTrackIds: likedTrackIds,
                trackLikeCounts: trackLikeCounts,
                onToggleLike: onToggleTrackLike,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        SupportSliderBlock(
          albumId: album.id,
          onSupport: () => onSupport(tier, amount),
        ),
      ],
    );
  }
}