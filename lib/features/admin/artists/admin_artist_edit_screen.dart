import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../../../core/errors.dart';
import '../../../core/theme.dart';
import '../../../widgets/auth_error_dialog.dart';
import '../shared/admin_confirm.dart';
import '../shared/admin_media_upload.dart';
import 'admin_artist_model.dart';
import 'admin_artists_provider.dart';

// ─────────────────────────────────────────────────────────────
// User picker — search existing users to link to the artist
// ─────────────────────────────────────────────────────────────
class AdminUserLite {
  final String id;
  final String userName;
  final String email;
  final String role;

  AdminUserLite({
    required this.id,
    required this.userName,
    required this.email,
    required this.role,
  });

  factory AdminUserLite.fromJson(Map<String, dynamic> j) => AdminUserLite(
        id: (j['id'] ?? '').toString(),
        userName: (j['userName'] ?? j['name'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        role: (j['role'] ?? 'fan').toString(),
      );
}

final _adminUsersSearchProvider =
    FutureProvider.family<List<AdminUserLite>, String>((ref, search) async {
  final api = ref.watch(apiClientProvider);
  final query = search.trim().isEmpty
      ? '?page=1&limit=20'
      : '?search=${Uri.encodeComponent(search.trim())}&page=1&limit=20';
  final res = await api.get('/api/admin/users$query');
  if (res['success'] != true) return [];
  final data = res['data'];
  final items = data is Map && data['items'] is List
      ? (data['items'] as List)
      : data is List
          ? data
          : const [];
  return items
      .whereType<Map>()
      .map((j) => AdminUserLite.fromJson(Map<String, dynamic>.from(j)))
      .toList();
});

// ─────────────────────────────────────────────────────────────
// Edit screen
// ─────────────────────────────────────────────────────────────
class AdminArtistEditScreen extends ConsumerStatefulWidget {
  const AdminArtistEditScreen({super.key, this.artistId});

  final String? artistId;

  @override
  ConsumerState<AdminArtistEditScreen> createState() =>
      _AdminArtistEditScreenState();
}

class _AdminArtistEditScreenState
    extends ConsumerState<AdminArtistEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final _stageName = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _bio = TextEditingController();
  final _genreId = TextEditingController();

  bool _canCreateAlbums = false;

  // Selected linked user (required on create, read-only on edit)
  String? _userId;

  String? _profileUrl;
  String? _coverUrl;

  AdminArtist? _artist;

  bool _loading = true;
  bool _saving = false;
  bool _deleting = false;
  bool _uploadingProfile = false;
  bool _uploadingCover = false;

  bool get _isEditing => widget.artistId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _load();
    } else {
      _loading = false;
    }
  }

  @override
  void dispose() {
    _stageName.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _bio.dispose();
    _genreId.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final artist = await ref
          .read(adminArtistsRepositoryProvider)
          .get(widget.artistId!);
      if (!mounted) return;
      _artist = artist;
      _userId = artist.userId;
      _stageName.text = artist.stageName;
      _firstName.text = artist.firstName ?? '';
      _lastName.text = artist.lastName ?? '';
      _bio.text = artist.bio ?? '';
      _genreId.text = artist.genreId ?? '';
      _canCreateAlbums = artist.canCreateAlbums;
      _profileUrl = artist.profilePictureUrl;
      _coverUrl = artist.coverPhoto;
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

  AdminArtist _buildArtist() => AdminArtist(
        id: _artist?.id ?? '',
        userId: _userId,
        stageName: _stageName.text.trim(),
        firstName: _emptyOrNull(_firstName.text),
        lastName: _emptyOrNull(_lastName.text),
        bio: _emptyOrNull(_bio.text),
        genreId: _emptyOrNull(_genreId.text),
        profilePictureUrl: _profileUrl,
        coverPhoto: _coverUrl,
        canCreateAlbums: _canCreateAlbums,
        hasCustomProfilePic: _artist?.hasCustomProfilePic ?? false,
        hasCustomCoverPhoto: _artist?.hasCustomCoverPhoto ?? false,
      );

  String? _emptyOrNull(String s) => s.trim().isEmpty ? null : s.trim();

  // ─── User picker dialog ─────────────────────────────────────
  Future<void> _pickUser() async {
    final picked = await showDialog<AdminUserLite>(
      context: context,
      builder: (_) => const _UserPickerDialog(),
    );
    if (picked == null || !mounted) return;
    setState(() => _userId = picked.id);
  }

  // ─── Uploads ─────────────────────────────────────────────────
  Future<void> _uploadProfile() async {
    if (!_isEditing) {
      await AuthErrorDialog.show(
        context,
        title: 'Save first',
        message:
            'Save the artist first, then re-open this screen to upload '
            'profile and cover images.',
      );
      return;
    }

    setState(() => _uploadingProfile = true);
    try {
      final uploader = AdminMediaUpload(ref.read(apiClientProvider));
      final url = await uploader.pickAndUpload(
        slot: MediaSlot.artistProfile, // 'avatar'
        confirmExtra: {'artistId': widget.artistId},
      );
      if (url == null) return;
      if (!mounted) return;
      setState(() => _profileUrl = url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated')),
      );
    } catch (e) {
      if (!mounted) return;
      await AuthErrorDialog.show(
        context,
        title: 'Upload failed',
        message: e is AppError ? e.message : '$e',
      );
    } finally {
      if (mounted) setState(() => _uploadingProfile = false);
    }
  }

  Future<void> _uploadCover() async {
    if (!_isEditing) {
      await AuthErrorDialog.show(
        context,
        title: 'Save first',
        message:
            'Save the artist first, then re-open this screen to upload '
            'profile and cover images.',
      );
      return;
    }

    setState(() => _uploadingCover = true);
    try {
      final uploader = AdminMediaUpload(ref.read(apiClientProvider));
      final url = await uploader.pickAndUpload(
        slot: MediaSlot.artistCover, // 'cover'
        confirmExtra: {'artistId': widget.artistId},
      );
      if (url == null) return;
      if (!mounted) return;
      setState(() => _coverUrl = url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cover photo updated')),
      );
    } catch (e) {
      if (!mounted) return;
      await AuthErrorDialog.show(
        context,
        title: 'Upload failed',
        message: e is AppError ? e.message : '$e',
      );
    } finally {
      if (mounted) setState(() => _uploadingCover = false);
    }
  }

  // ─── Save ────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isEditing && (_userId == null || _userId!.isEmpty)) {
      await AuthErrorDialog.show(
        context,
        title: 'Linked user required',
        message:
            'Pick the user account this artist profile belongs to. '
            'Admins cannot create an artist without a linked user.',
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(adminArtistsRepositoryProvider);
      final artist = _buildArtist();
      if (_isEditing) {
        await repo.update(widget.artistId!, artist);
      } else {
        final created = await repo.create(artist);
        if (!mounted) return;
        ref.invalidate(adminArtistsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Artist created. Upload images next.'),
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => AdminArtistEditScreen(artistId: created.id),
          ),
        );
        return;
      }
      if (!mounted) return;
      ref.invalidate(adminArtistsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artist updated')),
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

  // ─── Delete ──────────────────────────────────────────────────
  Future<void> _delete() async {
    final ok = await showAdminConfirm(
      context,
      title: 'Delete artist?',
      message:
          'Permanently removes "${_stageName.text.trim()}". '
          'Albums, tracks, and payments linked to them may be affected. '
          'This cannot be undone.',
      confirmLabel: 'Delete',
      danger: true,
    );
    if (!ok) return;

    setState(() => _deleting = true);
    try {
      await ref.read(adminArtistsRepositoryProvider).delete(widget.artistId!);
      if (!mounted) return;
      ref.invalidate(adminArtistsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artist deleted')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      await AuthErrorDialog.show(
        context,
        title: 'Delete failed',
        message: e is AppError ? e.message : '$e',
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  // ─── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kUzinduziWhite,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit artist' : 'New artist',
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
                      if (_isEditing) ...[
                        _SectionLabel('Images'),
                        _ImageRow(
                          label: 'Profile picture',
                          imageUrl: _profileUrl,
                          uploading: _uploadingProfile,
                          fallbackIcon: Icons.person,
                          isCircle: true,
                          onTap: _uploadProfile,
                        ),
                        const SizedBox(height: 16),
                        _ImageRow(
                          label: 'Cover photo',
                          imageUrl: _coverUrl,
                          uploading: _uploadingCover,
                          fallbackIcon: Icons.image_outlined,
                          isCircle: false,
                          onTap: _uploadCover,
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: kUzinduziDivider),
                        const SizedBox(height: 16),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kUzinduziDivider.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: kUzinduziGrey,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Save the artist first to upload profile '
                                  'and cover images.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: kUzinduziGrey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // ── Linked user (required) ─────────────
                      _SectionLabel('Linked user'),
                      _LinkedUserField(
                        userId: _userId,
                        isEditing: _isEditing,
                        onPick: _pickUser,
                        onClear: _isEditing
                            ? null
                            : () => setState(() => _userId = null),
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: kUzinduziDivider),
                      const SizedBox(height: 16),

                      // ── Identity ───────────────────────────
                      _SectionLabel('Identity'),
                      TextFormField(
                        controller: _stageName,
                        decoration: const InputDecoration(
                          labelText: 'Stage name',
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstName,
                              decoration: const InputDecoration(
                                labelText: 'First name',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _lastName,
                              decoration: const InputDecoration(
                                labelText: 'Last name',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _bio,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Bio',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _genreId,
                        decoration: const InputDecoration(
                          labelText: 'Genre ID (optional)',
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(color: kUzinduziDivider),
                      const SizedBox(height: 16),

                      _SectionLabel('Permissions'),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Can create albums'),
                        subtitle: const Text(
                          'Lets this artist publish albums and tracks',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _canCreateAlbums,
                        onChanged: (v) =>
                            setState(() => _canCreateAlbums = v),
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
                              : const Icon(
                                  Icons.delete_forever_outlined,
                                  size: 16,
                                ),
                          label: const Text('Delete artist permanently'),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Deleting an artist affects their albums, tracks, '
                          'and any associated payments. Make sure this is '
                          'intentional before proceeding.',
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
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Linked user field
// ─────────────────────────────────────────────────────────────
class _LinkedUserField extends StatelessWidget {
  const _LinkedUserField({
    required this.userId,
    required this.isEditing,
    required this.onPick,
    this.onClear,
  });

  final String? userId;
  final bool isEditing;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kUzinduziWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: userId == null ? kUzinduziRed : kUzinduziDivider,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, size: 18, color: kUzinduziGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              userId == null
                  ? (isEditing
                      ? 'No user linked'
                      : 'No user linked — required')
                  : 'User ID: $userId',
              style: TextStyle(
                fontSize: 13,
                color: userId == null ? kUzinduziGrey : kUzinduziBlack,
                fontWeight:
                    userId == null ? FontWeight.w500 : FontWeight.w600,
              ),
            ),
          ),
          if (onClear != null && userId != null)
            IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.close, size: 18),
              onPressed: onClear,
            ),
          TextButton(
            onPressed: onPick,
            child: Text(isEditing ? 'Change' : 'Pick user'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// User picker dialog
// ─────────────────────────────────────────────────────────────
class _UserPickerDialog extends ConsumerStatefulWidget {
  const _UserPickerDialog();

  @override
  ConsumerState<_UserPickerDialog> createState() => _UserPickerDialogState();
}

class _UserPickerDialogState extends ConsumerState<_UserPickerDialog> {
  final _searchCtrl = TextEditingController();
  final _debouncer = _Debouncer();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(_adminUsersSearchProvider(_query));

    return Dialog(
      backgroundColor: kUzinduziWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text(
                    'Pick user account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: kUzinduziBlack,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _searchCtrl,
                onChanged: (v) {
                  _debouncer.run(() => setState(() => _query = v));
                },
                decoration: InputDecoration(
                  hintText: 'Search by name or email',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: usersAsync.when(
                  data: (users) {
                    if (users.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          'No users match.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: kUzinduziGrey),
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: users.length,
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        color: kUzinduziDivider,
                      ),
                      itemBuilder: (_, i) {
                        final u = users[i];
                        return ListTile(
                          dense: true,
                          title: Text(
                            u.userName.isEmpty ? '(no name)' : u.userName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: kUzinduziBlack,
                            ),
                          ),
                          subtitle: Text(
                            '${u.email}  ·  ${u.role}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: kUzinduziGrey,
                            ),
                          ),
                          onTap: () => Navigator.of(context).pop(u),
                        );
                      },
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: CircularProgressIndicator(color: kUzinduziRed),
                    ),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'Error: $e',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: kUzinduziRed),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Debouncer {
  int _token = 0;

  void run(
    VoidCallback action, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    final myToken = ++_token;
    Future.delayed(delay, () {
      if (myToken == _token) action();
    });
  }

  void dispose() {
    _token++;
  }
}

// ─────────────────────────────────────────────────────────────
// Image row
// ─────────────────────────────────────────────────────────────
class _ImageRow extends StatelessWidget {
  const _ImageRow({
    required this.label,
    required this.imageUrl,
    required this.uploading,
    required this.fallbackIcon,
    required this.isCircle,
    required this.onTap,
  });

  final String label;
  final String? imageUrl;
  final bool uploading;
  final IconData fallbackIcon;
  final bool isCircle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shape = isCircle
        ? const CircleBorder()
        : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: isCircle ? 72 : 120,
              height: 72,
              decoration: ShapeDecoration(
                shape: shape,
                color: kUzinduziDivider,
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Icon(
                        fallbackIcon,
                        color: kUzinduziGrey,
                      ),
                    )
                  : Icon(fallbackIcon, color: kUzinduziGrey),
            ),
            if (uploading)
              Positioned.fill(
                child: Container(
                  decoration: ShapeDecoration(
                    shape: shape,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kUzinduziBlack,
                ),
              ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: uploading ? null : onTap,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  alignment: Alignment.centerLeft,
                ),
                icon: const Icon(Icons.upload_outlined, size: 16),
                label: const Text('Upload'),
              ),
            ],
          ),
        ),
      ],
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