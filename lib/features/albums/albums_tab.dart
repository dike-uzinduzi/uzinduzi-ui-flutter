import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import 'album_card.dart';
import 'album_detail_screen.dart';
import 'albums_provider.dart';

class AlbumsTab extends ConsumerWidget {
  const AlbumsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albums = ref.watch(albumsProvider);

    return Scaffold(
      backgroundColor: kUzinduziWhite,
      appBar: AppBar(
        title: const Text(
          'Albums',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        color: kUzinduziRed,
        onRefresh: () async => ref.invalidate(albumsProvider),
        child: albums.when(
          data: (list) {
            if (list.isEmpty) {
              return const _EmptyAlbums();
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 700 ? 3 : 2;
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final album = list[i];
                        return AlbumCard(
                          album: album,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AlbumDetailScreen(albumId: album.id),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: kUzinduziRed),
          ),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 40, color: kUzinduziGrey),
                  const SizedBox(height: 8),
                  Text('$e', textAlign: TextAlign.center,
                      style: const TextStyle(color: kUzinduziGrey, fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyAlbums extends StatelessWidget {
  const _EmptyAlbums();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.album_outlined, size: 56, color: kUzinduziGrey),
          SizedBox(height: 12),
          Text('No albums yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          SizedBox(height: 4),
          Text('Check back soon',
              style: TextStyle(fontSize: 13, color: kUzinduziGrey)),
        ],
      ),
    );
  }
}