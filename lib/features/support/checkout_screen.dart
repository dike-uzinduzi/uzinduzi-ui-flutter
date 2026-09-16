import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/errors.dart';
import '../../core/theme.dart';
import '../albums/plaque_tier_models.dart';
import 'payment_pending_screen.dart';
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

  // EcoCash-specific phone (independent of shipping phone)
  final _ecocashPhone = TextEditingController();

  String _country = 'Zimbabwe';
  String _paymentMethod = 'ECOCASH';
  bool _busy = false;
  String? _error;

  bool get _requiresShipping => widget.tier != null;
  bool get _isEcocash => _paymentMethod == 'ECOCASH';

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _whatsapp.dispose();
    _addressLine1.dispose();
    _addressLine2.dispose();
    _city.dispose();
    _postalCode.dispose();
    _ecocashPhone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);

    // 1. Shipping validation
    if (_requiresShipping) {
      if (!_formKey.currentState!.validate()) return;
    }

    // 2. EcoCash phone required
    if (_isEcocash &&
        _ecocashPhone.text.trim().isEmpty &&
        _phone.text.trim().isEmpty) {
      setState(() => _error = 'Enter your EcoCash phone number');
      return;
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

      // Prefer the EcoCash phone, fall back to the shipping phone
      final phoneForPayment = _isEcocash
          ? (_ecocashPhone.text.trim().isNotEmpty
              ? _ecocashPhone.text.trim()
              : _phone.text.trim())
          : _phone.text.trim();

      final result = await ref.read(supportRepositoryProvider).support(
            albumId: widget.albumId,
            amount: widget.amount,
            currency: 'USD',
            paymentMethod: _paymentMethod,
            customerPhone: phoneForPayment.isEmpty ? null : phoneForPayment,
            shippingAddress: shipping,
          );

      if (!mounted) return;

      // Demo: instant success
      if (result.demo) {
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
        return;
      }

      // Real path
      if (result.referenceNumber == null) {
        throw Exception('Missing payment reference');
      }

      if (result.needsRedirect) {
        await launchUrl(
          Uri.parse(result.redirectUrl!),
          webOnlyWindowName: '_blank',
          mode: LaunchMode.externalApplication,
        );
        if (!mounted) return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentPendingScreen(
            albumId: widget.albumId,
            albumTitle: widget.albumTitle,
            artistName: widget.artistName,
            coverArt: widget.coverArt,
            tier: widget.tier,
            amount: widget.amount,
            referenceNumber: result.referenceNumber!,
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

              // Shipping form (only when a plaque ships)
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

              // Payment method
              PaymentPicker(
                value: _paymentMethod,
                onChanged: (v) => setState(() => _paymentMethod = v),
              ),

              // EcoCash phone field (only when EcoCash selected)
              if (_isEcocash) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kUzinduziRed.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kUzinduziRed.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.phone_android, color: kUzinduziRed, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'EcoCash number',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: kUzinduziBlack,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Pesepay will send a payment prompt to this number.',
                        style: TextStyle(fontSize: 12, color: kUzinduziGrey),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _ecocashPhone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d+\s-]')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'EcoCash number',
                          hintText: '+263771234567',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

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