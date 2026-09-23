import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';

class AdminTrack {
  final String id;
  final String title;
  final int durationMs;
  final int trackNumber;
  final String? featuredArtists;
  final String? producer;
  final String? writer;
  final String? performedBy;
  final String? backingVocals;
  final String? instrumentation;
  final String? masteringEngineer;
  final String? mixingEngineer;
  final String? specialCredits;
  final String? trackDescription;
  final bool isPublished;

  const AdminTrack({
    required this.id,
    required this.title,
    required this.durationMs,
    required this.trackNumber,
    this.featuredArtists,
    this.producer,
    this.writer,
    this.performedBy,
    this.backingVocals,
    this.instrumentation,
    this.masteringEngineer,
    this.mixingEngineer,
    this.specialCredits,
    this.trackDescription,
    this.isPublished = true,
  });

  factory AdminTrack.fromJson(Map<String, dynamic> j) => AdminTrack(
        id: j['id'] as String,
        title: (j['title'] ?? '') as String,
        durationMs: (j['durationMs'] as num?)?.toInt() ?? 0,
        trackNumber: (j['trackNumber'] as num?)?.toInt() ?? 0,
        featuredArtists: j['featuredArtists'] as String?,
        producer: j['producer'] as String?,
        writer: j['writer'] as String?,
        performedBy: j['performedBy'] as String?,
        backingVocals: j['backingVocals'] as String?,
        instrumentation: j['instrumentation'] as String?,
        masteringEngineer: j['masteringEngineer'] as String?,
        mixingEngineer: j['mixingEngineer'] as String?,
        specialCredits: j['specialCredits'] as String?,
        trackDescription: j['trackDescription'] as String?,
        isPublished: j['isPublished'] as bool? ?? true,
      );

  String get durationLabel {
    final total = durationMs ~/ 1000;
    return '${total ~/ 60}:${(total % 60).toString().padLeft(2, '0')}';
  }
}

final adminTracksProvider =
    FutureProvider.family<List<AdminTrack>, String>((ref, albumId) async {
  final api = ref.read(apiClientProvider);
  final res = await api.get('/api/tracks/album/$albumId');
  if (res['success'] != true || res['data'] == null) {
    throw Exception(res['message'] ?? 'Could not load tracks');
  }
  final items = (res['data'] as List?) ?? const [];
  return items
      .whereType<Map>()
      .map((m) => AdminTrack.fromJson(Map<String, dynamic>.from(m)))
      .toList();
});
