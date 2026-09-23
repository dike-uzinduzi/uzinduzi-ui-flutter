import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../../../core/errors.dart';
import '../../../core/theme.dart';
import '../../../widgets/auth_error_dialog.dart';
import 'admin_albums_provider.dart';
import 'admin_artists_picker_provider.dart';

class AdminAlbumCreateScreen extends ConsumerStatefulWidget {
  const AdminAlbumCreateScreen({super.key});

  @override
  ConsumerState<AdminAlbumCreateScreen> createState() =>
      _AdminAlbumCreateScreenState();
}

class _AdminAlbumCreateScreenState
    extends ConsumerState<AdminAlbumCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _description = TextEditingController();
  final _publisher = TextEditingController();
  final _copyright = TextEditingController();
  final _credits = TextEditingController();
  final _affiliation = TextEditingController();

  String? _artistId;
  String _albumType = 'album';
  DateTime _releaseDate = DateTime.now();
  bool _isPublished = true;
  bool _isFeatured = false;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _publisher.dispose();
    _copyright.dispose();
    _credits.dispose();
    _affiliation.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_artistId == null) {
      await AuthErrorDialog.show(
        context,
        title: 'Artist required',
        message: 'Pick the artist this album belongs to.',
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.dio.post(
        '/api/albums',
        data: {
          'artistId': _artistId,
          'title': _title.text.trim(),
          'albumType': _albumType,
          'description': _description.text.trim(),
          'publisher': _publisher.text.trim(),
          'copyright_info': _copyright.text.trim(),
          'credits': _credits.text.trim(),
          'affiliation': _affiliation.text.trim(),
          'release_date': _releaseDate.toIso8601String().split('T').first,
          'is_published': _isPublished,
          'is_featured': _isFeatured,
        },
      );

      if (res.statusCode != 201) {
        final msg = res.data is Map
            ? res.data['message']?.toString()
            : 'Create failed';
        throw AppError(msg ?? 'Create failed');
      }

      if (!mounted) return;
      ref.invalidate(adminAlbumsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Album created')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      await AuthErrorDialog.show(
        context,
        title: 'Create failed',
        message: e is AppError ? e.message : '$e',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final artists = ref.watch(adminArtistsPickerProvider);

    return Scaffold(
      backgroundColor: kUzinduziWhite,
      appBar: AppBar(
        title: const Text(
          'New album',
          style: TextStyle(fontWeight: FontWeight.w800),
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
                : const Text(
                    'Create',
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
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _SectionLabel('Ownership'),
                artists.when(
                  data: (list) => DropdownButtonFormField<String>(
                    initialValue: _artistId,
                    decoration: const InputDecoration(
                      labelText: 'Artist',
                    ),
                    items: list
                        .map((a) => DropdownMenuItem(
                              value: a.id,
                              child: Text(a.name),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _artistId = v),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Pick an artist'
                        : null,
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
                  error: (e, _) => Text(
                    'Could not load artists: $e',
                    style: const TextStyle(color: kUzinduziRed),
                  ),
                ),
                const SizedBox(height: 24),

                _SectionLabel('Metadata'),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _albumType,
                  decoration: const InputDecoration(labelText: 'Album type'),
                  items: const [
                    DropdownMenuItem(value: 'album', child: Text('Album')),
                    DropdownMenuItem(value: 'ep', child: Text('EP')),
                    DropdownMenuItem(value: 'single', child: Text('Single')),
                    DropdownMenuItem(value: 'mixtape', child: Text('Mixtape')),
                    DropdownMenuItem(value: 'playlist', child: Text('Playlist')),
                  ],
                  onChanged: (v) => setState(() => _albumType = v ?? 'album'),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _releaseDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(now.year + 5),
                    );
                    if (picked != null) {
                      setState(() => _releaseDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration:
                        const InputDecoration(labelText: 'Release date'),
                    child: Text(
                      _releaseDate.toIso8601String().split('T').first,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _description,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: 24),
                _SectionLabel('Rights & credits'),
                TextFormField(
                  controller: _publisher,
                  decoration: const InputDecoration(labelText: 'Publisher'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _copyright,
                  decoration: const InputDecoration(labelText: 'Copyright'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _affiliation,
                  decoration: const InputDecoration(labelText: 'Affiliation'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _credits,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Credits',
                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: 24),
                _SectionLabel('Visibility'),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Publish immediately'),
                  value: _isPublished,
                  onChanged: (v) => setState(() => _isPublished = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Feature on home'),
                  subtitle: const Text(
                    'Only one album can be featured at a time',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _isFeatured,
                  onChanged: (v) => setState(() => _isFeatured = v),
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
