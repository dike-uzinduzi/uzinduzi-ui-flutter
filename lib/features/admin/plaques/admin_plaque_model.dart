class AdminPlaque {
  final String id;
  final String serialNumber;
  final String? verificationCode;
  final String plaqueType;         // WOOD | CRIMSON | SAPPHIRE | EMERALD | SILVER | GOLD
  final String status;             // PENDING_PAYMENT | PAID | ISSUED | ...
  final double amount;
  final String ownerType;          // FAN | CORPORATE
  final String ownerId;
  final String? ownerName;
  final String? ownerEmail;
  final String albumId;
  final String? albumTitle;
  final String artistId;
  final String? artistName;
  final String paymentId;
  final bool isDemo;
  final String? plaqueImageUrl;
  final String? certificateUrl;
  final String? qrCodeUrl;
  final String? shippingAddress;
  final String? trackingNumber;
  final String? adminNotes;
  final String? cancellationReason;
  final bool isVerified;
  final DateTime? issuedAt;
  final DateTime? deliveredAt;
  final DateTime? collectedAt;
  final DateTime? cancelledAt;
  final DateTime? createdAt;
  // blockchain (optional, read-only)
  final int? chainId;
  final String? contractAddress;
  final String? tokenId;
  final String? txHash;
  final DateTime? anchoredAt;

  AdminPlaque({
    required this.id,
    required this.serialNumber,
    this.verificationCode,
    required this.plaqueType,
    required this.status,
    required this.amount,
    required this.ownerType,
    required this.ownerId,
    this.ownerName,
    this.ownerEmail,
    required this.albumId,
    this.albumTitle,
    required this.artistId,
    this.artistName,
    required this.paymentId,
    this.isDemo = false,
    this.plaqueImageUrl,
    this.certificateUrl,
    this.qrCodeUrl,
    this.shippingAddress,
    this.trackingNumber,
    this.adminNotes,
    this.cancellationReason,
    this.isVerified = true,
    this.issuedAt,
    this.deliveredAt,
    this.collectedAt,
    this.cancelledAt,
    this.createdAt,
    this.chainId,
    this.contractAddress,
    this.tokenId,
    this.txHash,
    this.anchoredAt,
  });

  factory AdminPlaque.fromJson(Map<String, dynamic> j) {
    // ── Album: real alias is 'plaqueAlbum' ────────────────
    final album = j['plaqueAlbum'] is Map
        ? Map<String, dynamic>.from(j['plaqueAlbum'] as Map)
        : j['album'] is Map
            ? Map<String, dynamic>.from(j['album'] as Map)
            : j['Album'] is Map
                ? Map<String, dynamic>.from(j['Album'] as Map)
                : null;

    // ── Artist: no alias on server → key is 'Artist' ──────
    final artist = j['Artist'] is Map
        ? Map<String, dynamic>.from(j['Artist'] as Map)
        : j['artist'] is Map
            ? Map<String, dynamic>.from(j['artist'] as Map)
            : j['plaqueArtist'] is Map
                ? Map<String, dynamic>.from(j['plaqueArtist'] as Map)
                : null;

    // ── Owner: real alias is 'owner' ──────────────────────
    final owner = j['owner'] is Map
        ? Map<String, dynamic>.from(j['owner'] as Map)
        : j['User'] is Map
            ? Map<String, dynamic>.from(j['User'] as Map)
            : j['plaqueOwner'] is Map
                ? Map<String, dynamic>.from(j['plaqueOwner'] as Map)
                : null;

    return AdminPlaque(
      id: (j['id'] ?? '').toString(),
      serialNumber: (j['serialNumber'] ?? '').toString(),
      verificationCode: j['verificationCode']?.toString(),
      plaqueType: (j['plaqueType'] ?? '').toString(),
      status: (j['status'] ?? 'PENDING_PAYMENT').toString(),
      amount: _double(j['amount']),
      ownerType: (j['ownerType'] ?? 'FAN').toString(),
      ownerId: (j['ownerId'] ?? '').toString(),
      ownerName: j['ownerName']?.toString() ?? owner?['userName']?.toString(),
      ownerEmail: owner?['email']?.toString(),
      albumId: (j['albumId'] ?? '').toString(),
      albumTitle: album?['title']?.toString(),
      artistId: (j['artistId'] ?? '').toString(),
      artistName: artist?['stageName']?.toString() ??
          artist?['name']?.toString(),
      paymentId: (j['paymentId'] ?? '').toString(),
      isDemo: j['isDemo'] as bool? ?? false,
      plaqueImageUrl: j['plaqueImageUrl']?.toString(),
      certificateUrl: j['certificateUrl']?.toString(),
      qrCodeUrl: j['qrCodeUrl']?.toString(),
      shippingAddress: _stringifyAddress(j['shippingAddress']),
      trackingNumber: j['trackingNumber']?.toString(),
      adminNotes: j['adminNotes']?.toString(),
      cancellationReason: j['cancellationReason']?.toString(),
      isVerified: j['isVerified'] as bool? ?? true,
      issuedAt: _date(j['issuedAt']),
      deliveredAt: _date(j['deliveredAt']),
      collectedAt: _date(j['collectedAt']),
      cancelledAt: _date(j['cancelledAt']),
      createdAt: _date(j['createdAt']),
      chainId: (j['chainId'] as num?)?.toInt(),
      contractAddress: j['contractAddress']?.toString(),
      tokenId: j['tokenId']?.toString(),
      txHash: j['txHash']?.toString(),
      anchoredAt: _date(j['anchoredAt']),
    );
  }

  static double _double(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static DateTime? _date(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  static String? _stringifyAddress(dynamic v) {
    if (v == null) return null;
    if (v is String) return v.isEmpty ? null : v;
    if (v is Map) {
      final parts = [
        v['line1'],
        v['line2'],
        v['city'],
        v['state'],
        v['postalCode'],
        v['country'],
      ].where((s) => s != null && s.toString().trim().isNotEmpty);
      return parts.isEmpty ? null : parts.join(', ');
    }
    return v.toString();
  }
}

// ─── Status flow (mirror of server) ───────────────────────────
const kPlaqueStatusFlow = <String, List<String>>{
  'PENDING_PAYMENT':    ['PAID', 'CANCELLED'],
  'PAID':               ['ISSUED', 'CANCELLED'],
  'ISSUED':             ['IN_PRODUCTION', 'CANCELLED'],
  'IN_PRODUCTION':      ['READY_FOR_DELIVERY', 'CANCELLED'],
  'READY_FOR_DELIVERY': ['DELIVERED', 'CANCELLED'],
  'DELIVERED':          ['COLLECTED'],
  'COLLECTED':          [],
  'CANCELLED':          [],
};

const kPlaqueStatuses = <String>[
  'PENDING_PAYMENT',
  'PAID',
  'ISSUED',
  'IN_PRODUCTION',
  'READY_FOR_DELIVERY',
  'DELIVERED',
  'COLLECTED',
  'CANCELLED',
];

String plaqueStatusLabel(String s) => switch (s) {
      'PENDING_PAYMENT' => 'Pending payment',
      'PAID' => 'Paid',
      'ISSUED' => 'Issued',
      'IN_PRODUCTION' => 'In production',
      'READY_FOR_DELIVERY' => 'Ready for delivery',
      'DELIVERED' => 'Delivered',
      'COLLECTED' => 'Collected',
      'CANCELLED' => 'Cancelled',
      _ => s,
    };

String plaqueTransitionLabel(String to) => switch (to) {
      'PAID' => 'Mark paid',
      'ISSUED' => 'Issue plaque',
      'IN_PRODUCTION' => 'Start production',
      'READY_FOR_DELIVERY' => 'Ready for delivery',
      'DELIVERED' => 'Mark delivered',
      'COLLECTED' => 'Mark collected',
      'CANCELLED' => 'Cancel',
      _ => to,
    };