import '../../core/api_client.dart';
import 'album_models.dart';

class AlbumsRepository {
  final ApiClient _api;
  AlbumsRepository(this._api);

  Future<List<Album>> list() async {
    final res = await _api.get('/api/albums');
    final data = res['data'];
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((j) => Album.fromJson(Map<String, dynamic>.from(j)))
        .toList();
  }

  Future<Album> detail(String id) async {
    final res = await _api.get('/api/albums/$id');
    final data = res['data'];
    if (data is! Map) throw Exception('Malformed album response');
    return Album.fromJson(Map<String, dynamic>.from(data));
  }
}