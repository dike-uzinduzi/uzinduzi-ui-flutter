import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme.dart';
import '../admin_artist_model.dart';

class ArtistRowCard extends StatelessWidget {
  final AdminArtist artist;
  final VoidCallback onTap;

  const ArtistRowCard({
    super.key,
    required this.artist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kUzinduziWhite,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: artist.profilePictureUrl != null &&
                          artist.profilePictureUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: artist.profilePictureUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => Container(
                            color: kUzinduziDivider,
                            child: const Icon(
                              Icons.person,
                              color: kUzinduziGrey,
                            ),
                          ),
                        )
                      : Container(
                          color: kUzinduziDivider,
                          child: const Icon(
                            Icons.person,
                            color: kUzinduziGrey,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            artist.stageName.isEmpty
                                ? '(no stage name)'
                                : artist.stageName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: kUzinduziBlack,
                            ),
                          ),
                        ),
                        if (artist.canCreateAlbums) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: kUzinduziRed.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'CAN PUBLISH',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: kUzinduziRed,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (_realName(artist) != null)
                      Text(
                        _realName(artist)!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: kUzinduziGrey,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: kUzinduziGrey),
            ],
          ),
        ),
      ),
    );
  }

  String? _realName(AdminArtist a) {
    final parts = [a.firstName, a.lastName]
        .where((s) => s != null && s.trim().isNotEmpty)
        .map((s) => s!.trim())
        .toList();
    return parts.isEmpty ? null : parts.join(' ');
  }
}