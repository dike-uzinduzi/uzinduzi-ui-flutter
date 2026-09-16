import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import 'notification_models.dart';
import 'notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref.watch(apiClientProvider));
});

final notificationsFeedProvider = FutureProvider<List<FanNotification>>((ref) async {
  return ref.watch(notificationsRepositoryProvider).feed(limit: 50);
});

final unreadNotificationsProvider = FutureProvider<int>((ref) async {
  return ref.watch(notificationsRepositoryProvider).unreadCount();
});