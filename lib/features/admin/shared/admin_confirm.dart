import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// Standard admin confirmation dialog.
/// Returns true only if the user explicitly confirms.
Future<bool> showAdminConfirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            confirmLabel,
            style: TextStyle(
              color: danger ? kUzinduziRed : kUzinduziBlack,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
  return result == true;
}