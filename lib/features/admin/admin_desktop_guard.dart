import 'package:flutter/material.dart';

import '../../core/theme.dart';

const double kAdminMinWidth = 1024;

bool isDesktopWidth(BuildContext context) {
  return MediaQuery.of(context).size.width >= kAdminMinWidth;
}

class AdminDesktopOnly extends StatelessWidget {
  const AdminDesktopOnly({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= kAdminMinWidth) return child;

        return Scaffold(
          backgroundColor: kUzinduziWhite,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: const Text(
              'Admin',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.desktop_windows_outlined,
                    size: 64,
                    color: kUzinduziGrey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Admin dashboard is desktop-only',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: kUzinduziBlack,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Open this page on a laptop or desktop — the screen '
                    'is too narrow to render the dashboard safely.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: kUzinduziGrey,
                      height: 1.5,
                    ),
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