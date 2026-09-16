import 'package:flutter/foundation.dart';

import '../../core/api_client.dart';
import 'plaque_tier_models.dart';

class TiersRepository {
  final ApiClient _api;
  TiersRepository(this._api);

  Future<List<PlaqueTier>> list() async {
    final res = await _api.get('/api/plaque-tiers');
    debugPrint('TIERS RAW: success=${res['success']} dataType=${res['data']?.runtimeType}');
    final data = res['data'];
    if (data is! List) {
      debugPrint('TIERS: data is not a List — got ${data.runtimeType}');
      return [];
    }
    final parsed = data
        .whereType<Map>()
        .map((j) => PlaqueTier.fromJson(Map<String, dynamic>.from(j)))
        .toList();
    debugPrint('TIERS PARSED: ${parsed.length} tiers, first slug=${parsed.isNotEmpty ? parsed.first.slug : "none"}');
    return parsed;
  }
}