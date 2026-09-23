import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';

class ArtistOption {
  final String id;
  final String name;
  const ArtistOption({required this.id, required this.name});
}

final adminArtistsPickerProvider =
    FutureProvider<List<ArtistOption>>((ref) async {
  final api = ref.read(apiClientProvider);
  final res = await api.get('/api/artists');
  if (res['success'] != true || res['data'] == null) {
    throw Exception(res['message'] ?? 'Could not load artists');
  }
  final items = (res['data'] as List?) ?? const [];
  return items
      .whereType<Map>()
      .map((m) => ArtistOption(
            id: m['id'] as String,
            name: (m['stageName'] ?? m['name'] ?? '—').toString(),
          ))
      .toList();
});
