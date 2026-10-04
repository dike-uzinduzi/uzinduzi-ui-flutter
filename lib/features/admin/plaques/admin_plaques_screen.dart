import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import 'admin_plaque_detail_screen.dart';
import 'admin_plaque_model.dart';
import 'admin_plaques_provider.dart';
import 'widgets/plaque_row_card.dart';

class AdminPlaquesScreen extends ConsumerStatefulWidget {
  const AdminPlaquesScreen({super.key});

  @override
  ConsumerState<AdminPlaquesScreen> createState() =>
      _AdminPlaquesScreenState();
}

class _AdminPlaquesScreenState extends ConsumerState<AdminPlaquesScreen> {
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
    final query = ref.watch(adminPlaquesQueryProvider);
    final plaques = ref.watch(adminPlaquesProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
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
                        'Plaques',
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
                            ref.invalidate(adminPlaquesProvider),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 280,
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) {
                            _debouncer.run(() {
                              ref
                                  .read(adminPlaquesQueryProvider.notifier)
                                  .state = query.copyWith(
                                search: v,
                                page: 1,
                              );
                            });
                          },
                          decoration: InputDecoration(
                            hintText:
                                'Search serial / owner / tracking',
                            prefixIcon:
                                const Icon(Icons.search, size: 18),
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
                      SizedBox(
                        width: 220,
                        child: DropdownButtonFormField<String>(
                          initialValue: query.status,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: '',
                              child: Text('All statuses'),
                            ),
                            ...kPlaqueStatuses.map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(plaqueStatusLabel(s)),
                              ),
                            ),
                          ],
                          onChanged: (v) {
                            ref
                                .read(adminPlaquesQueryProvider.notifier)
                                .state = query.copyWith(
                              status: v ?? '',
                              page: 1,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: kUzinduziDivider),
            Expanded(
              child: plaques.when(
                data: (result) {
                  if (result.items.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: Text(
                          'No plaques match those filters.',
                          style: TextStyle(color: kUzinduziGrey),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          itemCount: result.items.length,
                          separatorBuilder: (_, _) => const Divider(
                            height: 1,
                            color: kUzinduziDivider,
                          ),
                          itemBuilder: (_, i) => PlaqueRowCard(
                            plaque: result.items[i],
                            onTap: () =>
                                _openDetail(result.items[i].id),
                          ),
                        ),
                      ),
                      _Pagination(
                        page: result.page,
                        pageCount: result.pageCount,
                        total: result.total,
                        onPrev: result.page > 1
                            ? () => ref
                                .read(adminPlaquesQueryProvider.notifier)
                                .state = query.copyWith(
                                    page: result.page - 1)
                            : null,
                        onNext: result.page < result.pageCount
                            ? () => ref
                                .read(adminPlaquesQueryProvider.notifier)
                                .state = query.copyWith(
                                    page: result.page + 1)
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
                      'Error loading plaques:\n$e',
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

  Future<void> _openDetail(String id) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdminPlaqueDetailScreen(plaqueId: id),
      ),
    );
    ref.invalidate(adminPlaquesProvider);
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