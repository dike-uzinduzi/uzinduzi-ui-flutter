import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme.dart';
import '../admin_tier_model.dart';

class TierRowCard extends StatelessWidget {
  final AdminTier tier;
  final int index;
  final VoidCallback onTap;

  const TierRowCard({
    super.key,
    required this.tier,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: kUzinduziWhite,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kUzinduziDivider),
            ),
            child: Row(
              children: [
                // Drag handle
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.drag_indicator,
                      size: 20,
                      color: kUzinduziGrey,
                    ),
                  ),
                ),

                // Image thumb
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: tier.imageUrl != null && tier.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: tier.imageUrl!,
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
                const SizedBox(width: 12),

                // Text block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: kUzinduziRed.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tier.slug,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: kUzinduziRed,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!tier.isActive)
                            const Text(
                              'INACTIVE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: kUzinduziGrey,
                                letterSpacing: 0.6,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tier.displayName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kUzinduziBlack,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${tier.minAmount.toStringAsFixed(0)}'
                        '${tier.freeShowDays != null ? '  ·  ${tier.freeShowDays} free show days' : ''}'
                        '  ·  ${tier.benefits.length} benefit${tier.benefits.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: kUzinduziGrey,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right,
                  color: kUzinduziGrey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}