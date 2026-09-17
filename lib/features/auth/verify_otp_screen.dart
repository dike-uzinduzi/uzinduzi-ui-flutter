import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../widgets/auth_error_dialog.dart';
import '../../widgets/otp_input.dart';
import 'auth_controller.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  String _email = '';
  bool _loading = false;
  bool _resending = false;
  int _cooldown = 0;
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['email'] is String) {
      _email = args['email'] as String;
      if (_cooldown == 0) _startCooldown(60);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    _cooldown = seconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _cooldown--;
        if (_cooldown <= 0) t.cancel();
      });
    });
  }

  Future<void> _verify(String code) async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      await ref
          .read(authControllerProvider.notifier)
          .verifyEmail(email: _email, otp: code);
      if (!mounted) return;
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
    } catch (e) {
      if (!mounted) return;
      final message =
          e is AppError ? e.message : 'We couldn\'t verify that code. Please try again.';

      await AuthErrorDialog.show(
        context,
        title: 'Verification failed',
        message: message,
        retryLabel: 'Try again',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    if (_resending || _cooldown > 0) return;
    setState(() => _resending = true);

    try {
      await ref.read(authControllerProvider.notifier).resendOtp(email: _email);
      if (!mounted) return;
      _startCooldown(60);
      // Non-error notification — SnackBar is appropriate here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A new code has been sent to your email.')),
      );
    } catch (e) {
      if (!mounted) return;
      final message =
          e is AppError ? e.message : 'We couldn\'t resend the code. Please try again.';

      await AuthErrorDialog.show(
        context,
        title: 'Couldn\'t resend',
        message: message,
        retryLabel: 'OK',
      );
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kUzinduziWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Check your email',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: kUzinduziBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We sent a 6-digit code to\n$_email',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: kUzinduziGrey),
                  ),
                  const SizedBox(height: 36),
                  OtpInput(
                    onCompleted: _verify,
                  ),
                  const SizedBox(height: 28),
                  if (_loading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: kUzinduziRed,
                      ),
                    )
                  else
                    TextButton(
                      onPressed: _cooldown > 0 ? null : _resend,
                      child: Text(
                        _cooldown > 0
                            ? 'Resend in ${_cooldown}s'
                            : 'Resend code',
                        style: TextStyle(
                          color: _cooldown > 0 ? kUzinduziGrey : kUzinduziRed,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}