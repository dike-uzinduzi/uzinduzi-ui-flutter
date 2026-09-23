import '../../../core/config.dart';

class Album {
  final String id;
  final String artistId;
  final String title;
  final String? coverArt;
  final bool hasCustomCoverArt;
  final String? description;
  final String? albumType;
  final String? copyrightInfo;
  final String? publisher;
  final String? credits;
  final String? affiliation;
  final int trackCount;
  final int duration;
  final int viewCount;
  final bool isDemo;
  final bool isPublished;
  final bool isFeatured;
  final bool isDeleted;
  final DateTime? releaseDate;
  final List<String> genres;
  final Artist? artist;
  final AlbumLaunch? launch;
  final List<Track>? tracks;

  Album({
    required this.id,
    required this.artistId,
    required this.title,
    this.coverArt,
    this.hasCustomCoverArt = false,
    this.description,
    this.albumType,
    this.copyrightInfo,
    this.publisher,
    this.credits,
    this.affiliation,
    this.trackCount = 0,
    this.duration = 0,
    this.viewCount = 0,
    this.isDemo = false,
    this.isPublished = false,
    this.isFeatured = false,
    this.isDeleted = false,
    this.releaseDate,
    this.genres = const [],
    this.artist,
    this.launch,
    this.tracks,
  });

  factory Album.fromJson(Map<String, dynamic> j) => Album(
        id: j['id'] as String,
        artistId: (j['artistId'] ?? '') as String,
        title: j['title'] as String,
        coverArt: j['cover_art'] as String?,
        hasCustomCoverArt: j['hasCustomCoverArt'] as bool? ?? false,
        description: j['description'] as String?,
        albumType: j['albumType'] as String?,
        copyrightInfo: j['copyright_info'] as String?,
        publisher: j['publisher'] as String?,
        credits: j['credits'] as String?,
        affiliation: j['affiliation'] as String?,
        trackCount: (j['track_count'] as num?)?.toInt() ?? 0,
        duration: (j['duration'] as num?)?.toInt() ?? 0,
        viewCount: (j['viewCount'] as num?)?.toInt() ?? 0,
        isDemo: j['isDemo'] as bool? ?? false,
        isPublished: j['is_published'] as bool? ?? false,
        isFeatured: j['is_featured'] as bool? ?? false,
        isDeleted: j['is_deleted'] as bool? ?? false,
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

  /// Human-readable album type, capitalised.
  String get albumTypeLabel {
    final t = albumType;
    if (t == null || t.isEmpty) return 'Album';
    return t[0].toUpperCase() + t.substring(1);
  }

  static String _month(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][m - 1];
}

class Artist {
  final String id;
  final String? userId;
  final String name; // stageName preferred
  final String? firstName;
  final String? lastName;
  final String? bio;
  final String? profilePictureUrl;
  final String? coverPhoto;
  final String? genreId;
  final bool canCreateAlbums;
  final bool hasCustomProfilePic;
  final bool hasCustomCoverPhoto;

  Artist({
    required this.id,
    this.userId,
    required this.name,
    this.firstName,
    this.lastName,
    this.bio,
    this.profilePictureUrl,
    this.coverPhoto,
    this.genreId,
    this.canCreateAlbums = false,
    this.hasCustomProfilePic = false,
    this.hasCustomCoverPhoto = false,
  });

  factory Artist.fromJson(Map<String, dynamic> j) => Artist(
        id: j['id'] as String,
        userId: j['userId'] as String?,
        name: (j['stageName'] ?? j['name'] ?? '') as String,
        firstName: j['firstName'] as String?,
        lastName: j['lastName'] as String?,
        bio: j['bio'] as String?,
        profilePictureUrl: j['profilePictureUrl'] as String?,
        coverPhoto: j['coverPhoto'] as String?,
        genreId: j['genreId'] as String?,
        canCreateAlbums: j['canCreateAlbums'] as bool? ?? false,
        hasCustomProfilePic: j['hasCustomProfilePic'] as bool? ?? false,
        hasCustomCoverPhoto: j['hasCustomCoverPhoto'] as bool? ?? false,
      );

  /// Real name if both parts are set, otherwise the stage name.
  String get realName {
    final parts = [firstName, lastName]
        .where((s) => s != null && s.trim().isNotEmpty)
        .map((s) => s!.trim())
        .toList();
    return parts.isEmpty ? name : parts.join(' ');
  }

  String get avatarUrl {
    final u = profilePictureUrl;
    if (u == null || u.isEmpty) return AppConfig.defaultAvatar;
    if (u.startsWith('http')) return u;
    return '${AppConfig.cdnBase}/$u';
  }

  String get coverUrl {
    final u = coverPhoto;
    if (u == null || u.isEmpty) return AppConfig.defaultCover;
    if (u.startsWith('http')) return u;
    return '${AppConfig.cdnBase}/$u';
  }
}

class AlbumLaunch {
  final String id;
  final String? albumId;
  final String status;
  final DateTime startsAt;
  final DateTime endsAt;
  final DateTime? physicalLaunchAt;
  final String? createdBy;
  final List<TierThreshold> tierThresholds;

  AlbumLaunch({
    required this.id,
    this.albumId,
    required this.status,
    required this.startsAt,
    required this.endsAt,
    this.physicalLaunchAt,
    this.createdBy,
    required this.tierThresholds,
  });

  factory AlbumLaunch.fromJson(Map<String, dynamic> j) => AlbumLaunch(
        id: j['id'] as String,
        albumId: j['albumId'] as String?,
        status: j['status'] as String,
        startsAt: DateTime.parse(j['startsAt'] as String).toLocal(),
        endsAt: DateTime.parse(j['endsAt'] as String).toLocal(),
        physicalLaunchAt: j['physicalLaunchAt'] != null
            ? DateTime.tryParse(j['physicalLaunchAt'].toString())?.toLocal()
            : null,
        createdBy: j['createdBy'] as String?,
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

  bool get isEnded => status == 'ended' || endsAt.isBefore(DateTime.now());

  bool get isScheduled =>
      status == 'scheduled' && startsAt.isAfter(DateTime.now());

  String? get physicalLaunchFormatted {
    final d = physicalLaunchAt;
    if (d == null) return null;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
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
  final String? albumId;
  final String title;
  final int durationMs;
  final int trackNumber;
  final String? featuredArtists;
  final int likeCount;

  // Extended attributes
  final String? trackDescription;
  final String? writer;
  final String? performedBy;
  final String? backingVocals;
  final String? instrumentation;
  final String? producer;
  final String? mixingEngineer;
  final String? masteringEngineer;
  final String? specialCredits;
  final DateTime? releaseDate;
  final bool isPublished;
  final bool isDeleted;

  Track({
    required this.id,
    this.albumId,
    required this.title,
    required this.durationMs,
    required this.trackNumber,
    this.featuredArtists,
    this.likeCount = 0,
    this.trackDescription,
    this.writer,
    this.performedBy,
    this.backingVocals,
    this.instrumentation,
    this.producer,
    this.mixingEngineer,
    this.masteringEngineer,
    this.specialCredits,
    this.releaseDate,
    this.isPublished = false,
    this.isDeleted = false,
  });

  factory Track.fromJson(Map<String, dynamic> j) => Track(
        id: j['id'] as String,
        albumId: j['albumId'] as String?,
        title: j['title'] as String,
        durationMs: (j['durationMs'] as num?)?.toInt() ?? 0,
        trackNumber: (j['trackNumber'] as num?)?.toInt() ?? 0,
        featuredArtists: j['featuredArtists'] as String?,
        likeCount: (j['likeCount'] as num?)?.toInt() ?? 0,
        trackDescription: j['trackDescription'] as String?,
        writer: j['writer'] as String?,
        performedBy: j['performedBy'] as String?,
        backingVocals: j['backingVocals'] as String?,
        instrumentation: j['instrumentation'] as String?,
        producer: j['producer'] as String?,
        mixingEngineer: j['mixingEngineer'] as String?,
        masteringEngineer: j['masteringEngineer'] as String?,
        specialCredits: j['specialCredits'] as String?,
        releaseDate: j['releaseDate'] != null
            ? DateTime.tryParse(j['releaseDate'].toString())
            : null,
        isPublished: j['isPublished'] as bool? ?? false,
        isDeleted: j['isDeleted'] as bool? ?? false,
      );

  String get formattedDuration {
    final total = durationMs ~/ 1000;
    return '${total ~/ 60}:${(total % 60).toString().padLeft(2, '0')}';
  }
}