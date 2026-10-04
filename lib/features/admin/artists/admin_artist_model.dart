class AdminArtist {
  final String id;
  final String? userId;
  final String stageName;
  final String? firstName;
  final String? lastName;
  final String? bio;
  final String? genreId;
  final String? profilePictureUrl;
  final String? coverPhoto;
  final bool canCreateAlbums;
  final bool hasCustomProfilePic;
  final bool hasCustomCoverPhoto;

  AdminArtist({
    required this.id,
    this.userId,
    required this.stageName,
    this.firstName,
    this.lastName,
    this.bio,
    this.genreId,
    this.profilePictureUrl,
    this.coverPhoto,
    this.canCreateAlbums = false,
    this.hasCustomProfilePic = false,
    this.hasCustomCoverPhoto = false,
  });

  factory AdminArtist.fromJson(Map<String, dynamic> j) => AdminArtist(
        id: (j['id'] ?? '').toString(),
        userId: j['userId']?.toString(),
        stageName: (j['stageName'] ?? j['name'] ?? '').toString(),
        firstName: j['firstName']?.toString(),
        lastName: j['lastName']?.toString(),
        bio: j['bio']?.toString(),
        genreId: j['genreId']?.toString(),
        profilePictureUrl: j['profilePictureUrl']?.toString(),
        coverPhoto: j['coverPhoto']?.toString(),
        canCreateAlbums: j['canCreateAlbums'] as bool? ?? false,
        hasCustomProfilePic: j['hasCustomProfilePic'] as bool? ?? false,
        hasCustomCoverPhoto: j['hasCustomCoverPhoto'] as bool? ?? false,
      );

  Map<String, dynamic> toCreateBody() => {
        'userId': userId,
        'stageName': stageName,
        'firstName': firstName,
        'lastName': lastName,
        'bio': bio,
        'genreId': genreId,
        'canCreateAlbums': canCreateAlbums,
      };

  Map<String, dynamic> toUpdateBody() => {
        'stageName': stageName,
        'firstName': firstName,
        'lastName': lastName,
        'bio': bio,
        'genreId': genreId,
        'canCreateAlbums': canCreateAlbums,
      };
}