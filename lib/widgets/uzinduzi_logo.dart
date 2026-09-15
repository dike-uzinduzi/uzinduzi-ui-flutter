import 'package:flutter/material.dart';

enum LogoVariant { wordmark, launchSymbol }

/// Brand mark loader.
///
/// - [LogoVariant.wordmark]     "UZINDUZI" wordmark
/// - [LogoVariant.launchSymbol] the launch symbol (main logo)
///
/// Set [onDark] when the background is red or dark so the white
/// variant of the asset is used.
class UzinduziLogo extends StatelessWidget {
  final LogoVariant variant;
  final double height;
  final bool onDark;

  const UzinduziLogo({
    super.key,
    this.variant = LogoVariant.wordmark,
    this.height = 40,
    this.onDark = false,
  });

  String get _asset {
    switch (variant) {
      case LogoVariant.wordmark:
        return onDark
            ? 'assets/icon/wordmark-white-nd.png'
            : 'assets/icon/wordmark-black-nd.png';
      case LogoVariant.launchSymbol:
        return onDark
            ? 'assets/icon/launch-symbol-white.png'
            : 'assets/icon/launch-symbol-black.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _asset,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
