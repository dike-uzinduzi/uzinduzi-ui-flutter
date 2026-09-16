import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/config.dart';
import '../../../core/theme.dart';
import '../plaque_tier_models.dart';

/// Shows the currently-selected plaque tier — image, name, benefits.
/// When [tier] is null, shows the below-threshold "thank you" state.
class TierPreview extends StatelessWidget {
  final PlaqueTier? tier;

  const TierPreview({super.key, required this.tier});

String _imageFor(PlaqueTier? t) {
  if (t == null) return '${AppConfig.cdnBase}/plaques/thankyou.png';
  final raw = t.imageUrl;
  if (raw == null || raw.isEmpty) return '${AppConfig.cdnBase}/plaques/thankyou.png';
  if (raw.startsWith('http')) return raw;
  return '${AppConfig.cdnBase}/$raw';
}

  
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(anim),
          child: child,
        ),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final key = ValueKey(tier?.slug ?? 'thank_you');

    if (tier == null) {
      return _ThankYouState(key: key);
    }

    final imageUrl = _imageFor(tier);

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            height: 180,
            fit: BoxFit.contain,
            errorWidget: (_, _, _) => Container(
              height: 180,
              alignment: Alignment.center,
              child: Icon(
                Icons.workspace_premium,
                size: 80,
                color: tierColor(tier!.slug).withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
        const SizedBox(height: 20),
        if (tier!.benefits.isEmpty)
          const Center(
            child: Text(
              'Physical plaque shipped to you',
              style: TextStyle(fontSize: 13, color: kUzinduziGrey),
            ),
          )
        else
          ...tier!.benefits.map((b) => _BenefitRow(text: b)),
      ],
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String text;
  const _BenefitRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle, size: 16, color: kStatusLive),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: kUzinduziBlack, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThankYouState extends StatelessWidget {
  const _ThankYouState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: CachedNetworkImage(
            imageUrl: '${AppConfig.cdnBase}/plaques/thankyou.png',
            height: 180,
            fit: BoxFit.contain,
            errorWidget: (_, _, _) => const Icon(Icons.favorite, size: 80, color: kUzinduziGrey),
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'THANK YOU',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: kUzinduziBlack,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Every contribution counts. You won\'t earn a physical plaque at this amount, but you\'re still supporting the artist directly.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: kUzinduziGrey, height: 1.5),
          ),
        ),
      ],
    );
  }
}