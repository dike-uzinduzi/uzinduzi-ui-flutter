import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../widgets/uzinduzi_logo.dart';
import '../auth/auth_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;

    return Scaffold(
      backgroundColor: kUzinduziWhite,
      appBar: AppBar(
        title: const UzinduziLogo(
          variant: LogoVariant.launchSymbol,
          height: 28,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
     body: Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 720),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            'Welcome, ${user?.userName ?? "there"} ',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: kUzinduziBlack,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user?.email ?? '',
            style: const TextStyle(fontSize: 14, color: kUzinduziGrey),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: kUzinduziRed.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              (user?.role ?? 'unknown').toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: kUzinduziRed,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Coming next',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kUzinduziBlack,
            ),
          ),
          const SizedBox(height: 12),
          const _ComingSoonRow(
            icon: Icons.album_outlined,
            label: 'Browse albums',
          ),
          const _ComingSoonRow(
            icon: Icons.workspace_premium_outlined,
            label: 'My plaques',
          ),
          const _ComingSoonRow(
            icon: Icons.person_outline,
            label: 'Profile',
          ),
        ],
      ),
    ),
  ),
),
    );
  }
}

class _ComingSoonRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ComingSoonRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: kUzinduziGrey),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: kUzinduziBlack),
          ),
        ],
      ),
    );
  }
}
