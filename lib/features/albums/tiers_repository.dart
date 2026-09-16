

import '../../core/api_client.dart';
import 'plaque_tier_models.dart';

class TiersRepository {
  final ApiClient _api;
  TiersRepository(this._api);

  Future<List<PlaqueTier>> list() async {
    final res = await _api.get('/api/plaque-tiers');
    final data = res['data'];
    if (data is! List) {
      return [];
    }
    final parsed = data
        .whereType<Map>()
        .map((j) => PlaqueTier.fromJson(Map<String, dynamic>.from(j)))
        .toList();
   return parsed;
  }
}