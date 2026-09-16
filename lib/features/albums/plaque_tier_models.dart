class PlaqueTier {
  final String id;
  final String slug;
  final String displayName;
  final double minAmount;
  final int order;
  final String? imageUrl;
  final List<String> benefits;
  final int? freeShowDays;

  PlaqueTier({
    required this.id,
    required this.slug,
    required this.displayName,
    required this.minAmount,
    required this.order,
    this.imageUrl,
    required this.benefits,
    this.freeShowDays,
  });

  factory PlaqueTier.fromJson(Map<String, dynamic> j) {
  final rawMin = j['minAmount'];
  final minAmount = rawMin is num
      ? rawMin.toDouble()
      : double.tryParse(rawMin?.toString() ?? '') ?? 0;

  return PlaqueTier(
    id: (j['id'] ?? '').toString(),
    slug: (j['slug'] ?? '').toString().toUpperCase(),
    displayName: (j['displayName'] ?? '').toString(),
    minAmount: minAmount,
    order: (j['order'] as num?)?.toInt() ?? 0,
    imageUrl: j['imageUrl'] as String?,
    benefits: (j['benefits'] as List?)?.whereType<String>().toList() ?? [],
    freeShowDays: (j['freeShowDays'] as num?)?.toInt(),
  );
}}