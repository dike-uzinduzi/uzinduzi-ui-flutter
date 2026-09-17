import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import 'notification_models.dart';
import 'notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _iconFor(String type) {
    switch (type) {
      case 'NEW_ALBUM':
        return Icons.album;
      case 'NEW_LAUNCH':
        return Icons.podcasts;
      case 'NEWS':
        return Icons.newspaper;
      case 'PLAQUE_PURCHASED':
        return Icons.workspace_premium;
      case 'PLAQUE_IN_PRODUCTION':
        return Icons.build_circle_outlined;
      case 'PLAQUE_SHIPPED':
        return Icons.local_shipping_outlined;
      case 'ARTIST_FOLLOWED':
        return Icons.person_add;
      case 'BADGE_EARNED':
        return Icons.military_tech;
      default:
        return Icons.notifications_none;
    }
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('d MMM').format(dt);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(notificationsFeedProvider);

    return Scaffold(
      backgroundColor: kUzinduziWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final repo = ref.read(notificationsRepositoryProvider);
              await repo.markAllRead();
              ref.invalidate(notificationsFeedProvider);
              ref.invalidate(unreadNotificationsProvider);
            },
            icon: const Icon(Icons.done_all, size: 18, color: kUzinduziRed),
            label: const Text(
              'Mark all',
              style: TextStyle(
                color: kUzinduziRed,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: kUzinduziRed,
        onRefresh: () async {
          ref.invalidate(notificationsFeedProvider);
          ref.invalidate(unreadNotificationsProvider);
        },
        child: feed.when(
          data: (list) {
            if (list.isEmpty) return const _EmptyNotifications();
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: list.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: kUzinduziDivider),
                  itemBuilder: (context, i) {
                    final n = list[i];
                    return _NotificationRow(
                      notification: n,
                      icon: _iconFor(n.type),
                      relativeTime: _relativeTime(n.createdAt),
                      onTap: () async {
                        if (!n.read) {
                          final repo = ref.read(notificationsRepositoryProvider);
                          await repo.markRead(n.id);
                          ref.invalidate(notificationsFeedProvider);
                          ref.invalidate(unreadNotificationsProvider);
                        }
                      },
                    );
                  },
                ),
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: kUzinduziRed),
          ),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text('$e', textAlign: TextAlign.center,
                  style: const TextStyle(color: kUzinduziGrey, fontSize: 13)),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  final FanNotification notification;
  final IconData icon;
  final String relativeTime;
  final VoidCallback onTap;

  const _NotificationRow({
    required this.notification,
    required this.icon,
    required this.relativeTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kUzinduziRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: kUzinduziRed),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notification.read
                                ? FontWeight.w600
                                : FontWeight.w800,
                            color: kUzinduziBlack,
                          ),
                        ),
                      ),
                      if (!notification.read)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: kUzinduziRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: kUzinduziGrey,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    relativeTime,
                    style: const TextStyle(fontSize: 10, color: kUzinduziGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 120),
        Center(
          child: Column(
            children: [
              Icon(Icons.notifications_none, size: 56, color: kUzinduziGrey),
              SizedBox(height: 12),
              Text(
                'No notifications yet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                'Follow artists to get updates',
                style: TextStyle(fontSize: 13, color: kUzinduziGrey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}