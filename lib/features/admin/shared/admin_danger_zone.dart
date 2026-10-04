import 'package:flutter/material.dart';

import '../../../core/api_client.dart';
import '../../../core/errors.dart';
import '../../../core/theme.dart';
import '../../../widgets/auth_error_dialog.dart';
import 'admin_confirm.dart';
import 'admin_preflight.dart';

class AdminDangerZone extends StatefulWidget {
  final String resourceLabel;
  final bool isDeleted;
  final Future<bool> Function(bool nextDeleted) onSoftDelete;
  final Future<bool> Function() onHardDelete;
  final Future<AdminPreflight> Function()? preflight;
  final VoidCallback? onHardDeleted;

  const AdminDangerZone({
    super.key,
    required this.resourceLabel,
    required this.isDeleted,
    required this.onSoftDelete,
    required this.onHardDelete,
    this.preflight,
    this.onHardDeleted,
  });

  @override
  State<AdminDangerZone> createState() => _AdminDangerZoneState();
}

class _AdminDangerZoneState extends State<AdminDangerZone> {
  bool _busy = false;

  Future<void> _handleSoftDelete() async {
    final deleting = !widget.isDeleted;
    final ok = await showAdminConfirm(
      context,
      title: deleting
          ? 'Soft-delete ${widget.resourceLabel}?'
          : 'Restore ${widget.resourceLabel}?',
      message: deleting
          ? 'This hides it from the public app. It can be restored later.'
          : 'This will make it visible again.',
      confirmLabel: deleting ? 'Soft-delete' : 'Restore',
      danger: deleting,
    );
    if (!ok || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    setState(() => _busy = true);
    try {
      final success = await widget.onSoftDelete(deleting);
      if (!mounted) return;
      if (success) {
        messenger.showSnackBar(
          SnackBar(content: Text(deleting ? 'Soft-deleted' : 'Restored')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _handleHardDelete() async {
    if (!widget.isDeleted) return;

    AdminPreflight? pf;
    if (widget.preflight != null) {
      setState(() => _busy = true);
      try {
        pf = await widget.preflight!();
      } catch (e) {
        if (!mounted) return;
        await AuthErrorDialog.show(
          context,
          title: 'Cannot check',
          message: e is AppError ? e.message : '$e',
        );
        return;
      } finally {
        if (mounted) setState(() => _busy = false);
      }

      if (!mounted) return;
      if (pf.canHardDelete != true) {
        await AuthErrorDialog.show(
          context,
          title: 'Cannot delete yet',
          message:
              'This ${widget.resourceLabel} still has:\n${pf.blockersMessage}\n\n'
              'Resolve these dependencies first, or keep it soft-deleted.',
        );
        return;
      }
    }

    if (!mounted) return;
    final ok = await showAdminConfirm(
      context,
      title: 'Permanently delete?',
      message:
          'This will permanently delete this ${widget.resourceLabel} and '
          'cannot be undone.',
      confirmLabel: 'Delete forever',
      danger: true,
    );
    if (!ok || !mounted) return;

    setState(() => _busy = true);
    try {
      final success = await widget.onHardDelete();
      if (!mounted) return;
      if (success) {
        widget.onHardDeleted?.call();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deleting = !widget.isDeleted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _busy ? null : _handleSoftDelete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: deleting ? kUzinduziRed : kUzinduziBlack,
                  side: BorderSide(
                    color: deleting ? kUzinduziRed : kUzinduziDivider,
                  ),
                ),
                icon: Icon(
                  deleting ? Icons.visibility_off_outlined : Icons.restore,
                  size: 16,
                ),
                label: Text(deleting ? 'Soft-delete' : 'Restore'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    (_busy || !widget.isDeleted) ? null : _handleHardDelete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: kUzinduziRed,
                  side: const BorderSide(color: kUzinduziRed),
                ),
                icon: const Icon(Icons.delete_forever_outlined, size: 16),
                label: const Text('Delete forever'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.isDeleted
              ? 'This ${widget.resourceLabel} is soft-deleted. Hard-delete '
                  'is available if no dependencies remain.'
              : 'Soft-delete hides this from the public app. Hard-delete '
                  'unlocks only after soft-delete.',
          style: const TextStyle(fontSize: 12, color: kUzinduziGrey),
        ),
      ],
    );
  }
}

Future<AdminPreflight> preflightAlbum(ApiClient api, String albumId) =>
    fetchPreflight(api, 'album', albumId);