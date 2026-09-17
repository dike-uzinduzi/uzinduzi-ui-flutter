import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../album_detail_provider.dart';

class SupportSliderBlock extends ConsumerStatefulWidget {
  final String albumId;
  final VoidCallback onSupport;
  final bool enabled;

  const SupportSliderBlock({
    super.key,
    required this.albumId,
    required this.onSupport,
    this.enabled = true,
  });

  @override
  ConsumerState<SupportSliderBlock> createState() => _SupportSliderBlockState();
}

class _SupportSliderBlockState extends ConsumerState<SupportSliderBlock> {
  final _customController = TextEditingController();
  bool _customActive = false;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  double _snapToTier(double v) {
    const thresholds = [51.0, 101.0, 301.0, 501.0, 701.0, 901.0];
    for (final t in thresholds) {
      if ((v - t).abs() <= 15) return t;
    }
    return v;
  }

  String _fmt(double v) =>
      v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);

  @override
  Widget build(BuildContext context) {
    final amount = ref.watch(selectedAmountProvider(widget.albumId));

    return Container(
      decoration: const BoxDecoration(
        color: kUzinduziWhite,
        border: Border(top: BorderSide(color: kUzinduziDivider)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Row 1: amount + step buttons ─────────
            Row(
              children: [
                Text(
                  '\$${_fmt(amount)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: kUzinduziBlack,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                _StepButton(
                  label: '−\$10',
                  onTap: !widget.enabled || _customActive
                      ? null
                      : () {
                          final next =
                              (amount - 10).clamp(1, 1000).toDouble();
                          ref
                              .read(selectedAmountProvider(widget.albumId)
                                  .notifier)
                              .state = next;
                        },
                ),
                const SizedBox(width: 6),
                _StepButton(
                  label: '+\$10',
                  onTap: !widget.enabled || _customActive
                      ? null
                      : () {
                          final next =
                              (amount + 10).clamp(1, 1000).toDouble();
                          ref
                              .read(selectedAmountProvider(widget.albumId)
                                  .notifier)
                              .state = next;
                        },
                ),
              ],
            ),
            const SizedBox(height: 2),

            // ── Row 2: slider (compact) ──────────────
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 18),
                activeTrackColor: kUzinduziRed,
                inactiveTrackColor: kUzinduziDivider,
                thumbColor: kUzinduziRed,
                overlayColor: kUzinduziRed.withValues(alpha: 0.15),
              ),
              child: Slider(
                value: _customActive ? 1000 : amount.clamp(1, 1000),
                min: 1,
                max: 1000,
                onChanged: !widget.enabled || _customActive
                    ? null
                    : (v) {
                        ref
                            .read(selectedAmountProvider(widget.albumId)
                                .notifier)
                            .state = v;
                      },
                onChangeEnd: (v) {
                  final snapped = _snapToTier(v);
                  ref
                      .read(selectedAmountProvider(widget.albumId).notifier)
                      .state = snapped;
                },
              ),
            ),

            // ── Row 3: min/max + custom inline ───────
            Row(
              children: [
                const Text(
                  '\$1',
                  style: TextStyle(fontSize: 11, color: kUzinduziGrey),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _customController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      prefixText: '\$ ',
                      hintText: 'Custom',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (v) {
                      final parsed = double.tryParse(v);
                      setState(() {
                        _customActive = parsed != null && parsed > 1000;
                      });
                      if (_customActive && parsed != null) {
                        ref
                            .read(selectedAmountProvider(widget.albumId)
                                .notifier)
                            .state = parsed;
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '\$1000',
                  style: TextStyle(fontSize: 11, color: kUzinduziGrey),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Row 4: CTA ───────────────────────────
            SizedBox(
              height: 44,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.enabled ? widget.onSupport : null,
                child: Text('Support \$${_fmt(amount)}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _StepButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: kUzinduziWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kUzinduziDivider),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: onTap == null ? kUzinduziGrey : kUzinduziBlack,
          ),
        ),
      ),
    );
  }
}