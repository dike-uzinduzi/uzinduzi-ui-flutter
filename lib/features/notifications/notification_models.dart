class FanNotification {
  final String id;
  final String type;
  final String title;
  final String message;
  final bool read;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  FanNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
    this.metadata,
  });

  factory FanNotification.fromJson(Map<String, dynamic> j) => FanNotification(
        id: j['id'] as String,
        type: (j['type'] ?? '') as String,
        title: (j['title'] ?? '') as String,
        message: (j['message'] ?? '') as String,
        read: j['read'] as bool? ?? false,
        createdAt: DateTime.parse(j['createdAt'] as String).toLocal(),
        metadata: j['metadata'] is Map
            ? Map<String, dynamic>.from(j['metadata'] as Map)
            : null,
      );
}