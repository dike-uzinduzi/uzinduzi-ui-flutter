class AdminAlbumRow {
  final String id;
  final String title;
  final String? coverArt;
  final String artistName;
  final String albumType;
  final int trackCount;
  final int duration;
  final bool isPublished;
  final bool isFeatured;
  final bool isDeleted;
  final DateTime? releaseDate;

  const AdminAlbumRow({
    required this.id,
    required this.title,
    this.coverArt,
    required this.artistName,
    required this.albumType,
    required this.trackCount,
    required this.duration,
    required this.isPublished,
    required this.isFeatured,
    required this.isDeleted,
    this.releaseDate,
  });

  factory AdminAlbumRow.fromJson(Map<String, dynamic> j) {
    final artist = j['artist'] as Map?;
    return AdminAlbumRow(
      id: j['id'] as String,
      title: (j['title'] ?? '') as String,
      coverArt: j['cover_art'] as String?,
      artistName: (artist?['stageName'] ?? artist?['name'] ?? '—') as String,
      albumType: (j['albumType'] ?? 'album') as String,
      trackCount: (j['track_count'] as num?)?.toInt() ?? 0,
      duration: (j['duration'] as num?)?.toInt() ?? 0,
      isPublished: j['is_published'] as bool? ?? false,
      isFeatured: j['is_featured'] as bool? ?? false,
      isDeleted: j['is_deleted'] as bool? ?? false,
      releaseDate: j['release_date'] != null
          ? DateTime.tryParse(j['release_date'].toString())
          : null,
    );
  }

  String get durationLabel {
    final m = duration ~/ 60;
    final s = duration % 60;
    return '${m}m ${s}s';
  }
}
