class UserPlaque {
  final String id;
  final String serialNumber;
  final String plaqueType;
  final String? plaqueImageUrl;
  final String status;
  final double amount;
  final String? ownerType;
  final bool isDemo;
  final DateTime? issuedAt;
  final DateTime? deliveredAt;
  final DateTime createdAt;
  final PlaqueAlbumRef? album;
  final PlaqueArtistRef? artist;

  UserPlaque({
    required this.id,
    required this.serialNumber,
    required this.plaqueType,
    this.plaqueImageUrl,
    required this.status,
    required this.amount,
    this.ownerType,
    this.isDemo = false,
    this.issuedAt,
    this.deliveredAt,
    required this.createdAt,
    this.album,
    this.artist,
  });

  factory UserPlaque.fromJson(Map<String, dynamic> j) => UserPlaque(
        id: j['id'] as String,
        serialNumber: (j['serialNumber'] ?? '') as String,
        plaqueType: (j['plaqueType'] ?? '') as String,
        plaqueImageUrl: j['plaqueImageUrl'] as String?,
        status: (j['status'] ?? '') as String,
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        ownerType: j['ownerType'] as String?,
        isDemo: j['isDemo'] as bool? ?? false,
        issuedAt: j['issuedAt'] != null
            ? DateTime.tryParse(j['issuedAt'] as String)?.toLocal()
            : null,
        deliveredAt: j['deliveredAt'] != null
            ? DateTime.tryParse(j['deliveredAt'] as String)?.toLocal()
            : null,
        createdAt: DateTime.parse(j['createdAt'] as String).toLocal(),
        album: j['album'] is Map
            ? PlaqueAlbumRef.fromJson(Map<String, dynamic>.from(j['album'] as Map))
            : null,
        artist: j['artist'] is Map
            ? PlaqueArtistRef.fromJson(Map<String, dynamic>.from(j['artist'] as Map))
            : null,
      );
}

class PlaqueAlbumRef {
  final String id;
  final String title;
  final String? coverImage;
  PlaqueAlbumRef({required this.id, required this.title, this.coverImage});

  factory PlaqueAlbumRef.fromJson(Map<String, dynamic> j) => PlaqueAlbumRef(
        id: j['id'] as String,
        title: (j['title'] ?? '') as String,
        coverImage: j['coverImage'] as String?,
      );
}

class PlaqueArtistRef {
  final String id;
  final String name;
  final String? profileImage;
  PlaqueArtistRef({required this.id, required this.name, this.profileImage});

  factory PlaqueArtistRef.fromJson(Map<String, dynamic> j) => PlaqueArtistRef(
        id: j['id'] as String,
        name: (j['name'] ?? '') as String,
        profileImage: j['profileImage'] as String?,
      );
}