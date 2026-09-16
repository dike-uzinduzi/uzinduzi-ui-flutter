import '../../core/api_client.dart';
import 'notification_models.dart';

class NotificationsRepository {
  final ApiClient _api;
  NotificationsRepository(this._api);

  Future<List<FanNotification>> feed({int limit = 20, int offset = 0}) async {
    final res = await _api.get('/api/engagement/feed', query: {
      'limit': limit,
      'offset': offset,
    });
    final data = res['data'];
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((j) => FanNotification.fromJson(Map<String, dynamic>.from(j)))
        .toList();
  }

  Future<int> unreadCount() async {
    final res = await _api.get('/api/engagement/activities/unread-count');
    final data = res['data'];
    if (data is Map && data['count'] is num) {
      return (data['count'] as num).toInt();
    }
    return 0;
  }

  Future<void> markRead(String id) async {
    await _api.patch('/api/engagement/activities/$id/read');
  }

  Future<void> markAllRead() async {
    await _api.patch('/api/engagement/activities/read-all');
  }
}