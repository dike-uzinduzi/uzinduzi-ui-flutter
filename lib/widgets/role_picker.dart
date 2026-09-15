import 'package:flutter/material.dart';

import '../core/theme.dart';

class RoleOption {
  final String slug;
  final String label;
  final IconData icon;

  const RoleOption({required this.slug, required this.label, required this.icon});
}

const kSelfAssignableRoles = <RoleOption>[
  RoleOption(slug: 'fan',            label: 'Fan',            icon: Icons.favorite_outline),
  RoleOption(slug: 'artist',         label: 'Artist',         icon: Icons.mic_none),
  RoleOption(slug: 'producer',       label: 'Producer',       icon: Icons.tune),
  RoleOption(slug: 'artist_manager', label: 'Artist Manager', icon: Icons.work_outline),
  RoleOption(slug: 'promoter',       label: 'Promoter',       icon: Icons.campaign_outlined),
];

class RolePicker extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const RolePicker({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kSelfAssignableRoles.map((role) {
        final selected = value == role.slug;
        return GestureDetector(
          onTap: () => onChanged(role.slug),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? kUzinduziRed : kUzinduziWhite,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected ? kUzinduziRed : kUzinduziDivider,
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  role.icon,
                  size: 16,
                  color: selected ? kUzinduziWhite : kUzinduziBlack,
                ),
                const SizedBox(width: 6),
                Text(
                  role.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? kUzinduziWhite : kUzinduziBlack,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}