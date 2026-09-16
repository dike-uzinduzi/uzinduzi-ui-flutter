import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import 'plaque_models.dart';
import 'plaques_repository.dart';

final plaquesRepositoryProvider = Provider<PlaquesRepository>((ref) {
  return PlaquesRepository(ref.watch(apiClientProvider));
});

final myPlaquesProvider = FutureProvider<List<UserPlaque>>((ref) async {
  return ref.watch(plaquesRepositoryProvider).myPlaques();
});