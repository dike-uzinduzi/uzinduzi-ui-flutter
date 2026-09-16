import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../albums/album_models.dart';
import '../albums/albums_provider.dart';

final liveNowCountProvider = FutureProvider<int>((ref) async {
  final albums = await ref.watch(albumsProvider.future);
  return albums.where((a) => a.launch?.isActive == true).length;
});

class FanStats {
  final double totalSpent;
  final int totalPlaques;
  final int artistsFollowed;
  final int artistsSupported;

  FanStats({
    required this.totalSpent,
    required this.totalPlaques,
    required this.artistsFollowed,
    required this.artistsSupported,
  });

  factory FanStats.fromJson(Map<String, dynamic> j) => FanStats(
        totalSpent: (j['totalSpent'] as num?)?.toDouble() ?? 0,
        totalPlaques: (j['totalPlaques'] as num?)?.toInt() ?? 0,
        artistsFollowed: (j['artistsFollowed'] as num?)?.toInt() ?? 0,
        artistsSupported: (j['artistsSupported'] as num?)?.toInt() ?? 0,
      );
}

final fanStatsProvider = FutureProvider<FanStats>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/api/engagement/stats');
  final data = res['data'];
  if (data is! Map) {
    return FanStats(totalSpent: 0, totalPlaques: 0, artistsFollowed: 0, artistsSupported: 0);
  }
  return FanStats.fromJson(Map<String, dynamic>.from(data));
});

final featuredAlbumProvider = FutureProvider<Album?>((ref) async {
  final albums = await ref.watch(albumsProvider.future);
  if (albums.isEmpty) return null;
  final live = albums.where((a) => a.launch?.isActive == true).toList();
  return live.isNotEmpty ? live.first : albums.first;
});

String formatMoney(double amount) {
  if (amount >= 1000000) return '\$${(amount / 1000000).toStringAsFixed(1)}M';
  if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(1)}k';
  if (amount == amount.roundToDouble()) return '\$${amount.toInt()}';
  return '\$${amount.toStringAsFixed(2)}';
}