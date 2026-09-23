import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import 'admin_guard.dart';
import 'admin_routes.dart';
import 'albums/admin_albums_screen.dart';
import 'overview/admin_overview_screen.dart';
import 'users/admin_users_screen.dart';
import 'shared/admin_placeholder.dart';

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _index = 0;

  static const _sections = <_AdminSection>[
    _AdminSection(AdminRoutes.overview,   'Overview',   Icons.dashboard_outlined),
    _AdminSection(AdminRoutes.users,      'Users',      Icons.people_outline),
    _AdminSection(AdminRoutes.artists,    'Artists',    Icons.mic_none),
    _AdminSection(AdminRoutes.albums,     'Albums',     Icons.album_outlined),
    _AdminSection(AdminRoutes.launches,   'Launches',   Icons.rocket_launch_outlined),
    _AdminSection(AdminRoutes.payments,   'Payments',   Icons.payments_outlined),
    _AdminSection(AdminRoutes.plaques,    'Plaques',    Icons.workspace_premium_outlined),
    _AdminSection(AdminRoutes.news,       'News',       Icons.newspaper_outlined),
    _AdminSection(AdminRoutes.moderation, 'Moderation', Icons.flag_outlined),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ensureAdmin(context, ref);
    });
  }

  Widget _body() {
    switch (_sections[_index].path) {
      case AdminRoutes.overview:
        return const AdminOverviewScreen();
      case AdminRoutes.users:
        return const AdminUsersScreen();
      case AdminRoutes.albums:
        return const AdminAlbumsScreen();
      default:
        return AdminPlaceholder(label: _sections[_index].label);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Admin is desktop-only. The route is guarded by `AdminDesktopOnly`
    // in app.dart, which blocks viewports narrower than 1024px. So by the
    // time we get here, we always render the wide layout.
    return Scaffold(
      backgroundColor: kUzinduziWhite,
      body: Row(
        children: [
          _AdminSidebar(
            sections: _sections,
            selectedIndex: _index,
            onTap: (i) => setState(() => _index = i),
          ),
          const VerticalDivider(width: 1, color: kUzinduziDivider),
          Expanded(child: _body()),
        ],
      ),
    );
  }
}

class _AdminSection {
  final String path;
  final String label;
  final IconData icon;
  const _AdminSection(this.path, this.label, this.icon);
}

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar({
    required this.sections,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<_AdminSection> sections;
  final int selectedIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: kUzinduziWhite,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                'UZINDUZI',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: kUzinduziBlack,
                  letterSpacing: 2,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Text(
                'ADMIN',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: kUzinduziRed,
                  letterSpacing: 3,
                ),
              ),
            ),
            const Divider(height: 1, color: kUzinduziDivider),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: sections.length,
                itemBuilder: (context, i) {
                  final s = sections[i];
                  final selected = i == selectedIndex;
                  return InkWell(
                    onTap: () => onTap(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      color: selected
                          ? kUzinduziRed.withValues(alpha: 0.08)
                          : Colors.transparent,
                      child: Row(
                        children: [
                          Icon(
                            s.icon,
                            size: 18,
                            color: selected ? kUzinduziRed : kUzinduziGrey,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            s.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w500,
                              color:
                                  selected ? kUzinduziRed : kUzinduziBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1, color: kUzinduziDivider),
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Exit admin'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kUzinduziBlack,
                  side: const BorderSide(color: kUzinduziDivider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}