import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/config.dart';
import '../../core/theme.dart';
import 'album_models.dart';

class AlbumDetailStub extends StatelessWidget {
  final Album album;
  const AlbumDetailStub({super.key, required this.album});

  String get _coverUrl {
    final raw = album.coverArt;
    if (raw == null || raw.isEmpty) return AppConfig.defaultAlbumCover;
    if (raw.startsWith('http')) return raw;
    return '${AppConfig.cdnBase}/$raw';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kUzinduziWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: _coverUrl,
                    width: 220,
                    height: 220,
                    fit: BoxFit.cover,
                    memCacheWidth: 600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                album.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: kUzinduziBlack,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                album.artist?.name ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: kUzinduziGrey),
              ),
              const SizedBox(height: 32),
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.construction, size: 40, color: kUzinduziGrey),
                    SizedBox(height: 8),
                    Text(
                      'Full album detail — next milestone',
                      style: TextStyle(fontSize: 14, color: kUzinduziGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}