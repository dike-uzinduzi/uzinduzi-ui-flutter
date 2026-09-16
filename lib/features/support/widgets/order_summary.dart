import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/config.dart';
import '../../../core/theme.dart';
import '../../albums/plaque_tier_models.dart';

class OrderSummary extends StatelessWidget {
  final String albumTitle;
  final String artistName;
  final String? coverArt;
  final PlaqueTier? tier;
  final double amount;

  const OrderSummary({
    super.key,
    required this.albumTitle,
    required this.artistName,
    this.coverArt,
    required this.tier,
    required this.amount,
  });

  String get _coverUrl {
    if (coverArt == null || coverArt!.isEmpty) return AppConfig.defaultAlbumCover;
    if (coverArt!.startsWith('http')) return coverArt!;
    return '${AppConfig.cdnBase}/$coverArt';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kUzinduziWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kUzinduziDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order summary',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: kUzinduziGrey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: _coverUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  memCacheWidth: 200,
                  errorWidget: (_, _, _) => Container(
                    width: 72,
                    height: 72,
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
                    Text(
                      albumTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kUzinduziBlack,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      artistName,
                      style: const TextStyle(fontSize: 13, color: kUzinduziGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: kUzinduziDivider),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tier',
                  style: TextStyle(fontSize: 13, color: kUzinduziGrey),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tier != null ? tierColor(tier!.slug) : kUzinduziGrey,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tier == null ? 'THANK YOU' : tier!.displayName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Amount',
                  style: TextStyle(fontSize: 13, color: kUzinduziGrey),
                ),
              ),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: kUzinduziBlack,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}