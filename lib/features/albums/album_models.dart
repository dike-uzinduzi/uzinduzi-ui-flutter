class Album {
  final String id;
  final String title;
  final String? coverArt;
  final String? description;
  final String? genre;
  final int trackCount;
  final int duration;
  final bool isDemo;
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
        artist: j['artist'] is Map
            ? Artist.fromJson(Map<String, dynamic>.from(j['artist'] as Map))
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