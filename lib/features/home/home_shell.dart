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

  static const _tabs = [
    HomeTab(),
    AlbumsTab(),
    PlaquesTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final useSidebar = width >= 900;

    if (useSidebar) {
      return Scaffold(
        backgroundColor: kUzinduziWhite,
        body: Row(
          children: [
            AppSidebar(
              currentIndex: _index,
              onTap: (i) => setState(() => _index = i),
            ),
            Expanded(
              child: IndexedStack(index: _index, children: _tabs),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: kUzinduziDivider)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: kUzinduziWhite,
          selectedItemColor: kUzinduziRed,
          unselectedItemColor: kUzinduziGrey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.album_outlined),
              activeIcon: Icon(Icons.album),
              label: 'Albums',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.workspace_premium_outlined),
              activeIcon: Icon(Icons.workspace_premium),
              label: 'Plaques',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}