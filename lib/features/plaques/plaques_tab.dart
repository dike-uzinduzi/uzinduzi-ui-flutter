import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import 'plaques_provider.dart';
import 'widgets/plaque_row.dart';

class PlaquesTab extends ConsumerWidget {
  const PlaquesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plaques = ref.watch(myPlaquesProvider);

    return Scaffold(
      backgroundColor: kUzinduziWhite,
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'My Plaques',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 10),
            plaques.maybeWhen(
              data: (list) => list.isEmpty
                  ? const SizedBox.shrink()
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: kUzinduziRed,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${list.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: kUzinduziRed,
        onRefresh: () async => ref.invalidate(myPlaquesProvider),
        child: plaques.when(
          data: (list) {
            if (list.isEmpty) return const _EmptyPlaques();
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => PlaqueRow(plaque: list[i]),
                ),
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: kUzinduziRed),
          ),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text('$e', textAlign: TextAlign.center,
                  style: const TextStyle(color: kUzinduziGrey, fontSize: 13)),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyPlaques extends StatelessWidget {
  const _EmptyPlaques();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 120),
        Center(
          child: Column(
            children: [
              Icon(Icons.workspace_premium_outlined, size: 56, color: kUzinduziGrey),
              SizedBox(height: 12),
              Text(
                'No plaques yet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                'Support an album launch to earn one',
                style: TextStyle(fontSize: 13, color: kUzinduziGrey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}