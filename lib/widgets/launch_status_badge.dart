import 'package:flutter/material.dart';

import '../core/theme.dart';

class LaunchStatusBadge extends StatelessWidget {
  /// "active" | "scheduled" | "ended" | "cancelled"
  final String? status;

  const LaunchStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == null) return const SizedBox.shrink();

    late final Color color;
    late final String label;

    switch (status!.toLowerCase()) {
      case 'active':
        color = kStatusLive;
        label = 'LIVE';
        break;
      case 'scheduled':
        color = kStatusScheduled;
        label = 'SOON';
        break;
      case 'ended':
        color = kStatusEnded;
        label = 'ENDED';
        break;
      case 'cancelled':
        color = kStatusFailed;
        label = 'CANCELLED';
        break;
      default:
        color = kUzinduziGrey;
        label = status!.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status!.toLowerCase() == 'active') ...[
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
