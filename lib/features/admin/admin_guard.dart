import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';

bool isAdminUser(WidgetRef ref) {
  final user = ref.read(authControllerProvider).valueOrNull;
  if (user == null) return false;
  return user.role == 'admin' || user.role == 'super_admin';
}

Future<void> ensureAdmin(BuildContext context, WidgetRef ref) async {
  if (isAdminUser(ref)) return;
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Admin access required')),
    );
    Navigator.of(context).maybePop();
  }
}
