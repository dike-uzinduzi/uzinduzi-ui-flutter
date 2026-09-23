import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../../../core/errors.dart';
import '../../../core/theme.dart';
import '../../../widgets/auth_error_dialog.dart';
import 'admin_albums_provider.dart';
import 'admin_track_edit_screen.dart';
import 'admin_tracks_provider.dart';

class AdminAlbumEditScreen extends ConsumerStatefulWidget {
  const AdminAlbumEditScreen({super.key, required this.albumId});
  final String albumId;

  @override
  ConsumerState<AdminAlbumEditScreen> createState() =>
      _AdminAlbumEditScreenState();
}

class _AdminAlbumEditScreenState extends ConsumerState<AdminAlbumEditScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController? _title;
  TextEditingController? _description;
  TextEditingController? _publisher;
  TextEditingController? _copyright;
  TextEditingController? _credits;
  TextEditingController? _affiliation;

  String _albumType = 'album';
  DateTime? _releaseDate;

  bool _loading = true;
  bool _saving = false;
  bool _toggling = false;

  Map<String, dynamic>? _album;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _title?.dispose();
    _description?.dispose();
    _publisher?.dispose();
    _copyright?.dispose();
    _credits?.dispose();
    _affiliation?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.get('/api/admin/albums/${widget.albumId}');
      if (res['success'] != true || res['data'] == null) {
        throw AppError(res['message']?.toString() ?? 'Album not found');
      }
      final album = Map<String, dynamic>.from(res['data'] as Map);
      _album = album;

      _title = TextEditingController(text: album['title']?.toString() ?? '');
      _description = TextEditingController(
        text: album['description']?.toString() ?? '',
      );
      _publisher = TextEditingController(
        text: album['publisher']?.toString() ?? '',
      );
      _copyright = TextEditingController(
        text: album['copyright_info']?.toString() ?? '',
      );
      _credits = TextEditingController(
        text: album['credits']?.toString() ?? '',
      );
      _affiliation = TextEditingController(
        text: album['affiliation']?.toString() ?? '',
      );
      _albumType = (album['albumType']?.toString() ?? 'album');
      _releaseDate = album['release_date'] != null
          ? DateTime.tryParse(album['release_date'].toString())
          : null;
    } catch (e) {
      if (mounted) {
        await AuthErrorDialog.show(
          context,
          title: 'Load failed',
          message: e is AppError ? e.message : '$e',
        );
        if (mounted) Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final api = ref.read(apiClientProvider);
      final body = <String, dynamic>{
        'title': _title!.text.trim(),
        'description': _description!.text.trim(),
        'albumType': _albumType,
        'publisher': _publisher!.text.trim(),
        'copyright_info': _copyright!.text.trim(),
        'credits': _credits!.text.trim(),
        'affiliation': _affiliation!.text.trim(),
      };
      if (_releaseDate != null) {
        body['release_date'] =
            _releaseDate!.toIso8601String().split('T').first;
      }

      final res = await api.dio.patch(
        '/api/admin/albums/${widget.albumId}',
        data: body,
      );

      if (res.statusCode != 200) {
        throw AppError('Save failed (${res.statusCode})');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Album saved')),
      );
      ref.invalidate(adminAlbumsProvider);
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

  Future<void> _toggle(String action, bool value) async {
    setState(() => _toggling = true);
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.dio.patch(
        '/api/admin/albums/${widget.albumId}/$action',
        data: {'value': value},
      );
      if (res.statusCode != 200) {
        throw AppError('$action failed (${res.statusCode})');
      }
      await _load();
      ref.invalidate(adminAlbumsProvider);
    } catch (e) {
      if (!mounted) return;
      await AuthErrorDialog.show(
        context,
        title: 'Action failed',
        message: e is AppError ? e.message : '$e',
      );
    } finally {
      if (mounted) setState(() => _toggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kUzinduziWhite,
      appBar: AppBar(
        title: Text(
          _album?['title']?.toString() ?? 'Album',
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
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: kUzinduziRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kUzinduziRed))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      // Cover preview
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: _album?['cover_art']?.toString() ?? '',
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) => Container(
                              width: 140,
                              height: 140,
                              color: kUzinduziDivider,
                              child: const Icon(Icons.album, size: 48),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Status toggles
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _ActionToggle(
                            label: (_album?['is_published'] == true)
                                ? 'Unpublish'
                                : 'Publish',
                            active: _album?['is_published'] == true,
                            onTap: _toggling
                                ? null
                                : () => _toggle(
                                      'publish',
                                      !(_album?['is_published'] == true),
                                    ),
                          ),
                          _ActionToggle(
                            label: (_album?['is_featured'] == true)
                                ? 'Unfeature'
                                : 'Feature',
                            active: _album?['is_featured'] == true,
                            onTap: _toggling
                                ? null
                                : () => _toggle(
                                      'feature',
                                      !(_album?['is_featured'] == true),
                                    ),
                          ),
                          _ActionToggle(
                            label: (_album?['is_deleted'] == true)
                                ? 'Restore'
                                : 'Delete',
                            active: _album?['is_deleted'] == true,
                            danger: true,
                            onTap: _toggling
                                ? null
                                : () => _toggle(
                                      'soft-delete',
                                      !(_album?['is_deleted'] == true),
                                    ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: kUzinduziDivider),
                      const SizedBox(height: 16),

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
                        decoration:
                            const InputDecoration(labelText: 'Album type'),
                        items: const [
                          DropdownMenuItem(
                              value: 'album', child: Text('Album')),
                          DropdownMenuItem(value: 'ep', child: Text('EP')),
                          DropdownMenuItem(
                              value: 'single', child: Text('Single')),
                          DropdownMenuItem(
                              value: 'mixtape', child: Text('Mixtape')),
                          DropdownMenuItem(
                              value: 'playlist', child: Text('Playlist')),
                        ],
                        onChanged: (v) =>
                            setState(() => _albumType = v ?? 'album'),
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _releaseDate ?? now,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(now.year + 5),
                          );
                          if (picked != null) {
                            setState(() => _releaseDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Release date',
                          ),
                          child: Text(
                            _releaseDate == null
                                ? 'Not set'
                                : _releaseDate!
                                    .toIso8601String()
                                    .split('T')
                                    .first,
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
                      const Divider(color: kUzinduziDivider),
                      const SizedBox(height: 16),

                      _SectionLabel('Rights & credits'),
                      TextFormField(
                        controller: _publisher,
                        decoration:
                            const InputDecoration(labelText: 'Publisher'),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _copyright,
                        decoration:
                            const InputDecoration(labelText: 'Copyright'),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _affiliation,
                        decoration:
                            const InputDecoration(labelText: 'Affiliation'),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _credits,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Credits',
                          alignLabelWithHint: true,
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(color: kUzinduziDivider),
                      const SizedBox(height: 16),

                      _TracksSection(albumId: widget.albumId),

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

class _ActionToggle extends StatelessWidget {
  const _ActionToggle({
    required this.label,
    required this.active,
    this.danger = false,
    this.onTap,
  });

  final String label;
  final bool active;
  final bool danger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = danger ? kUzinduziRed : kUzinduziBlack;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(
          color: active ? color : kUzinduziDivider,
        ),
        backgroundColor:
            active ? color.withValues(alpha: 0.06) : Colors.transparent,
      ),
      child: Text(label),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tracks section
// ─────────────────────────────────────────────────────────────
class _TracksSection extends ConsumerWidget {
  const _TracksSection({required this.albumId});
  final String albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(adminTracksProvider(albumId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'TRACKS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: kUzinduziGrey,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () async {
                final added = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => AdminTrackEditScreen(albumId: albumId),
                  ),
                );
                if (added == true) {
                  ref.invalidate(adminTracksProvider(albumId));
                }
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add track'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        tracksAsync.when(
          data: (tracks) {
            if (tracks.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No tracks yet. Add the first one.',
                  style: TextStyle(color: kUzinduziGrey),
                ),
              );
            }
            return Column(
              children: [
                for (final t in tracks)
                  _TrackRow(
                    track: t,
                    albumId: albumId,
                    onChanged: () =>
                        ref.invalidate(adminTracksProvider(albumId)),
                  ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (e, _) => Text(
            'Could not load tracks: $e',
            style: const TextStyle(color: kUzinduziRed),
          ),
        ),
      ],
    );
  }
}

class _TrackRow extends ConsumerWidget {
  const _TrackRow({
    required this.track,
    required this.albumId,
    required this.onChanged,
  });

  final AdminTrack track;
  final String albumId;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              track.trackNumber.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: kUzinduziGrey,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kUzinduziBlack,
                  ),
                ),
                if (track.producer != null && track.producer!.isNotEmpty)
                  Text(
                    'prod. ${track.producer}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: kUzinduziGrey,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            track.durationLabel,
            style: const TextStyle(
              fontSize: 12,
              color: kUzinduziGrey,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            tooltip: 'Edit',
            onPressed: () async {
              final edited = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => AdminTrackEditScreen(
                    albumId: albumId,
                    track: track,
                  ),
                ),
              );
              if (edited == true) onChanged();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            tooltip: 'Delete',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete track?'),
                  content: Text('Remove "${track.title}" from this album?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: kUzinduziRed,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed != true) return;

              try {
                final api = ref.read(apiClientProvider);
                await api.dio.delete('/api/tracks/${track.id}');
                onChanged();
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Delete failed: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}