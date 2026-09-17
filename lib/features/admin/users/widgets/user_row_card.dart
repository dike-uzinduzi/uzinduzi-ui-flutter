import 'package:flutter/material.dart';

import '../../../../core/theme.dart';
import '../admin_user_model.dart';

class UserRowCard extends StatelessWidget {
  const UserRowCard({
    super.key,
    required this.user,
    this.onTap,
  });

  final AdminUserRow user;
  final VoidCallback? onTap;

  Color get _roleColor {
    switch (user.role) {
      case 'super_admin':
        return kUzinduziRed;
      case 'admin':
        return kTierCrimson;
      case 'artist':
        return kTierGold;
      case 'corporate':
        return kTierSapphire;
      default:
        return kUzinduziGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _roleColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                user.initials,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _roleColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.displayName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: kUzinduziBlack,
                          ),
                        ),
                      ),
                      if (user.isDemoAccount) ...[
                        const SizedBox(width: 6),
                        _Chip(label: 'DEMO', color: kUzinduziGrey),
                      ],
                      if (user.isSuspended) ...[
                        const SizedBox(width: 6),
                        _Chip(label: 'SUSPENDED', color: kUzinduziRed),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: kUzinduziGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _Chip(label: user.role.toUpperCase(), color: _roleColor),
            const SizedBox(width: 12),
            SizedBox(
              width: 90,
              child: Text(
                _lastSeenLabel(user.lastLoginAt),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 11,
                  color: kUzinduziGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _lastSeenLabel(DateTime? d) {
    if (d == null) return 'Never';
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
