import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import 'plaque_tier_models.dart';
import 'tiers_repository.dart';

final tiersRepositoryProvider = Provider<TiersRepository>((ref) {
  return TiersRepository(ref.watch(apiClientProvider));
});

/// Fetches all active plaque tiers once. The app invalidates this
/// on screen open so admin edits propagate without a rebuild.
final tiersProvider = FutureProvider<List<PlaqueTier>>((ref) async {
  return ref.watch(tiersRepositoryProvider).list();
});

/// Resolve the tier a given amount qualifies for, from the fetched list.
/// Returns null when the amount is below the lowest tier.
PlaqueTier? tierForAmount(double amount, List<PlaqueTier> tiers) {
  if (tiers.isEmpty) return null;
  final sorted = [...tiers]..sort((a, b) => b.minAmount.compareTo(a.minAmount));
  for (final t in sorted) {
    if (amount >= t.minAmount) return t;
  }
  return null;
}