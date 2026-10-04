import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import 'admin_artist_edit_screen.dart';
import 'admin_artists_provider.dart';
import 'widgets/artist_row_card.dart';

class AdminArtistsScreen extends ConsumerStatefulWidget {
  const AdminArtistsScreen({super.key});

  @override
  ConsumerState<AdminArtistsScreen> createState() =>
      _AdminArtistsScreenState();
}

class _AdminArtistsScreenState extends ConsumerState<AdminArtistsScreen> {
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
    final artists = ref.watch(adminArtistsProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Artists',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: kUzinduziBlack,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () =>
                            ref.invalidate(adminArtistsProvider),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Refresh'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: kUzinduziRed,
                        ),
                        onPressed: () => _openCreate(context),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('New artist'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 320,
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) {
                        _debouncer.run(() {
                          ref
                              .read(adminArtistsQueryProvider.notifier)
                              .state = v;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by stage name',
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
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: kUzinduziDivider),
            Expanded(
              child: artists.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: Text(
                          'No artists match.',
                          style: TextStyle(color: kUzinduziGrey),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      color: kUzinduziDivider,
                    ),
                    itemBuilder: (_, i) => ArtistRowCard(
                      artist: list[i],
                      onTap: () => _openEdit(context, list[i].id),
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: kUzinduziRed),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Text(
                      'Error loading artists:\n$e',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: kUzinduziGrey),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCreate(BuildContext context) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const AdminArtistEditScreen(),
      ),
    );
    if (created == true) ref.invalidate(adminArtistsProvider);
  }

  Future<void> _openEdit(BuildContext context, String id) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdminArtistEditScreen(artistId: id),
      ),
    );
    if (changed == true) ref.invalidate(adminArtistsProvider);
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