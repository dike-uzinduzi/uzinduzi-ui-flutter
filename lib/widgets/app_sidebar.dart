import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../features/auth/auth_controller.dart';
import 'uzinduzi_logo.dart';

class AppSidebar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppSidebar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    (icon: Icons.album_outlined, activeIcon: Icons.album, label: 'Albums'),
    (icon: Icons.workspace_premium_outlined, activeIcon: Icons.workspace_premium, label: 'Plaques'),
    (icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;

    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: kUzinduziWhite,
        border: Border(right: BorderSide(color: kUzinduziDivider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Row(
              children: [
                const UzinduziLogo(
                  variant: LogoVariant.launchSymbol,
                  height: 28,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Uzinduzi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: kUzinduziBlack,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),

          // Nav items
          for (int i = 0; i < _items.length; i++)
            _SidebarItem(
              icon: _items[i].icon,
              activeIcon: _items[i].activeIcon,
              label: _items[i].label,
              selected: currentIndex == i,
              onTap: () => onTap(i),
            ),

          const Spacer(),

          const Divider(height: 1, color: kUzinduziDivider),

          // User block
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: kUzinduziRed.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, size: 18, color: kUzinduziRed),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.userName ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kUzinduziBlack,
                            ),
                          ),
                          Text(
                            user?.email ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: kUzinduziGrey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                  icon: const Icon(Icons.logout, size: 16, color: kUzinduziRed),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: kUzinduziRed,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    alignment: Alignment.centerLeft,
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

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? kUzinduziRed.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  selected ? activeIcon : icon,
                  size: 20,
                  color: selected ? kUzinduziRed : kUzinduziGrey,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? kUzinduziRed : kUzinduziBlack,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}