import 'package:flutter/material.dart';

import '../../../../core/theme.dart';
import '../admin_payment_model.dart';

class PaymentRowCard extends StatelessWidget {
  final AdminPayment payment;
  final VoidCallback onTap;

  const PaymentRowCard({
    super.key,
    required this.payment,
    required this.onTap,
  });

  Color get _statusColor => switch (payment.status) {
        'SUCCESS' || 'PAID' || 'SETTLEMENT_COMPLETED' => kStatusLive,
        'PENDING' => kUzinduziRed,
        'FAILED' => kUzinduziGrey,
        _ => kUzinduziGrey,
      };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kUzinduziWhite,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          payment.amountLabel,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: kUzinduziBlack,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            paymentStatusLabel(payment.status).toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: _statusColor,
                            ),
                          ),
                        ),
                        if (payment.isDemo) ...[
                          const SizedBox(width: 8),
                          const Text(
                            'DEMO',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: kUzinduziGrey,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      payment.userName ??
                          payment.userEmail ??
                          payment.customerEmail ??
                          '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: kUzinduziBlack,
                      ),
                    ),
                    Text(
                      [
                        if (payment.albumTitle != null) payment.albumTitle!,
                        if (payment.paymentMethod != null)
                          paymentMethodLabel(payment.paymentMethod),
                      ].join('  ·  '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: kUzinduziGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (payment.createdAt != null)
                    Text(
                      '${payment.createdAt!.year}-'
                      '${payment.createdAt!.month.toString().padLeft(2, '0')}-'
                      '${payment.createdAt!.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: kUzinduziGrey,
                      ),
                    ),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right, color: kUzinduziGrey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}