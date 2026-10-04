import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import 'admin_tier_edit_screen.dart';
import 'admin_tiers_provider.dart';
import 'widgets/tier_row_card.dart';
import 'admin_tier_model.dart';

class AdminTiersScreen extends ConsumerWidget {
  const AdminTiersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiers = ref.watch(adminTiersProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  const Text(
                    'Plaque tiers',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: kUzinduziBlack,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => ref.invalidate(adminTiersProvider),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: kUzinduziRed,
                    ),
                    onPressed: () => _openCreate(context, ref),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('New tier'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: kUzinduziDivider),
            Expanded(
              child: tiers.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: Text(
                          'No tiers yet. Create the first one.',
                          style: TextStyle(color: kUzinduziGrey),
                        ),
                      ),
                    );
                  }

                  return ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    // ignore: deprecated_member_use
                    onReorder: (oldIndex, newIndex) =>
                        _onReorder(context, ref, list, oldIndex, newIndex),
                    itemBuilder: (context, i) {
                      final tier = list[i];
                      return TierRowCard(
                        key: ValueKey(tier.id),
                        tier: tier,
                        index: i,
                        onTap: () => _openEdit(context, ref, tier),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: kUzinduziRed),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Text(
                      'Error loading tiers:\n$e',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: kUzinduziGrey),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCreate(BuildContext context, WidgetRef ref) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const AdminTierEditScreen(),
      ),
    );
    if (created == true) ref.invalidate(adminTiersProvider);
  }

  Future<void> _openEdit(
    BuildContext context,
    WidgetRef ref,
    AdminTier tier,
  ) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdminTierEditScreen(tier: tier),
      ),
    );
    if (changed == true) ref.invalidate(adminTiersProvider);
  }

  Future<void> _onReorder(
    BuildContext context,
    WidgetRef ref,
    List<AdminTier> list,
    int oldIndex,
    int newIndex,
  ) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final reordered = [...list];
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);

    // Persist the new order for every tier whose position changed.
    final repo = ref.read(adminTiersRepositoryProvider);
    try {
      for (var i = 0; i < reordered.length; i++) {
        final t = reordered[i];
        if (t.order == i) continue;
        await repo.update(
          t.id,
          AdminTier(
            id: t.id,
            slug: t.slug,
            displayName: t.displayName,
            minAmount: t.minAmount,
            order: i,
            imageUrl: t.imageUrl,
            benefits: t.benefits,
            freeShowDays: t.freeShowDays,
            isActive: t.isActive,
          ),
        );
      }
      if (!context.mounted) return;
      ref.invalidate(adminTiersProvider);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reorder failed: $e')),
      );
      ref.invalidate(adminTiersProvider);
    }
  }
}