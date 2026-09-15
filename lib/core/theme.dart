import 'package:flutter/material.dart';

// ─── Brand ──────────────────────────────────────────────────
const kUzinduziRed     = Color(0xFFFF0000);
const kUzinduziBlack   = Color(0xFF000000);
const kUzinduziWhite   = Color(0xFFFFFFFF);
const kUzinduziGrey    = Color(0xFF8A8A8E);
const kUzinduziSurface = Color(0xFFFFFFFF);
const kUzinduziDivider = Color(0xFFEAEAEA);

// ─── Status ─────────────────────────────────────────────────
const kStatusLive      = Color(0xFF006633); // emerald green — "active"
const kStatusEnded     = Color(0xFF8A8A8E); // grey
const kStatusScheduled = Color(0xFF996633); // gold-brown — "upcoming"
const kStatusPending   = Color(0xFF996633);
const kStatusFailed    = Color(0xFF660000);

// ─── Plaque tiers ───────────────────────────────────────────
const kTierSilver   = Color(0xFF999999);
const kTierGold     = Color(0xFF996633);
const kTierSapphire = Color(0xFF000066);
const kTierEmerald  = Color(0xFF006633);
const kTierCrimson  = Color(0xFF660000);

/// Resolve a plaque tier name to its brand colour.
Color tierColor(String? tier) {
  switch ((tier ?? '').toUpperCase()) {
    case 'SILVER':   return kTierSilver;
    case 'GOLD':     return kTierGold;
    case 'SAPPHIRE': return kTierSapphire;
    case 'EMERALD':  return kTierEmerald;
    case 'CRIMSON':  return kTierCrimson;
    default:         return kUzinduziGrey;
  }
}

/// Minimum contribution (USD) for each tier.
/// Kept client-side for preview only — the server is authoritative.
const kTierThresholds = <String, double>{
  'SILVER':   51,
  'GOLD':     150,
  'SAPPHIRE': 300,
  'EMERALD':  600,
  'CRIMSON':  1000,
};

/// Which tier an amount qualifies for, or null if below the lowest tier.
String? tierForAmount(double amount) {
  // Highest threshold first
  const order = ['CRIMSON', 'EMERALD', 'SAPPHIRE', 'GOLD', 'SILVER'];
  for (final tier in order) {
    if (amount >= (kTierThresholds[tier] ?? double.infinity)) return tier;
  }
  return null;
}

// ─── Theme ──────────────────────────────────────────────────
ThemeData uzinduziTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: kUzinduziRed,
    brightness: Brightness.light,
  ).copyWith(
    primary: kUzinduziRed,
    onPrimary: kUzinduziWhite,
    surface: kUzinduziSurface,
    onSurface: kUzinduziBlack,
    error: kStatusFailed,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: kUzinduziSurface,
    dividerColor: kUzinduziDivider,
    appBarTheme: const AppBarTheme(
      backgroundColor: kUzinduziWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: kUzinduziBlack,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),
    textTheme: const TextTheme(
      headlineLarge:  TextStyle(fontWeight: FontWeight.w800, color: kUzinduziBlack, letterSpacing: -0.6),
      headlineMedium: TextStyle(fontWeight: FontWeight.w700, color: kUzinduziBlack, letterSpacing: -0.4),
      headlineSmall:  TextStyle(fontWeight: FontWeight.w700, color: kUzinduziBlack),
      titleLarge:     TextStyle(fontWeight: FontWeight.w700, color: kUzinduziBlack),
      titleMedium:    TextStyle(fontWeight: FontWeight.w600, color: kUzinduziBlack),
      titleSmall:     TextStyle(fontWeight: FontWeight.w600, color: kUzinduziBlack),
      bodyLarge:      TextStyle(color: kUzinduziBlack),
      bodyMedium:     TextStyle(color: kUzinduziBlack),
      bodySmall:      TextStyle(color: kUzinduziGrey),
      labelLarge:     TextStyle(fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kUzinduziRed,
        foregroundColor: kUzinduziWhite,
        disabledBackgroundColor: kUzinduziRed.withValues(alpha: 0.4),
        disabledForegroundColor: kUzinduziWhite,
        elevation: 0,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kUzinduziBlack,
        side: const BorderSide(color: kUzinduziDivider),
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kUzinduziDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kUzinduziDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kUzinduziRed, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: kUzinduziWhite,
      side: const BorderSide(color: kUzinduziDivider),
      labelStyle: const TextStyle(color: kUzinduziBlack, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
