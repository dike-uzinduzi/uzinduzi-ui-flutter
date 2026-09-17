import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import 'admin_users_provider.dart';
import 'widgets/user_row_card.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
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
    final query = ref.watch(adminUsersQueryProvider);
    final users = ref.watch(adminUsersProvider);

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
                        'Users',
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
                            ref.invalidate(adminUsersProvider),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _Filters(
                    searchCtrl: _searchCtrl,
                    query: query,
                    onSearchChanged: (v) {
                      _debouncer.run(
                        () => ref
                            .read(adminUsersQueryProvider.notifier)
                            .setSearch(v),
                      );
                    },
                    onRoleChanged: (v) => ref
                        .read(adminUsersQueryProvider.notifier)
                        .setRole(v),
                    onVerifiedChanged: (v) => ref
                        .read(adminUsersQueryProvider.notifier)
                        .setVerified(v),
                    onSuspendedChanged: (v) => ref
                        .read(adminUsersQueryProvider.notifier)
                        .setSuspended(v),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: kUzinduziDivider),
            Expanded(
              child: users.when(
                data: (result) {
                  if (result.users.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: Text(
                          'No users match those filters.',
                          style: TextStyle(color: kUzinduziGrey),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          itemCount: result.users.length,
                          separatorBuilder: (_, _) => const Divider(
                            height: 1,
                            color: kUzinduziDivider,
                          ),
                          itemBuilder: (_, i) => UserRowCard(
                            user: result.users[i],
                          ),
                        ),
                      ),
                      _Pagination(
                        page: result.page,
                        pageCount: result.pageCount,
                        total: result.total,
                        onPrev: result.page > 1
                            ? () => ref
                                .read(adminUsersQueryProvider.notifier)
                                .setPage(result.page - 1)
                            : null,
                        onNext: result.page < result.pageCount
                            ? () => ref
                                .read(adminUsersQueryProvider.notifier)
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
                      'Error loading users:\n$e',
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
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.searchCtrl,
    required this.query,
    required this.onSearchChanged,
    required this.onRoleChanged,
    required this.onVerifiedChanged,
    required this.onSuspendedChanged,
  });

  final TextEditingController searchCtrl;
  final AdminUsersQuery query;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onRoleChanged;
  final ValueChanged<bool?> onVerifiedChanged;
  final ValueChanged<bool?> onSuspendedChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 280,
          child: TextField(
            controller: searchCtrl,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search by name or email',
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
          width: 160,
          child: DropdownButtonFormField<String>(
            initialValue: query.role,
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: const [
              DropdownMenuItem(value: '', child: Text('All roles')),
              DropdownMenuItem(value: 'fan', child: Text('Fan')),
              DropdownMenuItem(value: 'artist', child: Text('Artist')),
              DropdownMenuItem(value: 'corporate', child: Text('Corporate')),
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
              DropdownMenuItem(value: 'super_admin', child: Text('Super admin')),
            ],
            onChanged: (v) => onRoleChanged(v ?? ''),
          ),
        ),
        _TriToggle(
          label: 'Verified',
          value: query.verified,
          onChanged: onVerifiedChanged,
        ),
        _TriToggle(
          label: 'Suspended',
          value: query.suspended,
          onChanged: onSuspendedChanged,
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

  void run(VoidCallback action, {Duration delay = const Duration(milliseconds: 300)}) {
    final myToken = ++_token;
    Future.delayed(delay, () {
      if (myToken == _token) action();
    });
  }

  void dispose() {
    _token++;
  }
}
