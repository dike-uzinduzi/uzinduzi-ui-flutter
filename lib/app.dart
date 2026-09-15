import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/auth_controller.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';

class UzinduziApp extends ConsumerWidget {
  const UzinduziApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Uzinduzi',
      debugShowCheckedModeBanner: false,
      theme: _theme(),
      home: const _Root(),
    );
  }

  ThemeData _theme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF444F),
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: false,
      ),
    );
  }
}

class _Root extends ConsumerWidget {
  const _Root();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return auth.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        body: Center(child: Text('Startup error: $err')),
      ),
      data: (user) {
        if (user == null) return const LoginScreen();
        return const HomeScreen();
      },
    );
  }
}
