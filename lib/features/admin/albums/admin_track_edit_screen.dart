import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../../../core/errors.dart';
import '../../../core/theme.dart';
import '../../../widgets/auth_error_dialog.dart';
import 'admin_tracks_provider.dart';

class AdminTrackEditScreen extends ConsumerStatefulWidget {
  const AdminTrackEditScreen({
    super.key,
    required this.albumId,
    this.track,
  });

  final String albumId;
  final AdminTrack? track;

  @override
  ConsumerState<AdminTrackEditScreen> createState() =>
      _AdminTrackEditScreenState();
}

class _AdminTrackEditScreenState
    extends ConsumerState<AdminTrackEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _title;
  late final TextEditingController _durationMin;
  late final TextEditingController _durationSec;
  late final TextEditingController _trackNumber;
  late final TextEditingController _featuredArtists;
  late final TextEditingController _writer;
  late final TextEditingController _producer;
  late final TextEditingController _performedBy;
  late final TextEditingController _backingVocals;
  late final TextEditingController _instrumentation;
  late final TextEditingController _mixingEngineer;
  late final TextEditingController _masteringEngineer;
  late final TextEditingController _specialCredits;
  late final TextEditingController _description;

  bool _saving = false;

  bool get _isEditing => widget.track != null;

  @override
  void initState() {
    super.initState();
    final t = widget.track;
    final minutes = t == null ? 3 : (t.durationMs ~/ 60000);
    final seconds = t == null ? 0 : ((t.durationMs % 60000) ~/ 1000);

    _title = TextEditingController(text: t?.title ?? '');
    _durationMin = TextEditingController(text: minutes.toString());
    _durationSec = TextEditingController(text: seconds.toString());
    _trackNumber = TextEditingController(
      text: (t?.trackNumber ?? 1).toString(),
    );
    _featuredArtists = TextEditingController(text: t?.featuredArtists ?? '');
    _writer = TextEditingController(text: t?.writer ?? '');
    _producer = TextEditingController(text: t?.producer ?? '');
    _performedBy = TextEditingController(text: t?.performedBy ?? '');
    _backingVocals = TextEditingController(text: t?.backingVocals ?? '');
    _instrumentation = TextEditingController(text: t?.instrumentation ?? '');
    _mixingEngineer = TextEditingController(text: t?.mixingEngineer ?? '');
    _masteringEngineer =
        TextEditingController(text: t?.masteringEngineer ?? '');
    _specialCredits = TextEditingController(text: t?.specialCredits ?? '');
    _description = TextEditingController(text: t?.trackDescription ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _durationMin.dispose();
    _durationSec.dispose();
    _trackNumber.dispose();
    _featuredArtists.dispose();
    _writer.dispose();
    _producer.dispose();
    _performedBy.dispose();
    _backingVocals.dispose();
    _instrumentation.dispose();
    _mixingEngineer.dispose();
    _masteringEngineer.dispose();
    _specialCredits.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final min = int.tryParse(_durationMin.text.trim()) ?? 0;
      final sec = int.tryParse(_durationSec.text.trim()) ?? 0;
      final durationMs = (min * 60 + sec) * 1000;

      final body = <String, dynamic>{
        'albumId': widget.albumId,
        'title': _title.text.trim(),
        'durationMs': durationMs,
        'trackNumber': int.tryParse(_trackNumber.text.trim()) ?? 1,
        'featuredArtists': _emptyOrNull(_featuredArtists.text),
        'writer': _emptyOrNull(_writer.text),
        'producer': _emptyOrNull(_producer.text),
        'performedBy': _emptyOrNull(_performedBy.text),
        'backingVocals': _emptyOrNull(_backingVocals.text),
        'instrumentation': _emptyOrNull(_instrumentation.text),
        'mixingEngineer': _emptyOrNull(_mixingEngineer.text),
        'masteringEngineer': _emptyOrNull(_masteringEngineer.text),
        'specialCredits': _emptyOrNull(_specialCredits.text),
        'trackDescription': _emptyOrNull(_description.text),
        'isPublished': true,
      };

      final api = ref.read(apiClientProvider);
      final res = _isEditing
          ? await api.dio.put(
              '/api/tracks/${widget.track!.id}',
              data: body,
            )
          : await api.dio.post('/api/tracks', data: body);

      final ok = res.statusCode == 200 || res.statusCode == 201;
      if (!ok) {
        final msg = res.data is Map
            ? res.data['message']?.toString()
            : 'Save failed';
        throw AppError(msg ?? 'Save failed');
      }

      if (!mounted) return;
      ref.invalidate(adminTracksProvider(widget.albumId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Track updated' : 'Track added'),
        ),
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

  String? _emptyOrNull(String s) => s.trim().isEmpty ? null : s.trim();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kUzinduziWhite,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit track' : 'Add track',
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
                    _isEditing ? 'Save' : 'Add',
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
                _SectionLabel('Basic'),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        controller: _trackNumber,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Track #',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _durationMin,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Minutes'),
                        validator: (v) {
                          final n = int.tryParse((v ?? '').trim());
                          if (n == null || n < 0) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _durationSec,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Seconds'),
                        validator: (v) {
                          final n = int.tryParse((v ?? '').trim());
                          if (n == null || n < 0 || n > 59) return '0–59';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _description,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: 24),
                _SectionLabel('Credits'),
                TextFormField(
                  controller: _featuredArtists,
                  decoration:
                      const InputDecoration(labelText: 'Featured artists'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _performedBy,
                  decoration:
                      const InputDecoration(labelText: 'Performed by'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _writer,
                  decoration: const InputDecoration(labelText: 'Writer'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _producer,
                  decoration: const InputDecoration(labelText: 'Producer'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _backingVocals,
                  decoration:
                      const InputDecoration(labelText: 'Backing vocals'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _instrumentation,
                  decoration:
                      const InputDecoration(labelText: 'Instrumentation'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _mixingEngineer,
                  decoration:
                      const InputDecoration(labelText: 'Mixing engineer'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _masteringEngineer,
                  decoration:
                      const InputDecoration(labelText: 'Mastering engineer'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _specialCredits,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Special credits',
                    alignLabelWithHint: true,
                  ),
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
