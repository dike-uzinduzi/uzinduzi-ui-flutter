import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme.dart';

class ShippingForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullName;
  final TextEditingController phone;
  final TextEditingController whatsapp;
  final TextEditingController addressLine1;
  final TextEditingController addressLine2;
  final TextEditingController city;
  final TextEditingController postalCode;
  final String country;
  final ValueChanged<String> onCountryChanged;

  const ShippingForm({
    super.key,
    required this.formKey,
    required this.fullName,
    required this.phone,
    required this.whatsapp,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.postalCode,
    required this.country,
    required this.onCountryChanged,
  });

  static final _e164 = RegExp(r'^\+?[1-9]\d{1,14}$');

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery details',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: kUzinduziGrey,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'For shipping your physical plaque',
            style: TextStyle(fontSize: 12, color: kUzinduziGrey),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: fullName,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Full name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: phone,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d+\s-]')),
            ],
            decoration: const InputDecoration(
              labelText: 'Phone number',
              hintText: '+263771234567',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Phone is required';
              final cleaned = v.replaceAll(RegExp(r'[\s-]'), '');
              if (!_e164.hasMatch(cleaned)) return 'Use international format (+263...)';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: whatsapp,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d+\s-]')),
            ],
            decoration: const InputDecoration(
              labelText: 'WhatsApp (optional)',
              hintText: '+263771234567',
              prefixIcon: Icon(Icons.chat_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: addressLine1,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Address line 1',
              prefixIcon: Icon(Icons.home_outlined),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Address is required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: addressLine2,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Address line 2 (optional)',
              prefixIcon: Icon(Icons.home_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: city,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'City',
              prefixIcon: Icon(Icons.location_city_outlined),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'City is required' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: country,
            decoration: const InputDecoration(
              labelText: 'Country',
              prefixIcon: Icon(Icons.public),
            ),
            items: const [
              DropdownMenuItem(value: 'Zimbabwe', child: Text('Zimbabwe')),
              DropdownMenuItem(value: 'South Africa', child: Text('South Africa')),
              DropdownMenuItem(value: 'Zambia', child: Text('Zambia')),
              DropdownMenuItem(value: 'Mozambique', child: Text('Mozambique')),
              DropdownMenuItem(value: 'Botswana', child: Text('Botswana')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (v) => v != null ? onCountryChanged(v) : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: postalCode,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Postal code (optional)',
              prefixIcon: Icon(Icons.markunread_mailbox_outlined),
            ),
          ),
        ],
      ),
    );
  }
}