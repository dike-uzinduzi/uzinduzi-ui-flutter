import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import 'admin_album_create_screen.dart';
import 'admin_album_edit_screen.dart';
import 'admin_albums_provider.dart';
import 'widgets/album_row_card.dart';

class AdminAlbumsScreen extends ConsumerStatefulWidget {
  const AdminAlbumsScreen({super.key});

  @override
  ConsumerState<AdminAlbumsScreen> createState() => _AdminAlbumsScreenState();
}

class _AdminAlbumsScreenState extends ConsumerState<AdminAlbumsScreen> {
  final _searchCtrl = TextEditingController();
  final _debouncer = _Debouncer();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(adminAlbumsQueryProvider);
    final albums = ref.watch(adminAlbumsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Albums',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: kUzinduziBlack,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => ref.invalidate(adminAlbumsProvider),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () async {
                      final created = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => const AdminAlbumCreateScreen(),
                        ),
                      );
                      if (created == true) {
                        ref.invalidate(adminAlbumsProvider);
                      }
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('New album'),
                    style: FilledButton.styleFrom(
                      backgroundColor: kUzinduziRed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Filters(
                searchCtrl: _searchCtrl,
                query: query,
                onSearchChanged: (v) => _debouncer.run(
                  () => ref
                      .read(adminAlbumsQueryProvider.notifier)
                      .setSearch(v),
                ),
                onAlbumTypeChanged: (v) =>
                    ref.read(adminAlbumsQueryProvider.notifier).setAlbumType(v),
                onPublishedChanged: (v) =>
                    ref.read(adminAlbumsQueryProvider.notifier).setPublished(v),
                onFeaturedChanged: (v) =>
                    ref.read(adminAlbumsQueryProvider.notifier).setFeatured(v),
                onDeletedChanged: (v) =>
                    ref.read(adminAlbumsQueryProvider.notifier).setDeleted(v),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: kUzinduziDivider),
        Expanded(
          child: albums.when(
            data: (result) {
              if (result.albums.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: Text(
                      'No albums match those filters.',
                      style: TextStyle(color: kUzinduziGrey),
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: result.albums.length,
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        color: kUzinduziDivider,
                      ),
                      itemBuilder: (_, i) {
                        final album = result.albums[i];
                        return AlbumRowCard(
                          album: album,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AdminAlbumEditScreen(
                                  albumId: album.id,
                                ),
                              ),
                            );
                            ref.invalidate(adminAlbumsProvider);
                          },
                        );
                      },
                    ),
                  ),
                  _Pagination(
                    page: result.page,
                    pageCount: result.pageCount,
                    total: result.total,
                    onPrev: result.page > 1
                        ? () => ref
                            .read(adminAlbumsQueryProvider.notifier)
                            .setPage(result.page - 1)
                        : null,
                    onNext: result.page < result.pageCount
                        ? () => ref
                            .read(adminAlbumsQueryProvider.notifier)
                            .setPage(result.page + 1)
                        : null,
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: kUzinduziRed),
            ),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Text(
                  'Error loading albums:\n$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: kUzinduziGrey),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.searchCtrl,
    required this.query,
    required this.onSearchChanged,
    required this.onAlbumTypeChanged,
    required this.onPublishedChanged,
    required this.onFeaturedChanged,
    required this.onDeletedChanged,
  });

  final TextEditingController searchCtrl;
  final AdminAlbumsQuery query;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onAlbumTypeChanged;
  final ValueChanged<bool?> onPublishedChanged;
  final ValueChanged<bool?> onFeaturedChanged;
  final ValueChanged<bool> onDeletedChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 260,
          child: TextField(
            controller: searchCtrl,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search by title',
              prefixIcon: const Icon(Icons.search, size: 18),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 150,
          child: DropdownButtonFormField<String>(
            initialValue: query.albumType,
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: const [
              DropdownMenuItem(value: '', child: Text('All types')),
              DropdownMenuItem(value: 'album', child: Text('Album')),
              DropdownMenuItem(value: 'ep', child: Text('EP')),
              DropdownMenuItem(value: 'single', child: Text('Single')),
              DropdownMenuItem(value: 'mixtape', child: Text('Mixtape')),
              DropdownMenuItem(value: 'playlist', child: Text('Playlist')),
            ],
            onChanged: (v) => onAlbumTypeChanged(v ?? ''),
          ),
        ),
        _TriToggle(
          label: 'Published',
          value: query.published,
          onChanged: onPublishedChanged,
        ),
        _TriToggle(
          label: 'Featured',
          value: query.featured,
          onChanged: onFeaturedChanged,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: query.deleted,
              onChanged: (v) => onDeletedChanged(v ?? false),
            ),
            const Text(
              'Show deleted',
              style: TextStyle(fontSize: 12, color: kUzinduziBlack),
            ),
          ],
        ),
      ],
    );
  }
}

class _TriToggle extends StatelessWidget {
  const _TriToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool? value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: kUzinduziDivider),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kUzinduziGrey,
              ),
            ),
          ),
          _TriOption(
            label: 'All',
            selected: value == null,
            onTap: () => onChanged(null),
          ),
          _TriOption(
            label: 'Yes',
            selected: value == true,
            onTap: () => onChanged(true),
          ),
          _TriOption(
            label: 'No',
            selected: value == false,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _TriOption extends StatelessWidget {
  const _TriOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? kUzinduziRed.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: selected ? kUzinduziRed : kUzinduziGrey,
          ),
        ),
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.page,
    required this.pageCount,
    required this.total,
    this.onPrev,
    this.onNext,
  });

  final int page;
  final int pageCount;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: kUzinduziDivider)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Text(
            '$total total',
            style: const TextStyle(fontSize: 12, color: kUzinduziGrey),
          ),
          const Spacer(),
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Page $page of $pageCount',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kUzinduziBlack,
              ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next',
          ),
        ],
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