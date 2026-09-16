import 'package:flutter/material.dart';

import '../../../core/theme.dart';

class SocialRow extends StatelessWidget {
  final int likeCount;
  final bool liked;
  final int viewCount;
  final bool busy;
  final VoidCallback onLike;
  final VoidCallback onShare;

  const SocialRow({
    super.key,
    required this.likeCount,
    required this.liked,
    required this.viewCount,
    required this.busy,
    required this.onLike,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionPill(
          icon: liked ? Icons.favorite : Icons.favorite_border,
          label: '$likeCount',
          active: liked,
          onTap: busy ? null : onLike,
        ),
        const SizedBox(width: 8),
        _ActionPill(
          icon: Icons.visibility_outlined,
          label: '$viewCount',
          active: false,
          onTap: null,
        ),
        const SizedBox(width: 8),
        _ActionPill(
          icon: Icons.ios_share,
          label: 'Share',
          active: false,
          onTap: onShare,
        ),
      ],
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _ActionPill({
    required this.icon,
    required this.label,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? kUzinduziRed : kUzinduziBlack;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? kUzinduziRed.withValues(alpha: 0.08) : kUzinduziWhite,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? kUzinduziRed.withValues(alpha: 0.3) : kUzinduziDivider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}