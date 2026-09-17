import '../../../core/config.dart';

class Album {
  final String id;
  final String title;
  final String? coverArt;
  final String? description;
  final String? genre;
  final int trackCount;
  final int duration;
  final bool isDemo;
  final bool isPublished;
  final bool isFeatured;
  final DateTime? releaseDate;
  final List<String> genres;
  final Artist? artist;
  final AlbumLaunch? launch;
  final List<Track>? tracks;

  Album({
    required this.id,
    required this.title,
    this.coverArt,
    this.description,
    this.genre,
    this.trackCount = 0,
    this.duration = 0,
    this.isDemo = false,
    this.isPublished = false,
    this.isFeatured = false,
    this.releaseDate,
    this.genres = const [],
    this.artist,
    this.launch,
    this.tracks,
  });

  factory Album.fromJson(Map<String, dynamic> j) => Album(
        id: j['id'] as String,
        title: j['title'] as String,
        coverArt: j['cover_art'] as String?,
        description: j['description'] as String?,
        genre: j['genre'] as String?,
        trackCount: (j['track_count'] as num?)?.toInt() ?? 0,
        duration: (j['duration'] as num?)?.toInt() ?? 0,
        isDemo: j['isDemo'] as bool? ?? false,
        isPublished: j['is_published'] as bool? ?? false,
        isFeatured: j['is_featured'] as bool? ?? false,
        releaseDate: j['release_date'] != null
            ? DateTime.tryParse(j['release_date'].toString())
            : null,
        genres: _parseGenres(j),
        artist: j['artist'] is Map
            ? Artist.fromJson(Map<String, dynamic>.from(j['artist'] as Map))
            : j['Artist'] is Map
                ? Artist.fromJson(Map<String, dynamic>.from(j['Artist'] as Map))
                : null,
        launch: j['launch'] is Map
            ? AlbumLaunch.fromJson(Map<String, dynamic>.from(j['launch'] as Map))
            : null,
        tracks: j['Tracks'] is List
            ? (j['Tracks'] as List)
                .whereType<Map>()
                .map((t) => Track.fromJson(Map<String, dynamic>.from(t)))
                .toList()
            : null,
      );

  static List<String> _parseGenres(Map<String, dynamic> j) {
    final raw = j['genres'] ?? j['Genres'];
    if (raw is List) {
      return raw
          .map((g) => g is Map ? g['name']?.toString() : g?.toString())
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return const [];
  }

  // ── Computed helpers ────────────────────────────────────

  String get artistName => artist?.name ?? 'Unknown artist';

  String get coverImage {
    final raw = coverArt;
    if (raw == null || raw.isEmpty) return AppConfig.defaultAlbumCover;
    if (raw.startsWith('http')) return raw;
    return '${AppConfig.cdnBase}/$raw';
  }

  bool get isLive => isPublished || (launch?.isActive ?? false);

  String get releaseDateFormatted {
    final d = releaseDate;
    if (d == null) return '—';
    return '${_month(d.month)} ${d.day}, ${d.year}';
  }

  String get durationLabel {
    final h = duration ~/ 3600;
    final m = (duration % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  static String _month(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][m - 1];
}

class Artist {
  final String id;
  final String name;
  final String? profilePictureUrl;

  Artist({required this.id, required this.name, this.profilePictureUrl});

  factory Artist.fromJson(Map<String, dynamic> j) => Artist(
        id: j['id'] as String,
        name: (j['stageName'] ?? j['name'] ?? '') as String,
        profilePictureUrl: j['profilePictureUrl'] as String?,
      );
}

class AlbumLaunch {
  final String id;
  final String status;
  final DateTime startsAt;
  final DateTime endsAt;
  final List<TierThreshold> tierThresholds;

  AlbumLaunch({
    required this.id,
    required this.status,
    required this.startsAt,
    required this.endsAt,
    required this.tierThresholds,
  });

  factory AlbumLaunch.fromJson(Map<String, dynamic> j) => AlbumLaunch(
        id: j['id'] as String,
        status: j['status'] as String,
        startsAt: DateTime.parse(j['startsAt'] as String).toLocal(),
        endsAt: DateTime.parse(j['endsAt'] as String).toLocal(),
        tierThresholds: (j['tierThresholds'] as List?)
                ?.whereType<Map>()
                .map((t) => TierThreshold.fromJson(Map<String, dynamic>.from(t)))
                .toList() ??
            [],
      );

  Duration get remaining {
    final d = endsAt.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  bool get isActive => status == 'active' && remaining.inSeconds > 0;
}

class TierThreshold {
  final String tier;
  final double minAmount;

  TierThreshold({required this.tier, required this.minAmount});

  factory TierThreshold.fromJson(Map<String, dynamic> j) => TierThreshold(
        tier: j['tier'] as String,
        minAmount: (j['minAmount'] as num).toDouble(),
      );
}

class Track {
  final String id;
  final String title;
  final int durationMs;
  final int trackNumber;
  final String? featuredArtists;
  final int likeCount;
  // Extended attributes
  final String? trackArt;
  final String? trackDescription;
  final String? writer;
  final String? performedBy;
  final String? backingVocals;
  final String? instrumentation;
  final String? producer;
  final String? mixingEngineer;
  final String? masteringEngineer;
  final String? specialCredits;

  Track({
    required this.id,
    required this.title,
    required this.durationMs,
    required this.trackNumber,
    this.featuredArtists,
    this.likeCount = 0,
    this.trackArt,
    this.trackDescription,
    this.writer,
    this.performedBy,
    this.backingVocals,
    this.instrumentation,
    this.producer,
    this.mixingEngineer,
    this.masteringEngineer,
    this.specialCredits,
  });

  factory Track.fromJson(Map<String, dynamic> j) => Track(
        id: j['id'] as String,
        title: j['title'] as String,
        durationMs: (j['durationMs'] as num?)?.toInt() ?? 0,
        trackNumber: (j['trackNumber'] as num?)?.toInt() ?? 0,
        featuredArtists: j['featuredArtists'] as String?,
        likeCount: (j['likeCount'] as num?)?.toInt() ?? 0,
        trackArt: j['trackArt'] as String?,
        trackDescription: j['trackDescription'] as String?,
        writer: j['writer'] as String?,
        performedBy: j['performedBy'] as String?,
        backingVocals: j['backingVocals'] as String?,
        instrumentation: j['instrumentation'] as String?,
        producer: j['producer'] as String?,
        mixingEngineer: j['mixingEngineer'] as String?,
        masteringEngineer: j['masteringEngineer'] as String?,
        specialCredits: j['specialCredits'] as String?,
      );

  String get formattedDuration {
    final total = durationMs ~/ 1000;
    return '${total ~/ 60}:${(total % 60).toString().padLeft(2, '0')}';
  }
}