import '../../../../core/api_client.dart';
import '../../../../core/errors.dart';

class AdminPreflightBlocker {
  final String type;
  final int? count;
  final String? status;
  final String? message;

  AdminPreflightBlocker({
    required this.type,
    this.count,
    this.status,
    this.message,
  });

  factory AdminPreflightBlocker.fromJson(Map<String, dynamic> j) =>
      AdminPreflightBlocker(
        type: j['type']?.toString() ?? 'dependency',
        count: (j['count'] as num?)?.toInt(),
        status: j['status']?.toString(),
        message: j['message']?.toString(),
      );

  String describe() {
    if (message != null && message!.isNotEmpty) return message!;
    final c = count;
    if (c != null && c > 0) return '$c ${_plural(type, c)}';
    if (status != null && status!.isNotEmpty) return '$type ($status)';
    return type;
  }

  static String _plural(String type, int count) =>
      count == 1 ? type : '${type}s';
}

class AdminPreflight {
  final bool canHardDelete;
  final List<AdminPreflightBlocker> blockers;

  AdminPreflight({required this.canHardDelete, required this.blockers});

  factory AdminPreflight.fromJson(Map<String, dynamic> j) => AdminPreflight(
        canHardDelete: j['canHardDelete'] == true,
        blockers: (j['blockers'] as List?)
                ?.whereType<Map>()
                .map((b) => AdminPreflightBlocker.fromJson(
                    Map<String, dynamic>.from(b)))
                .toList() ??
            const [],
      );

  String get blockersMessage =>
      blockers.map((b) => '• ${b.describe()}').join('\n');
}

/// Fetch delete-preflight info for a resource.
/// Currently supports: 'album'. Extend as more resources gain preflight.
Future<AdminPreflight> fetchPreflight(
  ApiClient api,
  String resourceType,
  String id,
) async {
  final path = switch (resourceType) {
    'album' => '/api/admin/albums/$id/delete-preflight',
    _ => throw AppError('No preflight endpoint for $resourceType'),
  };

  final res = await api.get(path);
  if (res['success'] != true || res['data'] == null) {
    throw AppError(res['message']?.toString() ?? 'Preflight failed');
  }
  return AdminPreflight.fromJson(Map<String, dynamic>.from(res['data'] as Map));
}