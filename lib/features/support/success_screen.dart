import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/config.dart';
import '../../core/theme.dart';
import '../albums/plaque_tier_models.dart';
import 'support_repository.dart';

class SuccessScreen extends StatelessWidget {
  final String albumTitle;
  final String artistName;
  final PlaqueTier? tier;
  final double amount;
  final SupportResult result;
  final Map<String, dynamic>? shippingAddress;

  const SuccessScreen({
    super.key,
    required this.albumTitle,
    required this.artistName,
    required this.tier,
    required this.amount,
    required this.result,
    this.shippingAddress,
  });

  String? _plaqueImageUrl() {
    final raw = result.plaqueImageUrl;
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http')) return raw;
    return '${AppConfig.cdnBase}/$raw';
  }

  String _shippingLine() {
    if (shippingAddress == null) return '';
    final parts = [
      shippingAddress!['addressLine1'],
      shippingAddress!['addressLine2'],
      shippingAddress!['city'],
      shippingAddress!['country'],
    ].where((s) => s != null && s.toString().trim().isNotEmpty);
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final hasPlaque = result.hasPlaque && tier != null;

    return Scaffold(
      backgroundColor: kUzinduziWhite,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: kStatusLive,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 40),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    hasPlaque ? 'Support successful' : 'Thank you',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: kUzinduziBlack,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasPlaque
                        ? 'You supported $artistName\'s $albumTitle'
                        : 'Your \$${amount.toStringAsFixed(2)} goes directly to $artistName',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: kUzinduziGrey),
                  ),
                  const SizedBox(height: 32),

                  if (hasPlaque) ...[
                    Center(
                      child: _plaqueImageUrl() != null
                          ? CachedNetworkImage(
                              imageUrl: _plaqueImageUrl()!,
                              height: 180,
                              fit: BoxFit.contain,
                              errorWidget: (_, _, _) => Container(
                                height: 180,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.workspace_premium,
                                  size: 72,
                                  color: tierColor(tier!.slug),
                                ),
                              ),
                            )
                          : Icon(
                              Icons.workspace_premium,
                              size: 72,
                              color: tierColor(tier!.slug),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: tierColor(tier!.slug),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${tier!.displayName.toUpperCase()} PLAQUE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (result.plaqueSerial != null) ...[
                      const Text(
                        'Serial number',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: kUzinduziGrey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.plaqueSerial!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700,
                          color: kUzinduziBlack,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (shippingAddress != null) ...[
                      const Text(
                        'Ships to',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: kUzinduziGrey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _shippingLine(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, color: kUzinduziBlack),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ] else ...[
                    const SizedBox(height: 24),
                    const Center(
                      child: Icon(
                        Icons.favorite,
                        size: 64,
                        color: kUzinduziRed,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Every contribution counts.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: kUzinduziBlack,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final text =
                            'I just supported $artistName\'s $albumTitle on Uzinduzi 🎵';
                        Share.share(text);
                      },
                      icon: const Icon(Icons.ios_share, size: 18),
                      label: const Text('Share my support'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (hasPlaque)
                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((r) => r.isFirst);
                        },
                        child: const Text('View my plaques'),
                      ),
                    ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 50,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      },
                      child: const Text(
                        'Back to album',
                        style: TextStyle(
                          color: kUzinduziRed,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}