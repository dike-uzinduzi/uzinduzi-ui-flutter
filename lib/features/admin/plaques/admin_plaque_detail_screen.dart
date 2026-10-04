import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors.dart';
import '../../../core/theme.dart';
import '../../../widgets/auth_error_dialog.dart';
import '../shared/admin_confirm.dart';
import 'admin_plaque_model.dart';
import 'admin_plaques_provider.dart';

class AdminPlaqueDetailScreen extends ConsumerStatefulWidget {
  const AdminPlaqueDetailScreen({super.key, required this.plaqueId});

  final String plaqueId;

  @override
  ConsumerState<AdminPlaqueDetailScreen> createState() =>
      _AdminPlaqueDetailScreenState();
}

class _AdminPlaqueDetailScreenState
    extends ConsumerState<AdminPlaqueDetailScreen> {
  bool _loading = true;
  bool _busy = false;
  AdminPlaque? _plaque;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final p = await ref
          .read(adminPlaquesRepositoryProvider)
          .get(widget.plaqueId);
      if (!mounted) return;
      setState(() => _plaque = p);
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

  // ─── Transitions ────────────────────────────────────────────
  Future<void> _advance(String to) async {
    final plaque = _plaque!;
    String? tracking;
    String? reason;

    // DELIVERED: ask for tracking + confirm
    if (to == 'DELIVERED') {
      final ctrl = TextEditingController(
        text: plaque.trackingNumber ?? '',
      );
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Mark as delivered'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Confirm the physical plaque reached the owner.',
                style: TextStyle(fontSize: 13, color: kUzinduziGrey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                decoration: const InputDecoration(
                  labelText: 'Tracking number (optional)',
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
              child: const Text(
                'Mark delivered',
                style: TextStyle(
                  color: kUzinduziRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
      tracking = ctrl.text.trim().isEmpty ? null : ctrl.text.trim();
    }

    // CANCELLED: ask for reason
    if (to == 'CANCELLED') {
      final ctrl = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Cancel this plaque?'),
          content: TextField(
            controller: ctrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reason',
              hintText: 'Payment failed, owner request, etc.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Back'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(
                'Cancel plaque',
                style: TextStyle(
                  color: kUzinduziRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
      reason = ctrl.text.trim().isEmpty ? null : ctrl.text.trim();
    }

    // Generic confirm for other transitions
    if (to != 'DELIVERED' && to != 'CANCELLED') {
      final ok = await showAdminConfirm(
        context,
        title: '${plaqueTransitionLabel(to)}?',
        message:
            'Move "${plaque.serialNumber}" from ${plaqueStatusLabel(plaque.status)} to ${plaqueStatusLabel(to)}.',
        confirmLabel: plaqueTransitionLabel(to),
      );
      if (!ok || !mounted) return;
    }

    setState(() => _busy = true);
    try {
      final updated = await ref
          .read(adminPlaquesRepositoryProvider)
          .updateStatus(
            widget.plaqueId,
            status: to,
            trackingNumber: tracking,
            cancellationReason: reason,
          );
      if (!mounted) return;
      setState(() => _plaque = updated);
      ref.invalidate(adminPlaquesProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Moved to ${plaqueStatusLabel(to)}')),
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

  // ─── Notes ──────────────────────────────────────────────────
  Future<void> _editNotes() async {
    final ctrl = TextEditingController(text: _plaque?.adminNotes ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Admin notes'),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Internal notes — never shown to the owner',
            alignLabelWithHint: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final updated = await ref
          .read(adminPlaquesRepositoryProvider)
          .updateNotes(widget.plaqueId, ctrl.text.trim());
      if (!mounted) return;
      setState(() => _plaque = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notes saved')),
      );
    } catch (e) {
      if (!mounted) return;
      await AuthErrorDialog.show(
        context,
        title: 'Save failed',
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
          'Plaque',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: kUzinduziRed),
            )
          : _plaque == null
              ? const Center(
                  child: Text(
                    'Plaque not found',
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
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 180,
                                  height: 180,
                                  child: _plaque!.plaqueImageUrl != null &&
                                          _plaque!
                                              .plaqueImageUrl!.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: _plaque!
                                              .plaqueImageUrl!,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, _, _) =>
                                              Container(
                                            color: kUzinduziDivider,
                                            child: const Icon(
                                              Icons.workspace_premium,
                                              size: 48,
                                              color: kUzinduziGrey,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          color: kUzinduziDivider,
                                          child: const Icon(
                                            Icons.workspace_premium,
                                            size: 48,
                                            color: kUzinduziGrey,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _plaque!.serialNumber,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: kUzinduziBlack,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _plaque!.plaqueType,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: kUzinduziGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        _StatusBanner(plaque: _plaque!),

                        const SizedBox(height: 24),
                        const _SectionLabel('Owner'),
                        _Row(
                          label: 'Name',
                          value: _plaque!.ownerName ?? '—',
                        ),
                        if (_plaque!.ownerEmail != null)
                          _Row(
                            label: 'Email',
                            value: _plaque!.ownerEmail!,
                          ),
                        _Row(
                          label: 'Type',
                          value: _plaque!.ownerType,
                        ),

                        const SizedBox(height: 24),
                        const _SectionLabel('Context'),
                        _Row(
                          label: 'Album',
                          value: _plaque!.albumTitle ?? '—',
                        ),
                        _Row(
                          label: 'Artist',
                          value: _plaque!.artistName ?? '—',
                        ),
                        _Row(
                          label: 'Amount',
                          value:
                              '\$${_plaque!.amount.toStringAsFixed(0)}',
                        ),
                        if (_plaque!.isDemo)
                          const _Row(label: 'Demo', value: 'Yes'),

                        const SizedBox(height: 24),
                        const _SectionLabel('Shipping'),
                        _Row(
                          label: 'Address',
                          value: _plaque!.shippingAddress ?? '—',
                        ),
                        _Row(
                          label: 'Tracking',
                          value: _plaque!.trackingNumber ?? '—',
                        ),

                        const SizedBox(height: 24),
                        const _SectionLabel('Timeline'),
                        if (_plaque!.createdAt != null)
                          _Row(
                            label: 'Created',
                            value: _fmt(_plaque!.createdAt!),
                          ),
                        if (_plaque!.issuedAt != null)
                          _Row(
                            label: 'Issued',
                            value: _fmt(_plaque!.issuedAt!),
                          ),
                        if (_plaque!.deliveredAt != null)
                          _Row(
                            label: 'Delivered',
                            value: _fmt(_plaque!.deliveredAt!),
                          ),
                        if (_plaque!.collectedAt != null)
                          _Row(
                            label: 'Collected',
                            value: _fmt(_plaque!.collectedAt!),
                          ),
                        if (_plaque!.cancelledAt != null)
                          _Row(
                            label: 'Cancelled',
                            value: _fmt(_plaque!.cancelledAt!),
                          ),
                        if (_plaque!.cancelledAt != null &&
                            _plaque!.cancellationReason != null)
                          _Row(
                            label: 'Reason',
                            value: _plaque!.cancellationReason!,
                          ),

                        if (_plaque!.adminNotes != null &&
                            _plaque!.adminNotes!.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const _SectionLabel('Admin notes'),
                          Text(
                            _plaque!.adminNotes!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: kUzinduziBlack,
                              height: 1.5,
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),
                        const Divider(color: kUzinduziDivider),
                        const SizedBox(height: 16),
                        const _SectionLabel('Actions'),

                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ...(_nextStatuses(_plaque!.status)
                                .where((s) => s != 'CANCELLED')
                                .map(
                                  (s) => FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: kUzinduziRed,
                                    ),
                                    onPressed: _busy
                                        ? null
                                        : () => _advance(s),
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                      size: 16,
                                    ),
                                    label: Text(
                                      plaqueTransitionLabel(s),
                                    ),
                                  ),
                                )),
                            OutlinedButton.icon(
                              onPressed: _busy ? null : _editNotes,
                              icon: const Icon(Icons.notes, size: 16),
                              label: const Text('Edit notes'),
                            ),
                          ],
                        ),

                        if (_nextStatuses(_plaque!.status)
                            .contains('CANCELLED')) ...[
                          const SizedBox(height: 24),
                          const Divider(color: kUzinduziDivider),
                          const SizedBox(height: 16),
                          const _SectionLabel('Danger zone'),
                          OutlinedButton.icon(
                            onPressed:
                                _busy ? null : () => _advance('CANCELLED'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kUzinduziRed,
                              side:
                                  const BorderSide(color: kUzinduziRed),
                            ),
                            icon: const Icon(
                              Icons.cancel_outlined,
                              size: 16,
                            ),
                            label: const Text('Cancel plaque'),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Cancelling is terminal. The owner keeps '
                            'their contribution record.',
                            style: TextStyle(
                              fontSize: 12,
                              color: kUzinduziGrey,
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
    );
  }

  List<String> _nextStatuses(String from) =>
      kPlaqueStatusFlow[from] ?? const [];

  static String _fmt(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.plaque});
  final AdminPlaque plaque;

  Color get _color => switch (plaque.status) {
        'PAID' || 'ISSUED' || 'IN_PRODUCTION' => kUzinduziRed,
        'READY_FOR_DELIVERY' => kUzinduziBlack,
        'DELIVERED' || 'COLLECTED' => kStatusLive,
        _ => kUzinduziGrey,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: _color),
          const SizedBox(width: 8),
          Text(
            plaqueStatusLabel(plaque.status).toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: _color,
            ),
          ),
          const Spacer(),
          if (plaque.trackingNumber != null &&
              plaque.trackingNumber!.isNotEmpty)
            Text(
              plaque.trackingNumber!,
              style: const TextStyle(
                fontSize: 12,
                color: kUzinduziGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
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
            width: 100,
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