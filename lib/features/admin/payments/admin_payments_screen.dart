import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import 'admin_payment_detail_screen.dart';
import 'admin_payment_model.dart';
import 'admin_payments_provider.dart';
import 'widgets/payment_row_card.dart';

class AdminPaymentsScreen extends ConsumerStatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  ConsumerState<AdminPaymentsScreen> createState() =>
      _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends ConsumerState<AdminPaymentsScreen> {
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
    final query = ref.watch(adminPaymentsQueryProvider);
    final payments = ref.watch(adminPaymentsProvider);
    final stats = ref.watch(adminPaymentsStatsProvider);

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
                        'Payments',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: kUzinduziBlack,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          ref.invalidate(adminPaymentsProvider);
                          ref.invalidate(adminPaymentsStatsProvider);
                        },
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  stats.when(
                    data: (s) => _StatsBar(stats: s),
                    loading: () =>
                        const LinearProgressIndicator(minHeight: 2),
                    error: (_, _) => const SizedBox.shrink(),
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
                                  .read(adminPaymentsQueryProvider.notifier)
                                  .state = query.copyWith(
                                search: v,
                                page: 1,
                              );
                            });
                          },
                          decoration: InputDecoration(
                            hintText:
                                'Search reference / email / phone',
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
                        width: 200,
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
                            ...kPaymentStatuses.map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(paymentStatusLabel(s)),
                              ),
                            ),
                          ],
                          onChanged: (v) {
                            ref
                                .read(adminPaymentsQueryProvider.notifier)
                                .state = query.copyWith(
                              status: v ?? '',
                              page: 1,
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: DropdownButtonFormField<String>(
                          initialValue: query.method,
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
                          items: const [
                            DropdownMenuItem(
                              value: '',
                              child: Text('All methods'),
                            ),
                            DropdownMenuItem(
                              value: 'card',
                              child: Text('Card'),
                            ),
                            DropdownMenuItem(
                              value: 'mobile_money',
                              child: Text('Mobile money'),
                            ),
                            DropdownMenuItem(
                              value: 'bank_transfer',
                              child: Text('Bank transfer'),
                            ),
                            DropdownMenuItem(
                              value: 'cash',
                              child: Text('Cash'),
                            ),
                            DropdownMenuItem(
                              value: 'paypal',
                              child: Text('PayPal'),
                            ),
                          ],
                          onChanged: (v) {
                            ref
                                .read(adminPaymentsQueryProvider.notifier)
                                .state = query.copyWith(
                              method: v ?? '',
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
              child: payments.when(
                data: (result) {
                  if (result.items.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: Text(
                          'No payments match those filters.',
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
                          itemBuilder: (_, i) => PaymentRowCard(
                            payment: result.items[i],
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
                                .read(adminPaymentsQueryProvider.notifier)
                                .state = query.copyWith(
                                    page: result.page - 1)
                            : null,
                        onNext: result.page < result.pageCount
                            ? () => ref
                                .read(adminPaymentsQueryProvider.notifier)
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
                      'Error loading payments:\n$e',
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
        builder: (_) => AdminPaymentDetailScreen(paymentId: id),
      ),
    );
    ref.invalidate(adminPaymentsProvider);
    ref.invalidate(adminPaymentsStatsProvider);
  }
}

class _StatsBar extends StatelessWidget {
  const _StatsBar({required this.stats});
  final PaymentsStats stats;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _StatTile(label: 'Total', value: '${stats.total}'),
        _StatTile(label: 'Success', value: '${stats.success}'),
        _StatTile(label: 'Pending', value: '${stats.pending}'),
        _StatTile(label: 'Failed', value: '${stats.failed}'),
        _StatTile(label: 'Revenue', value: stats.revenueLabel, accent: true),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    this.accent = false,
  });

  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: accent
            ? kUzinduziRed.withValues(alpha: 0.08)
            : kUzinduziDivider.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: accent
              ? kUzinduziRed.withValues(alpha: 0.3)
              : kUzinduziDivider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: accent ? kUzinduziRed : kUzinduziGrey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: accent ? kUzinduziRed : kUzinduziBlack,
            ),
          ),
        ],
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