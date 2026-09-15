import 'package:flutter/material.dart';

import '../core/theme.dart';

class TierBadge extends StatelessWidget {
  final String tier;
  final bool large;

  const TierBadge({super.key, required this.tier, this.large = false});

  @override
  Widget build(BuildContext context) {
    final color = tierColor(tier);
    final label = tier.toUpperCase();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 10,
        vertical: large ? 8 : 5,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: large ? 14 : 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
