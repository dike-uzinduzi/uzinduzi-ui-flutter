import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../../../core/errors.dart';
import '../../../core/theme.dart';
import '../../../widgets/auth_error_dialog.dart';
import '../shared/admin_confirm.dart';
import '../shared/admin_media_upload.dart';
import 'admin_tier_model.dart';
import 'admin_tiers_provider.dart';

class AdminTierEditScreen extends ConsumerStatefulWidget {
  const AdminTierEditScreen({super.key, this.tier});

  final AdminTier? tier;

  @override
  ConsumerState<AdminTierEditScreen> createState() =>
      _AdminTierEditScreenState();
}

class _AdminTierEditScreenState extends ConsumerState<AdminTierEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _slug;
  late final TextEditingController _displayName;
  late final TextEditingController _minAmount;
  late final TextEditingController _order;
  late final TextEditingController _freeShowDays;

  final List<TextEditingController> _benefitCtrls = [];

  String? _imageUrl;
  bool _isActive = true;
  bool _saving = false;
  bool _uploading = false;
  bool _deleting = false;

  bool get _isEditing => widget.tier != null;

  @override
  void initState() {
    super.initState();
    final t = widget.tier;

    _slug = TextEditingController(text: t?.slug ?? '');
    _displayName = TextEditingController(text: t?.displayName ?? '');
    _minAmount = TextEditingController(
      text: t == null ? '' : t.minAmount.toStringAsFixed(0),
    );
    _order = TextEditingController(text: (t?.order ?? 0).toString());
    _freeShowDays = TextEditingController(
      text: t?.freeShowDays?.toString() ?? '',
    );
    _imageUrl = t?.imageUrl;
    _isActive = t?.isActive ?? true;

    final benefits = t?.benefits ?? const <String>[];
    if (benefits.isEmpty) {
      _benefitCtrls.add(TextEditingController());
    } else {
      for (final b in benefits) {
        _benefitCtrls.add(TextEditingController(text: b));
      }
    }
  }

  @override
  void dispose() {
    _slug.dispose();
    _displayName.dispose();
    _minAmount.dispose();
    _order.dispose();
    _freeShowDays.dispose();
    for (final c in _benefitCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> get _benefits => _benefitCtrls
      .map((c) => c.text.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  AdminTier _buildTier() => AdminTier(
        id: widget.tier?.id ?? '',
        slug: _slug.text.trim().toUpperCase(),
        displayName: _displayName.text.trim(),
        minAmount: double.tryParse(_minAmount.text.trim()) ?? 0,
        order: int.tryParse(_order.text.trim()) ?? 0,
        imageUrl: _imageUrl,
        benefits: _benefits,
        freeShowDays: _freeShowDays.text.trim().isEmpty
            ? null
            : int.tryParse(_freeShowDays.text.trim()),
        isActive: _isActive,
      );

Future<void> _pickAndUploadImage() async {
  setState(() => _uploading = true);
  try {
    final uploader = AdminMediaUpload(ref.read(apiClientProvider));
    final url = await uploader.pickAndUpload(
      slot: MediaSlot.tier,
      confirmExtra: _isEditing ? {'tierId': widget.tier!.id} : null,
    );
    if (url == null) return; // cancelled
    if (!mounted) return;
    setState(() => _imageUrl = url);
    ref.invalidate(adminTiersProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image updated')),
    );
  } catch (e) {
    if (!mounted) return;
    await AuthErrorDialog.show(
      context,
      title: 'Upload failed',
      message: e is AppError ? e.message : '$e',
    );
  } finally {
    if (mounted) setState(() => _uploading = false);
  }
}
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_slug.text.trim().isEmpty) return;
    if (_benefits.isEmpty) {
      final ok = await showAdminConfirm(
        context,
        title: 'No benefits added',
        message:
            'This tier has no benefits listed. Fans will only see the '
            'image and name. Save anyway?',
        confirmLabel: 'Save anyway',
      );
      if (!ok) return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(adminTiersRepositoryProvider);
      final tier = _buildTier();
      if (_isEditing) {
        await repo.update(widget.tier!.id, tier);
      } else {
        await repo.create(tier);
      }
      if (!mounted) return;
      ref.invalidate(adminTiersProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Tier updated' : 'Tier created')),
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

Future<void> _delete() async {
  final ok = await showAdminConfirm(
    context,
    title: 'Deactivate tier?',
    message:
        '"${widget.tier!.displayName}" will no longer appear in the public '
        'app. Fans currently entitled to it keep their benefits. '
        'You can reactivate it later by editing and turning Active back on.',
    confirmLabel: 'Deactivate',
    danger: true,
  );
  if (!ok) return;

  setState(() => _deleting = true);
  try {
    await ref.read(adminTiersRepositoryProvider).delete(widget.tier!.id);
    if (!mounted) return;
    ref.invalidate(adminTiersProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tier deactivated')),
    );
    Navigator.of(context).pop(true);
  } catch (e) {
    if (!mounted) return;
    await AuthErrorDialog.show(
      context,
      title: 'Deactivate failed',
      message: e is AppError ? e.message : '$e',
    );
  } finally {
    if (mounted) setState(() => _deleting = false);
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kUzinduziWhite,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit tier' : 'New tier',
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
                    _isEditing ? 'Save' : 'Create',
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
                _SectionLabel('Image'),
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 160,
                          height: 160,
                          child: _imageUrl != null && _imageUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: _imageUrl!,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, _, _) => Container(
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
                      if (_uploading)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.5),
                              alignment: Alignment.center,
                              child: const SizedBox(
                                width: 26,
                                height: 26,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Material(
                          color: kUzinduziRed,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _uploading ? null : _pickAndUploadImage,
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: _uploading ? null : _pickAndUploadImage,
                    icon: const Icon(Icons.upload_outlined, size: 16),
                    label: const Text('Change image'),
                  ),
                ),

                const SizedBox(height: 24),
                _SectionLabel('Basics'),
                TextFormField(
                  controller: _slug,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Slug (e.g. BRONZE, SILVER, GOLD)',
                  ),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return 'Required';
                    if (!RegExp(r'^[A-Za-z0-9_\-]+$').hasMatch(s)) {
                      return 'Letters, numbers, _ and - only';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _displayName,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minAmount,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Minimum amount',
                          prefixText: '\$ ',
                        ),
                        validator: (v) {
                          final n = double.tryParse((v ?? '').trim());
                          if (n == null || n < 0) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _order,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Order'),
                        validator: (v) {
                          final n = int.tryParse((v ?? '').trim());
                          if (n == null || n < 0) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _freeShowDays,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Free show days (optional)',
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  children: [
                    const _SectionLabel('Benefits'),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _benefitCtrls.add(TextEditingController());
                        });
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (_benefitCtrls.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No benefits yet. Add at least one.',
                      style: TextStyle(color: kUzinduziGrey),
                    ),
                  ),
                for (var i = 0; i < _benefitCtrls.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _benefitCtrls[i],
                            decoration: InputDecoration(
                              labelText: 'Benefit ${i + 1}',
                              isDense: true,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            setState(() {
                              _benefitCtrls[i].dispose();
                              _benefitCtrls.removeAt(i);
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),
                _SectionLabel('Visibility'),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  subtitle: const Text(
                    'Inactive tiers are hidden from the public app',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),

              if (_isEditing) ...[
  const SizedBox(height: 24),
  const Divider(color: kUzinduziDivider),
  const SizedBox(height: 16),
  _SectionLabel('Danger zone'),
  OutlinedButton.icon(
    onPressed: _deleting ? null : _delete,
    style: OutlinedButton.styleFrom(
      foregroundColor: kUzinduziRed,
      side: const BorderSide(color: kUzinduziRed),
    ),
    icon: _deleting
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: kUzinduziRed,
            ),
          )
        : const Icon(Icons.visibility_off_outlined, size: 16),
    label: const Text('Deactivate tier'),
  ),
  const SizedBox(height: 8),
  const Text(
    'Deactivating hides the tier from the public app. It can be '
    'reactivated later. Existing fan entitlements are preserved.',
    style: TextStyle(fontSize: 12, color: kUzinduziGrey),
  ),
],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
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