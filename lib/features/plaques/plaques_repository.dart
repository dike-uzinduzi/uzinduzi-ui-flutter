import '../../core/api_client.dart';
import 'plaque_models.dart';

class PlaquesRepository {
  final ApiClient _api;
  PlaquesRepository(this._api);

  Future<List<UserPlaque>> myPlaques() async {
    final res = await _api.get('/api/payments/my-awarded-plaques');
    final data = res['data'];
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((j) => UserPlaque.fromJson(Map<String, dynamic>.from(j)))
        .toList();
  }
}