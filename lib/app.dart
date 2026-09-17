import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routes.dart';
import 'core/theme.dart';
import 'features/admin/admin_shell.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/reset_password_screen.dart';
import 'features/auth/social_complete_screen.dart';
import 'features/auth/verify_otp_screen.dart';
import 'features/home/home_shell.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/profile/profile_tab.dart';

class UzinduziApp extends ConsumerWidget {
  const UzinduziApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'UzinduziAfrica',
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
        AppRoutes.profile:        (_) => const _ProfileRoute(),
        AppRoutes.admin:          (_) => const AdminShell(),
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

/// Full-screen profile route with a back button.
///
/// `ProfileTab` normally renders inside `HomeShell` (no back button needed).
/// When pushed as its own route, this wrapper supplies the AppBar and back
/// navigation so the user isn't stranded.
class _ProfileRoute extends StatelessWidget {
  const _ProfileRoute();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kUzinduziWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: const ProfileTab(showAppBar: false),
    );
  }
}