import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme.dart';

enum PaymentIconType { material, svg }

class PaymentMethod {
  final String key;
  final String label;
  final String description;
  final IconData? icon;
  final String? iconSvg;
  final PaymentIconType iconType;

  const PaymentMethod({
    required this.key,
    required this.label,
    required this.description,
    this.icon,
    this.iconSvg,
    required this.iconType,
  });
}

const kPaymentMethods = <PaymentMethod>[
  PaymentMethod(
    key: 'ECOCASH',
    label: 'EcoCash',
    description: 'Pay directly from your EcoCash wallet',
    icon: Icons.phone_android,
    iconType: PaymentIconType.material,
  ),
  PaymentMethod(
    key: 'PESEPAY',
    label: 'Pesepay',
    description: 'InnBucks · Card · ZimSwitch · More',
    iconSvg: 'assets/icons/pesepay-logo.svg',
    iconType: PaymentIconType.svg,
  ),
];

class PaymentPicker extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const PaymentPicker({super.key, required this.value, required this.onChanged});

  Widget _buildIcon(PaymentMethod m) {
    if (m.iconType == PaymentIconType.svg && m.iconSvg != null) {
      return SvgPicture.asset(
        m.iconSvg!,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => const SizedBox(
          width: 24,
          height: 24,
          child: Icon(Icons.credit_card, size: 22, color: kUzinduziBlack),
        ),
      );
    }
    return Icon(m.icon ?? Icons.payment, size: 22, color: kUzinduziBlack);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment method',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: kUzinduziGrey,
          ),
        ),
        const SizedBox(height: 12),
        for (final m in kPaymentMethods)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => onChanged(m.key),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kUzinduziWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: value == m.key ? kUzinduziRed : kUzinduziDivider,
                    width: value == m.key ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: value == m.key ? kUzinduziRed : kUzinduziGrey,
                          width: 2,
                        ),
                      ),
                      child: value == m.key
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: kUzinduziRed,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 48,
                      height: 32,
                      child: Center(child: _buildIcon(m)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.label,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: kUzinduziBlack,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            m.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: kUzinduziGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
