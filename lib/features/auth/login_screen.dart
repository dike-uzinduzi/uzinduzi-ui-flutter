import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../widgets/auth_error_dialog.dart';
import '../../widgets/social_button.dart';
import '../../widgets/uzinduzi_logo.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _googleLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
Future<void> _submit() async {

  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() => _loading = true);

  try {
    await ref.read(authControllerProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  } catch (e ) {
  

    if (!mounted) return;

    final message = e is AppError
        ? e.message
        : 'We couldn\'t sign you in. Check your details and try again.';

    _passwordController.clear();

    await AuthErrorDialog.show(
      context,
      title: 'Sign-in failed',
      message: message,
      retryLabel: 'Try again',
    );

  } finally {
    if (mounted) setState(() => _loading = false);
  }
}
  Future<void> _googleSignIn() async {
    setState(() => _googleLoading = true);

    try {
      final pendingToken =
          await ref.read(authControllerProvider.notifier).googleLogin();

      if (!mounted) return;
      if (pendingToken != null) {
        Navigator.of(context).pushNamed(
          AppRoutes.socialComplete,
          arguments: {'pendingToken': pendingToken},
        );
      }
    } catch (e) {
      if (!mounted) return;
      final message = e is AppError
          ? e.message
          : 'Google sign-in failed. Please try again.';

      await AuthErrorDialog.show(
        context,
        title: 'Google sign-in failed',
        message: message,
      );
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: kUzinduziWhite,
    
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: UzinduziLogo(
                      variant: LogoVariant.launchSymbol,
                      height: 52,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Launch Big, Grow Bigger',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: kUzinduziGrey),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Welcome back',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: kUzinduziBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Login to continue',
                    style: TextStyle(fontSize: 14, color: kUzinduziGrey),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_loading && !_googleLoading,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Email is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    enabled: !_loading && !_googleLoading,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Password is required' : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _loading || _googleLoading
                          ? null
                          : () => Navigator.of(context)
                              .pushNamed(AppRoutes.forgotPassword),
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: kUzinduziRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _loading || _googleLoading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Row(children: [
                    Expanded(child: Divider(color: kUzinduziDivider)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or',
                        style: TextStyle(
                          color: kUzinduziGrey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: kUzinduziDivider)),
                  ]),
                  const SizedBox(height: 20),
                  GoogleSignInButton(
                    onPressed: _googleSignIn,
                    loading: _googleLoading,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'New here? ',
                        style: TextStyle(color: kUzinduziGrey),
                      ),
                      TextButton(
                        onPressed: _loading || _googleLoading
                            ? null
                            : () => Navigator.of(context)
                                .pushNamed(AppRoutes.register),
                        child: const Text(
                          'Create an account',
                          style: TextStyle(
                            color: kUzinduziRed,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}}