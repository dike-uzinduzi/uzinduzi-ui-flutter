import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors.dart';
import '../../../core/theme.dart';
import '../../../features/albums/album_models.dart';
import '../../../features/albums/tiers_provider.dart';
import '../../../features/albums/plaque_tier_models.dart';
import '../../../widgets/auth_error_dialog.dart';
import '../shared/admin_confirm.dart';
import 'admin_album_launch_provider.dart';

class AdminAlbumLaunchScreen extends ConsumerStatefulWidget {
  const AdminAlbumLaunchScreen({
    super.key,
    required this.albumId,
    required this.albumTitle,
  });

  final String albumId;
  final String albumTitle;

  @override
  ConsumerState<AdminAlbumLaunchScreen> createState() =>
      _AdminAlbumLaunchScreenState();
}

class _AdminAlbumLaunchScreenState
    extends ConsumerState<AdminAlbumLaunchScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final launchAsync =
        ref.watch(adminAlbumLaunchProvider(widget.albumId));

    return Scaffold(
      backgroundColor: kUzinduziWhite,
      appBar: AppBar(
        title: const Text(
          'Album launch',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: launchAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: kUzinduziRed)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              '$e',
              textAlign: TextAlign.center,
              style: const TextStyle(color: kUzinduziGrey),
            ),
          ),
        ),
        data: (launch) => launch == null
            ? _NoLaunchView(
                albumId: widget.albumId,
                albumTitle: widget.albumTitle,
                busy: _busy,
                onCreate: _openCreate,
              )
            : _ExistingLaunchView(
                albumId: widget.albumId,
                launch: launch,
                busy: _busy,
                onEdit: () => _openEdit(launch),
                onStatusChange: (s) => _changeStatus(launch, s),
                onCancel: () => _cancel(launch),
              ),
      ),
    );
  }

  Future<void> _openCreate() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _LaunchFormScreen(
          albumId: widget.albumId,
          albumTitle: widget.albumTitle,
          existing: null,
        ),
      ),
    );
    if (created == true) {
      ref.invalidate(adminAlbumLaunchProvider(widget.albumId));
    }
  }

  Future<void> _openEdit(AlbumLaunch launch) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _LaunchFormScreen(
          albumId: widget.albumId,
          albumTitle: widget.albumTitle,
          existing: launch,
        ),
      ),
    );
    if (changed == true) {
      ref.invalidate(adminAlbumLaunchProvider(widget.albumId));
    }
  }

  Future<void> _changeStatus(AlbumLaunch launch, String next) async {
    final ok = await showAdminConfirm(
      context,
      title: 'Change status to "$next"?',
      message: _statusChangeMessage(launch.status, next),
      confirmLabel: 'Change status',
    );
    if (!ok) return;

    setState(() => _busy = true);
    try {
      await ref.read(adminLaunchRepositoryProvider).update(
            widget.albumId,
            status: next,
          );
      if (!mounted) return;
      ref.invalidate(adminAlbumLaunchProvider(widget.albumId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status changed to $next')),
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

  String _statusChangeMessage(String from, String to) {
    if (to == 'active') {
      return 'The launch will be visible as live on the public app. '
          'Supporters can earn plaque tiers immediately.';
    }
    if (to == 'ended') {
      return 'The launch will be marked as ended. '
          'The public countdown will stop and further supports will not '
          'count towards plaque thresholds.';
    }
    if (to == 'scheduled') {
      return 'The launch will return to the scheduled state. '
          'The countdown will resume.';
    }
    return 'Status will change from "$from" to "$to".';
  }

  Future<void> _cancel(AlbumLaunch launch) async {
    final ok = await showAdminConfirm(
      context,
      title: 'Cancel launch?',
      message:
          'This removes the launch entirely, including tier thresholds. '
          'Supporter contributions are not affected. Cannot be undone.',
      confirmLabel: 'Cancel launch',
      danger: true,
    );
    if (!ok) return;

    setState(() => _busy = true);
    try {
      await ref.read(adminLaunchRepositoryProvider).cancel(widget.albumId);
      if (!mounted) return;
      ref.invalidate(adminAlbumLaunchProvider(widget.albumId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Launch cancelled')),
      );
    } catch (e) {
      if (!mounted) return;
      await AuthErrorDialog.show(
        context,
        title: 'Cancel failed',
        message: e is AppError ? e.message : '$e',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

// ─────────────────────────────────────────────────────────────
// No launch yet
// ─────────────────────────────────────────────────────────────
class _NoLaunchView extends StatelessWidget {
  const _NoLaunchView({
    required this.albumId,
    required this.albumTitle,
    required this.busy,
    required this.onCreate,
  });

  final String albumId;
  final String albumTitle;
  final bool busy;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.rocket_launch_outlined,
                size: 56,
                color: kUzinduziGrey,
              ),
              const SizedBox(height: 16),
              const Text(
                'No launch scheduled',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: kUzinduziBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Set up a launch window for "$albumTitle" to let fans '
                'support the album and earn plaque tiers before the '
                'physical launch.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: kUzinduziGrey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: busy ? null : onCreate,
                style: FilledButton.styleFrom(
                  backgroundColor: kUzinduziRed,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Schedule launch'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Existing launch
// ─────────────────────────────────────────────────────────────
class _ExistingLaunchView extends StatelessWidget {
  const _ExistingLaunchView({
    required this.albumId,
    required this.launch,
    required this.busy,
    required this.onEdit,
    required this.onStatusChange,
    required this.onCancel,
  });

  final String albumId;
  final AlbumLaunch launch;
  final bool busy;
  final VoidCallback onEdit;
  final ValueChanged<String> onStatusChange;
  final VoidCallback onCancel;

  Color get _statusColor => switch (launch.status) {
        'active' => kStatusLive,
        'scheduled' => kUzinduziRed,
        'ended' => kUzinduziGrey,
        _ => kUzinduziGrey,
      };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Status header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _statusColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 10, color: _statusColor),
                  const SizedBox(width: 8),
                  Text(
                    launch.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: _statusColor,
                    ),
                  ),
                  const Spacer(),
                  if (launch.status == 'active')
                    Text(
                      'Ends in ${_humanize(launch.remaining)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: kUzinduziGrey,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _SectionLabel('Window'),
            _Row(
              icon: Icons.event_outlined,
              label: 'Starts',
              value: _fmt(launch.startsAt),
            ),
            _Row(
              icon: Icons.event_busy_outlined,
              label: 'Ends',
              value: _fmt(launch.endsAt),
            ),
            _Row(
              icon: Icons.place_outlined,
              label: 'Physical launch',
              value: launch.physicalLaunchAt == null
                  ? 'Not set'
                  : _fmt(launch.physicalLaunchAt!),
            ),

            const SizedBox(height: 24),
            _SectionLabel('Tier thresholds'),
            if (launch.tierThresholds.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No thresholds set. Supports will not unlock tier plaques.',
                  style: TextStyle(fontSize: 13, color: kUzinduziGrey),
                ),
              )
            else
              ...launch.tierThresholds.map(
                (t) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: kUzinduziRed.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          t.tier.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: kUzinduziRed,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '≥ \$${t.minAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kUzinduziBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),
            _SectionLabel('Actions'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed: busy ? null : onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit window'),
                ),
                if (launch.status != 'active')
                  OutlinedButton.icon(
                    onPressed: busy
                        ? null
                        : () => onStatusChange('active'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kStatusLive,
                      side: const BorderSide(color: kStatusLive),
                    ),
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Activate now'),
                  ),
                if (launch.status != 'scheduled')
                  OutlinedButton.icon(
                    onPressed: busy
                        ? null
                        : () => onStatusChange('scheduled'),
                    icon: const Icon(Icons.schedule, size: 16),
                    label: const Text('Set to scheduled'),
                  ),
                if (launch.status != 'ended')
                  OutlinedButton.icon(
                    onPressed: busy
                        ? null
                        : () => onStatusChange('ended'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kUzinduziGrey,
                    ),
                    icon: const Icon(Icons.stop, size: 16),
                    label: const Text('Mark ended'),
                  ),
              ],
            ),

            const SizedBox(height: 32),
            const Divider(color: kUzinduziDivider),
            const SizedBox(height: 16),
            _SectionLabel('Danger zone'),
            OutlinedButton.icon(
              onPressed: busy ? null : onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: kUzinduziRed,
                side: const BorderSide(color: kUzinduziRed),
              ),
              icon: const Icon(Icons.delete_forever_outlined, size: 16),
              label: const Text('Cancel launch entirely'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Removes the launch and its tier thresholds. '
              'Supporter contributions are preserved.',
              style: TextStyle(fontSize: 12, color: kUzinduziGrey),
            ),
          ],
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

  static String _humanize(Duration d) {
    if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    return '${d.inMinutes}m';
  }
}

// ─────────────────────────────────────────────────────────────
// Create / Edit form
// ─────────────────────────────────────────────────────────────
class _LaunchFormScreen extends ConsumerStatefulWidget {
  const _LaunchFormScreen({
    required this.albumId,
    required this.albumTitle,
    required this.existing,
  });

  final String albumId;
  final String albumTitle;
  final AlbumLaunch? existing;

  @override
  ConsumerState<_LaunchFormScreen> createState() => _LaunchFormScreenState();
}

class _LaunchFormScreenState extends ConsumerState<_LaunchFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _startsAt;
  late DateTime _endsAt;
  DateTime? _physicalLaunchAt;

  final List<_ThresholdRow> _thresholds = [];
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;

    if (e != null) {
      _startsAt = e.startsAt;
      _endsAt = e.endsAt;
      _physicalLaunchAt = e.physicalLaunchAt;
      for (final t in e.tierThresholds) {
        _thresholds.add(_ThresholdRow(
          tier: t.tier,
          minAmount: t.minAmount,
        ));
      }
    } else {
      final now = DateTime.now();
      _startsAt = now;
      _endsAt = now.add(const Duration(days: 30));
    }
  }

  @override
  void dispose() {
    for (final t in _thresholds) {
      t.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDateTime({
    required DateTime initial,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;

    onPicked(DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_endsAt.isAfter(_startsAt)) {
      await AuthErrorDialog.show(
        context,
        title: 'Invalid window',
        message: 'End time must be after start time.',
      );
      return;
    }

    final thresholds = _thresholds
        .where((t) => t.isValid)
        .map((t) => TierThreshold(
              tier: t.tierController.text.trim().toUpperCase(),
              minAmount: double.parse(t.amountController.text.trim()),
            ))
        .toList();

    setState(() => _saving = true);
    try {
      final repo = ref.read(adminLaunchRepositoryProvider);
      if (_isEditing) {
        await repo.update(
          widget.albumId,
          startsAt: _startsAt,
          endsAt: _endsAt,
          physicalLaunchAt: _physicalLaunchAt,
          tierThresholds: thresholds,
        );
      } else {
        await repo.create(
          widget.albumId,
          startsAt: _startsAt,
          endsAt: _endsAt,
          physicalLaunchAt: _physicalLaunchAt,
          tierThresholds: thresholds,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Launch updated' : 'Launch scheduled')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      await AuthErrorDialog.show(
        context,
        title: 'Save failed',
        message: e is AppError ? e.message : '$e',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kUzinduziWhite,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit launch' : 'Schedule launch',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _isEditing ? 'Save' : 'Schedule',
                    style: const TextStyle(
                      color: kUzinduziRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  widget.albumTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kUzinduziGrey,
                  ),
                ),
                const SizedBox(height: 24),

                _SectionLabel('Launch window'),
                _DateField(
                  label: 'Starts',
                  value: _startsAt,
                  onTap: () => _pickDateTime(
                    initial: _startsAt,
                    onPicked: (d) => setState(() => _startsAt = d),
                  ),
                ),
                const SizedBox(height: 12),
                _DateField(
                  label: 'Ends',
                  value: _endsAt,
                  onTap: () => _pickDateTime(
                    initial: _endsAt,
                    onPicked: (d) => setState(() => _endsAt = d),
                  ),
                ),
                const SizedBox(height: 12),
                _DateField(
                  label: 'Physical launch date (optional)',
                  value: _physicalLaunchAt,
                  onTap: () => _pickDateTime(
                    initial: _physicalLaunchAt ?? _endsAt,
                    onPicked: (d) => setState(() => _physicalLaunchAt = d),
                  ),
                  onClear: _physicalLaunchAt != null
                      ? () => setState(() => _physicalLaunchAt = null)
                      : null,
                ),

                const SizedBox(height: 24),
                Row(
                  children: [
                    const _SectionLabel('Tier thresholds'),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _thresholds.add(_ThresholdRow());
                        });
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add tier'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Set the minimum amount each tier requires during this launch.',
                  style: TextStyle(fontSize: 12, color: kUzinduziGrey),
                ),
                const SizedBox(height: 12),
                if (_thresholds.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No thresholds. Supports will not unlock tiers.',
                      style: TextStyle(color: kUzinduziGrey),
                    ),
                  ),
                for (var i = 0; i < _thresholds.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _thresholds[i].tierController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              labelText: 'Tier ${i + 1} (e.g. GOLD)',
                              isDense: true,
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _thresholds[i].amountController,
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Min amount',
                              prefixText: '\$ ',
                              isDense: true,
                            ),
                            validator: (v) {
                              if (_thresholds[i].isEmpty) return null;
                              final n = double.tryParse((v ?? '').trim());
                              if (n == null || n < 0) return 'Invalid';
                              return null;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            setState(() {
                              _thresholds[i].dispose();
                              _thresholds.removeAt(i);
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),
                _SectionLabel('Quick fill from plaque tiers'),
                const SizedBox(height: 8),
                _ThresholdPresets(
                  onApply: (thresholds) {
                    setState(() {
                      for (final t in _thresholds) {
                        t.dispose();
                      }
                      _thresholds.clear();
                      for (final t in thresholds) {
                        _thresholds.add(_ThresholdRow(
                          tier: t.slug,
                          minAmount: t.minAmount,
                        ));
                      }
                    });
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThresholdRow {
  final TextEditingController tierController;
  final TextEditingController amountController;

  _ThresholdRow({String? tier, double? minAmount})
      : tierController = TextEditingController(text: tier ?? ''),
        amountController = TextEditingController(
          text: minAmount == null ? '' : minAmount.toStringAsFixed(0),
        );

  bool get isEmpty =>
      tierController.text.trim().isEmpty && amountController.text.trim().isEmpty;

  bool get isValid =>
      tierController.text.trim().isNotEmpty &&
      double.tryParse(amountController.text.trim()) != null;

  void dispose() {
    tierController.dispose();
    amountController.dispose();
  }
}

class _ThresholdPresets extends ConsumerWidget {
  const _ThresholdPresets({required this.onApply});
  final ValueChanged<List<PlaqueTier>> onApply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiers = ref.watch(tiersProvider);

    return tiers.when(
      data: (list) {
        if (list.isEmpty) {
          return const Text(
            'No plaque tiers defined yet. Create tiers first to use presets.',
            style: TextStyle(fontSize: 12, color: kUzinduziGrey),
          );
        }
        return Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => onApply(list),
            icon: const Icon(Icons.auto_awesome, size: 16),
            label: Text('Copy ${list.length} tiers from catalog'),
          ),
        );
      },
      loading: () => const LinearProgressIndicator(minHeight: 2),
      error: (e, _) => Text(
        'Could not load tiers: $e',
        style: const TextStyle(fontSize: 12, color: kUzinduziRed),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: onClear != null
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onClear,
                )
              : const Icon(Icons.calendar_today_outlined, size: 16),
        ),
        child: Text(
          value == null
              ? 'Not set'
              : '${value!.year}-${value!.month.toString().padLeft(2, '0')}-'
                  '${value!.day.toString().padLeft(2, '0')} '
                  '${value!.hour.toString().padLeft(2, '0')}:'
                  '${value!.minute.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: kUzinduziGrey),
          const SizedBox(width: 10),
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
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: kUzinduziGrey,
      ),
    );
  }
}