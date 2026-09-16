import 'package:flutter/material.dart';

import '../../../core/theme.dart';

class HomeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int? badgeCount;
  final Color? accent;

  const HomeTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badgeCount,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final c = accent ?? kUzinduziRed;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kUzinduziWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kUzinduziDivider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 24, color: c),
                if (badgeCount != null && badgeCount! > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: kUzinduziRed,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kUzinduziBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}