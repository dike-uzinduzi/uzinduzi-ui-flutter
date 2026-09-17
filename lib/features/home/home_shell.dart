import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../widgets/app_sidebar.dart';
import '../albums/albums_tab.dart';
import '../plaques/plaques_tab.dart';
import '../profile/profile_tab.dart';
import 'home_tab.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _tabs = <Widget>[
    HomeTab(),
    AlbumsTab(),
    PlaquesTab(),
    ProfileTab(),
  ];

  static const _navItems = <_NavItem>[
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.album_outlined,
      activeIcon: Icons.album,
      label: 'Albums',
    ),
    _NavItem(
      icon: Icons.workspace_premium_outlined,
      activeIcon: Icons.workspace_premium,
      label: 'Plaques',
    ),
    _NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  static const _sidebarBreakpoint = 900.0;

  void _select(int i) {
    if (i == _index) return;
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useSidebar = constraints.maxWidth >= _sidebarBreakpoint;
        final body = IndexedStack(index: _index, children: _tabs);

        if (useSidebar) {
          return Scaffold(
            backgroundColor: kUzinduziWhite,
            body: Row(
              children: [
                AppSidebar(currentIndex: _index, onTap: _select),
                const VerticalDivider(width: 1, color: kUzinduziDivider),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: kUzinduziWhite,
          body: body,
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: kUzinduziDivider)),
              color: kUzinduziWhite,
            ),
            child: SafeArea(
              top: false,
              child: BottomNavigationBar(
                currentIndex: _index,
                onTap: _select,
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                backgroundColor: kUzinduziWhite,
                selectedItemColor: kUzinduziRed,
                unselectedItemColor: kUzinduziGrey,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                items: [
                  for (final item in _navItems)
                    BottomNavigationBarItem(
                      icon: Icon(item.icon),
                      activeIcon: Icon(item.activeIcon),
                      label: item.label,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}