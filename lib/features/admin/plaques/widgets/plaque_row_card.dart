import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme.dart';
import '../admin_plaque_model.dart';

class PlaqueRowCard extends StatelessWidget {
  final AdminPlaque plaque;
  final VoidCallback onTap;

  const PlaqueRowCard({
    super.key,
    required this.plaque,
    required this.onTap,
  });

  Color get _statusColor => switch (plaque.status) {
        'PENDING_PAYMENT' => kUzinduziGrey,
        'PAID' => kUzinduziRed,
        'ISSUED' => kUzinduziRed,
        'IN_PRODUCTION' => kUzinduziRed,
        'READY_FOR_DELIVERY' => kUzinduziBlack,
        'DELIVERED' => kStatusLive,
        'COLLECTED' => kStatusLive,
        'CANCELLED' => kUzinduziGrey,
        _ => kUzinduziGrey,
      };

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
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: plaque.plaqueImageUrl != null &&
                          plaque.plaqueImageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: plaque.plaqueImageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => Container(
                            color: kUzinduziDivider,
                            child: const Icon(
                              Icons.workspace_premium,
                              color: kUzinduziGrey,
                            ),
                          ),
                        )
                      : Container(
                          color: kUzinduziDivider,
                          child: const Icon(
                            Icons.workspace_premium,
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: kUzinduziRed.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            plaque.plaqueType,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: kUzinduziRed,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            plaque.serialNumber,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: kUzinduziBlack,
                              fontFeatures: [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                        if (plaque.isDemo) ...[
                          const SizedBox(width: 8),
                          const Text(
                            'DEMO',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: kUzinduziGrey,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      plaque.ownerName ?? 'Unknown owner',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: kUzinduziBlack,
                      ),
                    ),
                    Text(
                      plaque.albumTitle ?? '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: kUzinduziGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      plaqueStatusLabel(plaque.status).toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: _statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${plaque.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: kUzinduziBlack,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}