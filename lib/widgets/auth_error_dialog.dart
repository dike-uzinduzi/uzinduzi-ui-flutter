import 'package:flutter/material.dart';

import '../core/theme.dart';

class AuthErrorDialog extends StatelessWidget {
  const AuthErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.retryLabel = 'Try again',
  });

  final String title;
  final String message;
  final String retryLabel;

  /// Show the dialog and return when the user dismisses it.
  /// The dialog grabs focus, blocks interaction with the form behind it,
  /// and dismisses via the button (or back gesture / Esc).
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String retryLabel = 'Try again',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => AuthErrorDialog(
        title: title,
        message: message,
        retryLabel: retryLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Icon ─────────────────────────────
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: kStatusFailed.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: kStatusFailed,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ── Title ────────────────────────────
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kUzinduziBlack,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),

              // ── Message ──────────────────────────
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: kUzinduziGrey,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),

              // ── Retry button ─────────────────────
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kUzinduziRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Text(
                    retryLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // ── Optional cancel ──────────────────
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: kUzinduziGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}