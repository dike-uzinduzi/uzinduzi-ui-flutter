import 'package:flutter/material.dart';

import '../../../core/theme.dart';

class AdminPlaceholder extends StatelessWidget {
  const AdminPlaceholder({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.construction, size: 48, color: kUzinduziGrey),
          const SizedBox(height: 12),
          Text(
            '$label — coming soon',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: kUzinduziGrey,
            ),
          ),
        ],
      ),
    );
  }
}
