import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'albums_provider.dart';
import 'album_models.dart';
import 'tiers_provider.dart';
import 'plaque_tier_models.dart';
/// Full album detail with tracks and launch.
final albumDetailProvider =
    FutureProvider.family<Album, String>((ref, albumId) async {
  return ref.watch(albumsRepositoryProvider).detail(albumId);
});

/// The current amount the fan has chosen on the album detail slider.
/// Shared between the slider block and the tier preview pane.
final selectedAmountProvider = StateProvider.family<double, String>(
  (ref, albumId) => 51,
);

/// The tier that the current amount qualifies for.
final selectedTierProvider = Provider.family<PlaqueTier?, String>((ref, albumId) {
  final amount = ref.watch(selectedAmountProvider(albumId));
  final tiers = ref.watch(tiersProvider).valueOrNull ?? [];
  if (tiers.isEmpty) return null;
  final sorted = [...tiers]..sort((a, b) => b.minAmount.compareTo(a.minAmount));
  for (final t in sorted) {
    if (amount >= t.minAmount) return t;
  }
  return null;
});