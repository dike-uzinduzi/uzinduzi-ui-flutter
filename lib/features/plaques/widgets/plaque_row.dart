import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/config.dart';
import '../../../core/theme.dart';
import '../plaque_models.dart';

class PlaqueRow extends StatelessWidget {
  final UserPlaque plaque;
  const PlaqueRow({super.key, required this.plaque});

  String get _imageUrl {
    final raw = plaque.plaqueImageUrl;
    if (raw == null || raw.isEmpty) return '';
    if (raw.startsWith('http')) return raw;
    return '${AppConfig.cdnBase}/$raw';
  }

  Color get _tierColor => tierColor(plaque.plaqueType);

  String _statusLabel() {
    switch (plaque.status) {
      case 'PAID':
        return 'Paid';
      case 'ISSUED':
        return 'Issued';
      case 'IN_PRODUCTION':
        return 'In production';
      case 'READY_FOR_DELIVERY':
        return 'Ready for delivery';
      case 'DELIVERED':
        return 'Delivered';
      case 'COLLECTED':
        return 'Collected';
      case 'PENDING_PAYMENT':
        return 'Pending payment';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return plaque.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kUzinduziWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kUzinduziDivider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plaque image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 72,
              height: 72,
              color: _tierColor.withValues(alpha: 0.1),
              child: _imageUrl.isEmpty
                  ? Icon(Icons.workspace_premium, color: _tierColor, size: 32)
                  : CachedNetworkImage(
                      imageUrl: _imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) =>
                          Icon(Icons.workspace_premium, color: _tierColor, size: 32),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tier chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _tierColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    plaque.plaqueType.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  plaque.album?.title ?? 'General support',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kUzinduziBlack,
                  ),
                ),
                if (plaque.artist != null)
                  Text(
                    plaque.artist!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: kUzinduziGrey),
                  ),
                const SizedBox(height: 4),
                Text(
                  plaque.serialNumber,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: kUzinduziGrey,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _statusLabel(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: kUzinduziGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}