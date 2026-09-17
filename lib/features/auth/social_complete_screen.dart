import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../widgets/auth_error_dialog.dart';
import '../../widgets/role_picker.dart';
import 'auth_controller.dart';

class SocialCompleteScreen extends ConsumerStatefulWidget {
  const SocialCompleteScreen({super.key});

  @override
  ConsumerState<SocialCompleteScreen> createState() =>
      _SocialCompleteScreenState();
}

class _SocialCompleteScreenState extends ConsumerState<SocialCompleteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  String _role = 'fan';
  bool _loading = false;
  String _pendingToken = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['pendingToken'] is String) {
      _pendingToken = args['pendingToken'] as String;
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pendingToken.isEmpty) {
      await AuthErrorDialog.show(
        context,
        title: 'Session expired',
        message:
            'Your signup session has expired. Please sign in with Google again.',
        retryLabel: 'OK',
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await ref.read(authControllerProvider.notifier).socialComplete(
            pendingToken: _pendingToken,
            userName: _userNameController.text.trim(),
            role: _role,
          );
      if (!mounted) return;
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
    } catch (e) {
      if (!mounted) return;
      final message = e is AppError
          ? e.message
          : 'We couldn\'t finish setting up your account. Please try again.';

      await AuthErrorDialog.show(
        context,
        title: 'Couldn\'t finish signup',
        message: message,
        retryLabel: 'Try again',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kUzinduziWhite,
      appBar: AppBar(automaticallyImplyLeading: false),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Almost there',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: kUzinduziBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pick a username and tell us who you are.',
                      style: TextStyle(fontSize: 14, color: kUzinduziGrey),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _userNameController,
                      enabled: !_loading,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Username is required';
                        }
                        if (v.trim().length < 3) return 'At least 3 characters';
                        if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(v.trim())) {
                          return 'Letters, numbers, dot, underscore only';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'I am a...',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kUzinduziBlack,
                      ),
                    ),
                    const SizedBox(height: 10),
                    RolePicker(
                      value: _role,
                      onChanged: (r) => setState(() => _role = r),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Finish signup'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}