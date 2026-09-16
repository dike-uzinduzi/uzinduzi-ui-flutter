import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../albums/plaque_tier_models.dart';
import 'success_screen.dart';
import 'support_providers.dart';

class PaymentPendingScreen extends ConsumerStatefulWidget {
  final String albumId;
  final String albumTitle;
  final String artistName;
  final String? coverArt;
  final PlaqueTier? tier;
  final double amount;
  final String referenceNumber;
  final Map<String, dynamic>? shippingAddress;

  const PaymentPendingScreen({
    super.key,
    required this.albumId,
    required this.albumTitle,
    required this.artistName,
    this.coverArt,
    required this.tier,
    required this.amount,
    required this.referenceNumber,
    this.shippingAddress,
  });

  @override
  ConsumerState<PaymentPendingScreen> createState() => _PaymentPendingScreenState();
}

class _PaymentPendingScreenState extends ConsumerState<PaymentPendingScreen> {
  static const _pollInterval = Duration(seconds: 3);
  static const _timeout = Duration(seconds: 30); // change to minutes: 5 for production

  Timer? _pollTimer;
  Timer? _tickTimer;
  DateTime? _startedAt;
  Duration _remaining = _timeout;
  String _status = 'Waiting for payment...';
  bool _done = false;
  bool _timedOut = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _remaining = _timeout;

    _poll();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _tickTimer?.cancel();
    super.dispose();
  }

  void _tick() {
    if (!mounted || _done) return;
    final elapsed = DateTime.now().difference(_startedAt!);
    final left = _timeout - elapsed;
    if (left.isNegative) {
      _handleTimeout();
      return;
    }
    setState(() => _remaining = left);
  }

  void _handleTimeout() {
    if (_done) return;
    _done = true;
    _pollTimer?.cancel();
    _tickTimer?.cancel();

    final mins = _timeout.inMinutes;
    final secs = _timeout.inSeconds % 60;
    final label = mins > 0
        ? '$mins minute${mins == 1 ? '' : 's'}'
        : '$secs second${secs == 1 ? '' : 's'}';

    setState(() {
      _timedOut = true;
      _status = 'Payment not confirmed within $label.';
    });
  }

  Future<void> _poll() async {
    if (_done) return;

    try {
      final s = await ref
          .read(supportRepositoryProvider)
          .checkStatus(widget.referenceNumber);

      if (!mounted || _done) return;

      // Success
      if (s.status == 'SUCCESS' || s.paid) {
        _done = true;
        _pollTimer?.cancel();
        _tickTimer?.cancel();

        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;

        final result = await ref
            .read(supportRepositoryProvider)
            .fetchResult(widget.referenceNumber);

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => SuccessScreen(
              albumTitle: widget.albumTitle,
              artistName: widget.artistName,
              tier: widget.tier,
              amount: widget.amount,
              result: result,
              shippingAddress: widget.shippingAddress,
            ),
          ),
        );
        return;
      }

      // Failed
      if (s.status == 'FAILED') {
        _done = true;
        _pollTimer?.cancel();
        _tickTimer?.cancel();
        setState(() {
          _failed = true;
          _status = 'Payment failed. Please try again.';
        });
        return;
      }

      // Still pending
      setState(() => _status = 'Waiting for confirmation...');
    } catch (_) {
      // Network hiccup — keep polling
    }
  }

  String _formatRemaining(Duration d) {
    if (d.inMinutes < 1) return '${d.inSeconds}s';
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final terminated = _failed || _timedOut;

    return Scaffold(
      backgroundColor: kUzinduziWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Processing payment',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (!terminated)
            TextButton(
              onPressed: () {
                _done = true;
                _pollTimer?.cancel();
                _tickTimer?.cancel();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: kUzinduziRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!terminated)
                  const SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: kUzinduziRed,
                    ),
                  )
                else if (_timedOut)
                  const Icon(Icons.schedule, size: 56, color: kStatusScheduled)
                else
                  const Icon(Icons.error_outline, size: 56, color: kStatusFailed),

                const SizedBox(height: 24),

                Text(
                  _failed
                      ? 'Payment failed'
                      : _timedOut
                          ? 'Timed out'
                          : 'Please wait',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kUzinduziBlack,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: kUzinduziGrey),
                ),

                // Countdown badge
                if (!terminated) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: kUzinduziRed.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: kUzinduziRed),
                        const SizedBox(width: 6),
                        Text(
                          _formatRemaining(_remaining),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kUzinduziRed,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                Text(
                  'Reference: ${widget.referenceNumber}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: kUzinduziGrey,
                  ),
                ),

                if (_timedOut) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'If you completed the payment, it may still confirm. '
                    'Check your plaques in a few minutes, or contact support '
                    'with the reference above.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: kUzinduziGrey, height: 1.5),
                  ),
                ],

                if (terminated) ...[
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Try again'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((r) => r.isFirst);
                    },
                    child: const Text(
                      'Back to home',
                      style: TextStyle(
                        color: kUzinduziGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}