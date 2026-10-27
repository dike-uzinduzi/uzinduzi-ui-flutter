import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors.dart';
import '../../../core/theme.dart';
import '../../../widgets/auth_error_dialog.dart';
import 'admin_payment_model.dart';
import 'admin_payments_provider.dart';

class AdminPaymentDetailScreen extends ConsumerStatefulWidget {
  const AdminPaymentDetailScreen({super.key, required this.paymentId});

  final String paymentId;

  @override
  ConsumerState<AdminPaymentDetailScreen> createState() =>
      _AdminPaymentDetailScreenState();
}

class _AdminPaymentDetailScreenState
    extends ConsumerState<AdminPaymentDetailScreen> {
  bool _loading = true;
  bool _busy = false;
  AdminPayment? _payment;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final p = await ref
          .read(adminPaymentsRepositoryProvider)
          .get(widget.paymentId);
      if (!mounted) return;
      setState(() => _payment = p);
    } catch (e) {
      if (!mounted) return;
      await AuthErrorDialog.show(
        context,
        title: 'Load failed',
        message: e is AppError ? e.message : '$e',
      );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changeStatus(String next) async {
    final reasonCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Mark as ${paymentStatusLabel(next)}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Change status from "${paymentStatusLabel(_payment!.status)}" '
              'to "${paymentStatusLabel(next)}".',
              style: const TextStyle(fontSize: 13, color: kUzinduziGrey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'Why the status changed',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Mark ${paymentStatusLabel(next)}',
              style: const TextStyle(
                color: kUzinduziRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final updated = await ref
          .read(adminPaymentsRepositoryProvider)
          .updateStatus(
            widget.paymentId,
            status: next,
            reason:
                reasonCtrl.text.trim().isEmpty ? null : reasonCtrl.text.trim(),
          );
      if (!mounted) return;
      setState(() => _payment = updated);
      ref.invalidate(adminPaymentsProvider);
      ref.invalidate(adminPaymentsStatsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Marked as ${paymentStatusLabel(next)}')),
      );
    } catch (e) {
      if (!mounted) return;
      await AuthErrorDialog.show(
        context,
        title: 'Update failed',
        message: e is AppError ? e.message : '$e',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kUzinduziWhite,
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: kUzinduziRed),
            )
          : _payment == null
              ? const Center(
                  child: Text(
                    'Payment not found',
                    style: TextStyle(color: kUzinduziGrey),
                  ),
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Text(
                                _payment!.amountLabel,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: kUzinduziBlack,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: paymentStatusColor(
                                    _payment!.status,
                                    () => kUzinduziGrey,
                                  )
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  paymentStatusLabel(_payment!.status)
                                      .toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: paymentStatusColor(
                                      _payment!.status,
                                      () => kUzinduziGrey,
                                    ),
                                  ),
                                ),
                              ),
                              if (_payment!.isDemo) ...[
                                const SizedBox(height: 6),
                                const Text(
                                  'DEMO',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                    color: kUzinduziGrey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        const _SectionLabel('Reference'),
                        _Row(
                          label: 'Reference',
                          value: _payment!.referenceNumber,
                        ),
                        if (_payment!.ecocashReference != null)
                          _Row(
                            label: 'Ecocash ref',
                            value: _payment!.ecocashReference!,
                          ),

                        const SizedBox(height: 24),
                        const _SectionLabel('Customer'),
                        _Row(
                          label: 'Name',
                          value: _payment!.userName ?? '—',
                        ),
                        _Row(
                          label: 'Email',
                          value: _payment!.userEmail ??
                              _payment!.customerEmail ??
                              '—',
                        ),
                        if (_payment!.customerPhone != null)
                          _Row(
                            label: 'Phone',
                            value: _payment!.customerPhone!,
                          ),

                        const SizedBox(height: 24),
                        const _SectionLabel('Context'),
                        _Row(
                          label: 'Album',
                          value: _payment!.albumTitle ?? '—',
                        ),
                        _Row(
                          label: 'Method',
                          value: paymentMethodLabel(_payment!.paymentMethod),
                        ),
                        if (_payment!.plaqueType != null)
                          _Row(
                            label: 'Plaque type',
                            value: _payment!.plaqueType!,
                          ),
                        if (_payment!.qualifiedTier != null)
                          _Row(
                            label: 'Qualified tier',
                            value: _payment!.qualifiedTier!,
                          ),
                        if (_payment!.qualifiesForPlaque != null)
                          _Row(
                            label: 'Plaque eligible',
                            value: _payment!.qualifiesForPlaque! ? 'Yes' : 'No',
                          ),
                        if (_payment!.plaqueSerial != null)
                          _Row(
                            label: 'Plaque serial',
                            value: _payment!.plaqueSerial!,
                          ),

                        if (_payment!.reason != null &&
                            _payment!.reason!.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const _SectionLabel('Reason'),
                          Text(
                            _payment!.reason!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: kUzinduziBlack,
                              height: 1.5,
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),
                        const _SectionLabel('Timeline'),
                        if (_payment!.createdAt != null)
                          _Row(
                            label: 'Created',
                            value: _fmt(_payment!.createdAt!),
                          ),
                        if (_payment!.updatedAt != null)
                          _Row(
                            label: 'Updated',
                            value: _fmt(_payment!.updatedAt!),
                          ),

                        const SizedBox(height: 24),
                        const Divider(color: kUzinduziDivider),
                        const SizedBox(height: 16),
                        const _SectionLabel('Change status'),

                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            for (final s in kPaymentStatuses)
                              if (s != _payment!.status)
                                OutlinedButton.icon(
                                  onPressed: _busy
                                      ? null
                                      : () => _changeStatus(s),
                                  icon: const Icon(
                                    Icons.arrow_forward,
                                    size: 16,
                                  ),
                                  label: Text(paymentStatusLabel(s)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor:
                                        paymentStatusColor(
                                      s,
                                      () => kUzinduziBlack,
                                    ),
                                  ),
                                ),
                          ],
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
    );
  }

  static String _fmt(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: kUzinduziGrey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kUzinduziBlack,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: kUzinduziGrey,
        ),
      ),
    );
  }
}