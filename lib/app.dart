import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routes.dart';
import 'core/theme.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/reset_password_screen.dart';
import 'features/auth/social_complete_screen.dart';
import 'features/auth/verify_otp_screen.dart';
import 'features/home/home_shell.dart';
import 'features/notifications/notifications_screen.dart';

class UzinduziApp extends ConsumerWidget {
  const UzinduziApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Uzinduzi',
      debugShowCheckedModeBanner: false,
      theme: uzinduziTheme(),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login:          (_) => const _AuthGate(),
        AppRoutes.register:       (_) => const RegisterScreen(),
        AppRoutes.verifyOtp:      (_) => const VerifyOtpScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.resetPassword:  (_) => const ResetPasswordScreen(),
        AppRoutes.socialComplete: (_) => const SocialCompleteScreen(),
        AppRoutes.home:           (_) => const HomeShell(),
        AppRoutes.notifications:  (_) => const NotificationsScreen(),
      },
    );
  }
}

class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    // Splash only during the very first bootstrap (before we know auth status)
    if (auth.isLoading && !auth.hasValue) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: kUzinduziRed),
        ),
      );
    }

    // Any error or "no user" -> stay on the login screen.
    // Login failures are shown via AuthErrorDialog inside LoginScreen.
    final user = auth.valueOrNull;
    if (user == null) {
      return const LoginScreen();
    }

    return const HomeShell();
  }
}