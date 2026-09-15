import 'package:flutter/material.dart';

import '../core/theme.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;
  final String label;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.loading = false,
    this.label = 'Continue with Google',
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;

    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: disabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: kUzinduziWhite,
          foregroundColor: kUzinduziBlack,
          side: const BorderSide(color: kUzinduziDivider, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              )
            else
              Image.asset(
                'assets/icon/google-g.png',
                width: 22,
                height: 22,
                filterQuality: FilterQuality.high,
              ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: kUzinduziBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}