import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import 'album_models.dart';
import 'albums_repository.dart';

final albumsRepositoryProvider = Provider<AlbumsRepository>((ref) {
  return AlbumsRepository(ref.watch(apiClientProvider));
});

final albumsProvider = FutureProvider<List<Album>>((ref) async {
  return ref.watch(albumsRepositoryProvider).list();
});