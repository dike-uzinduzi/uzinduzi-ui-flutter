import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../core/theme.dart';
import '../albums/plaque_tier_models.dart';
import 'support_providers.dart';
import 'success_screen.dart';
import 'widgets/order_summary.dart';
import 'widgets/payment_picker.dart';
import 'widgets/shipping_form.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String albumId;
  final String albumTitle;
  final String artistName;
  final String? coverArt;
  final PlaqueTier? tier;
  final double amount;

  const CheckoutScreen({
    super.key,
    required this.albumId,
    required this.albumTitle,
    required this.artistName,
    this.coverArt,
    required this.tier,
    required this.amount,
  });

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _whatsapp = TextEditingController();
  final _addressLine1 = TextEditingController();
  final _addressLine2 = TextEditingController();
  final _city = TextEditingController();
  final _postalCode = TextEditingController();

  String _country = 'Zimbabwe';
  String _paymentMethod = 'ECOCASH';
  bool _busy = false;
  String? _error;

  bool get _requiresShipping => widget.tier != null;

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _whatsapp.dispose();
    _addressLine1.dispose();
    _addressLine2.dispose();
    _city.dispose();
    _postalCode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);

    if (_requiresShipping) {
      if (!_formKey.currentState!.validate()) return;
    }

    setState(() => _busy = true);

    try {
      Map<String, dynamic>? shipping;
      if (_requiresShipping) {
        shipping = {
          'fullName': _fullName.text.trim(),
          'phone': _phone.text.trim(),
          'whatsapp': _whatsapp.text.trim(),
          'addressLine1': _addressLine1.text.trim(),
          'addressLine2': _addressLine2.text.trim(),
          'city': _city.text.trim(),
          'country': _country,
          'postalCode': _postalCode.text.trim(),
        };
      }

      final result = await ref.read(supportRepositoryProvider).support(
            albumId: widget.albumId,
            amount: widget.amount,
            currency: 'USD',
            paymentMethod: _paymentMethod,
            customerPhone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            shippingAddress: shipping,
          );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SuccessScreen(
            albumTitle: widget.albumTitle,
            artistName: widget.artistName,
            tier: widget.tier,
            amount: widget.amount,
            result: result,
            shippingAddress: shipping,
          ),
        ),
      );
    } catch (e) {
      final msg = e is AppError ? e.message : e.toString();
      if (mounted) {
        setState(() {
          _busy = false;
          _error = msg;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kUzinduziWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              OrderSummary(
                albumTitle: widget.albumTitle,
                artistName: widget.artistName,
                coverArt: widget.coverArt,
                tier: widget.tier,
                amount: widget.amount,
              ),
              const SizedBox(height: 24),

              if (_requiresShipping) ...[
                ShippingForm(
                  formKey: _formKey,
                  fullName: _fullName,
                  phone: _phone,
                  whatsapp: _whatsapp,
                  addressLine1: _addressLine1,
                  addressLine2: _addressLine2,
                  city: _city,
                  postalCode: _postalCode,
                  country: _country,
                  onCountryChanged: (v) => setState(() => _country = v),
                ),
                const SizedBox(height: 24),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kUzinduziRed.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kUzinduziRed.withValues(alpha: 0.15)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.favorite, color: kUzinduziRed, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No physical plaque at this amount — just a heartfelt thank you.',
                          style: TextStyle(fontSize: 13, color: kUzinduziBlack),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              PaymentPicker(
                value: _paymentMethod,
                onChanged: (v) => setState(() => _paymentMethod = v),
              ),

              const SizedBox(height: 24),

              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: kStatusFailed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kStatusFailed.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: kStatusFailed, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(fontSize: 13, color: kStatusFailed),
                        ),
                      ),
                    ],
                  ),
                ),

           SizedBox(
  height: 52,
  child: ElevatedButton(
    onPressed: _busy ? null : _submit,
    child: _busy
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          )
        : Text(
            'Pay \$${widget.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
  ),
),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}