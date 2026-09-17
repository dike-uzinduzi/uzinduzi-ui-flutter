import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_phone_field/smart_phone_field.dart';

import '../../core/errors.dart';
import '../../core/theme.dart';
import '../../widgets/auth_error_dialog.dart';
import '../auth/auth_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _contactEmail;
  late final TextEditingController _nationalId;
  late final TextEditingController _country;
  late final TextEditingController _address;
  late final TextEditingController _bio;

  // Phone — the SmartPhoneField manages formatting; we only store E.164.
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();

  String? _phoneE164;
  String? _whatsappE164;
  String? _countryIso;
  String _phoneInitialIso = 'ZW';
  String _whatsappInitialIso = 'ZW';
  bool _whatsappSameAsPhone = false;

  DateTime? _dateOfBirth;
  String? _gender;

  bool _saving = false;
  bool _uploading = false;
  Uint8List? _pendingAvatar;

  @override
  void initState() {
    super.initState();
    final u = ref.read(authControllerProvider).valueOrNull;

    _firstName    = TextEditingController(text: u?.firstName ?? '');
    _lastName     = TextEditingController(text: u?.lastName ?? '');
    _contactEmail = TextEditingController(text: u?.contactEmail ?? '');
    _nationalId   = TextEditingController(text: u?.nationalId ?? '');
    _country      = TextEditingController(text: u?.countryOfResidence ?? '');
    _countryIso   = _isoForCountryName(u?.countryOfResidence);
    _address      = TextEditingController(text: u?.address ?? '');
    _bio          = TextEditingController(text: u?.bio ?? '');

    // Seed phone fields from stored E.164 values
    final phone = u?.phoneNumber ?? '';
    final whatsapp = u?.whatsappNumber ?? '';

    _phoneE164 = phone.isEmpty ? null : phone;
    _whatsappE164 = whatsapp.isEmpty ? null : whatsapp;

    _phoneInitialIso = _isoFromE164(phone) ?? 'ZW';
    _whatsappInitialIso = _isoFromE164(whatsapp) ?? 'ZW';

    _phoneController.text = _nationalFromE164(phone);
    _whatsappController.text = _nationalFromE164(whatsapp);

    if (whatsapp.isNotEmpty && whatsapp == phone) {
      _whatsappSameAsPhone = true;
    }

    _dateOfBirth = u?.dateOfBirth;
    _gender      = u?.gender;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _contactEmail.dispose();
    _nationalId.dispose();
    _country.dispose();
    _address.dispose();
    _bio.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final bytes = await picked.readAsBytes();
      await ref.read(authControllerProvider.notifier).uploadAvatar(
            bytes: bytes,
            fileName: picked.name,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar updated')),
      );
      setState(() => _pendingAvatar = null);
    } catch (e) {
      if (!mounted) return;
      await AuthErrorDialog.show(
        context,
        title: 'Upload failed',
        message: e is AppError ? e.message : 'Could not upload image.',
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year - 13),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _pickCountry() async {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      favorite: const ['ZW', 'ZA', 'GB', 'US'],
      countryListTheme: CountryListThemeData(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Start typing to search',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      onSelect: (Country country) {
        setState(() {
          _country.text = country.name;
          _countryIso = country.countryCode;
        });
      },
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await ref.read(authControllerProvider.notifier).updateProfile(
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim(),
            contactEmail: _contactEmail.text.trim().isEmpty
                ? null
                : _contactEmail.text.trim(),
            phoneNumber: (_phoneE164?.isEmpty ?? true) ? null : _phoneE164,
            whatsappNumber: _whatsappSameAsPhone
                ? _phoneE164
                : ((_whatsappE164?.isEmpty ?? true) ? null : _whatsappE164),
            nationalId: _nationalId.text.trim().isEmpty
                ? null
                : _nationalId.text.trim(),
            dateOfBirth: _dateOfBirth,
            gender: _gender,
            countryOfResidence: _country.text.trim().isEmpty
                ? null
                : _country.text.trim(),
            address: _address.text.trim(),
            bio: _bio.text.trim(),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      await AuthErrorDialog.show(
        context,
        title: 'Update failed',
        message: e is AppError ? e.message : 'Could not save profile.',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Best-effort: match a country name to an ISO alpha-2 code.
 String? _isoForCountryName(String? name) {
  if (name == null || name.trim().isEmpty) return null;
  final upper = name.trim().toUpperCase();
  if (upper.length == 2) return upper;

  const byName = <String, String>{
    'Zimbabwe': 'ZW', 'South Africa': 'ZA', 'Zambia': 'ZM', 'Malawi': 'MW',
    'Mozambique': 'MZ', 'Botswana': 'BW', 'Namibia': 'NA', 'Tanzania': 'TZ',
    'Kenya': 'KE', 'Uganda': 'UG', 'Nigeria': 'NG', 'Ghana': 'GH',
    'Egypt': 'EG', 'United States': 'US', 'United Kingdom': 'GB',
    'Ireland': 'IE', 'Germany': 'DE', 'France': 'FR', 'Italy': 'IT',
    'Spain': 'ES', 'Portugal': 'PT', 'Netherlands': 'NL', 'Belgium': 'BE',
    'Switzerland': 'CH', 'Austria': 'AT', 'Sweden': 'SE', 'Norway': 'NO',
    'Denmark': 'DK', 'Finland': 'FI', 'Poland': 'PL', 'Russia': 'RU',
    'Ukraine': 'UA', 'Turkey': 'TR', 'Israel': 'IL',
    'United Arab Emirates': 'AE', 'Saudi Arabia': 'SA', 'India': 'IN',
    'Pakistan': 'PK', 'Bangladesh': 'BD', 'China': 'CN', 'Japan': 'JP',
    'South Korea': 'KR', 'Singapore': 'SG', 'Malaysia': 'MY',
    'Indonesia': 'ID', 'Thailand': 'TH', 'Vietnam': 'VN',
    'Philippines': 'PH', 'Australia': 'AU', 'New Zealand': 'NZ',
    'Brazil': 'BR', 'Argentina': 'AR', 'Mexico': 'MX', 'Chile': 'CL',
    'Colombia': 'CO', 'Peru': 'PE',
  };
  return byName[name.trim()];
}

  /// Extract ISO alpha-2 from an E.164 number (best-effort).
  String? _isoFromE164(String e164) {
    if (!e164.startsWith('+')) return null;
    const table = <String, String>{
      '+263': 'ZW', '+27': 'ZA', '+260': 'ZM', '+265': 'MW', '+258': 'MZ',
      '+267': 'BW', '+264': 'NA', '+255': 'TZ', '+254': 'KE', '+256': 'UG',
      '+234': 'NG', '+233': 'GH', '+20': 'EG', '+1': 'US', '+44': 'GB',
      '+353': 'IE', '+49': 'DE', '+33': 'FR', '+39': 'IT', '+34': 'ES',
      '+351': 'PT', '+31': 'NL', '+32': 'BE', '+41': 'CH', '+43': 'AT',
      '+46': 'SE', '+47': 'NO', '+45': 'DK', '+358': 'FI', '+48': 'PL',
      '+7': 'RU', '+380': 'UA', '+90': 'TR', '+972': 'IL', '+971': 'AE',
      '+966': 'SA', '+91': 'IN', '+92': 'PK', '+880': 'BD', '+86': 'CN',
      '+81': 'JP', '+82': 'KR', '+65': 'SG', '+60': 'MY', '+62': 'ID',
      '+66': 'TH', '+84': 'VN', '+63': 'PH', '+61': 'AU', '+64': 'NZ',
      '+55': 'BR', '+54': 'AR', '+52': 'MX', '+56': 'CL', '+57': 'CO',
      '+51': 'PE',
    };
    final entries = table.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    for (final e in entries) {
      if (e164.startsWith(e.key)) return e.value;
    }
    return null;
  }

  /// Strip the international prefix, leaving national digits for the field.
  String _nationalFromE164(String e164) {
    if (!e164.startsWith('+')) return e164;
    final iso = _isoFromE164(e164);
    if (iso == null) return e164;
    const table = <String, String>{
      'ZW': '263', 'ZA': '27', 'ZM': '260', 'MW': '265', 'MZ': '258',
      'BW': '267', 'NA': '264', 'TZ': '255', 'KE': '254', 'UG': '256',
      'NG': '234', 'GH': '233', 'EG': '20', 'US': '1', 'GB': '44',
      'IE': '353', 'DE': '49', 'FR': '33', 'IT': '39', 'ES': '34',
      'PT': '351', 'NL': '31', 'BE': '32', 'CH': '41', 'AT': '43',
      'SE': '46', 'NO': '47', 'DK': '45', 'FI': '358', 'PL': '48',
      'RU': '7', 'UA': '380', 'TR': '90', 'IL': '972', 'AE': '971',
      'SA': '966', 'IN': '91', 'PK': '92', 'BD': '880', 'CN': '86',
      'JP': '81', 'KR': '82', 'SG': '65', 'MY': '60', 'ID': '62',
      'TH': '66', 'VN': '84', 'PH': '63', 'AU': '61', 'NZ': '64',
      'BR': '55', 'AR': '54', 'MX': '52', 'CL': '56', 'CO': '57',
      'PE': '51',
    };
    final dial = table[iso];
    if (dial == null) return e164;
    return e164.substring(1 + dial.length);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final avatarUrl = user?.avatarUrl;

    return Scaffold(
      backgroundColor: kUzinduziWhite,
      appBar: AppBar(
        title: const Text(
          'Edit profile',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: kUzinduziRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // ── Avatar ─────────────────────────────
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 56,
                        backgroundColor: kUzinduziRed.withValues(alpha: 0.1),
                        backgroundImage: _pendingAvatar != null
                            ? MemoryImage(_pendingAvatar!) as ImageProvider
                            : (avatarUrl != null && avatarUrl.isNotEmpty
                                ? CachedNetworkImageProvider(avatarUrl)
                                : null),
                        child: (_pendingAvatar == null &&
                                (avatarUrl == null || avatarUrl.isEmpty))
                            ? const Icon(
                                Icons.person,
                                size: 56,
                                color: kUzinduziRed,
                              )
                            : null,
                      ),
                      if (_uploading)
                        const Positioned.fill(
                          child: CircleAvatar(
                            backgroundColor: Colors.black45,
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Material(
                          color: kUzinduziRed,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _uploading ? null : _pickAndUploadAvatar,
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: _uploading ? null : _pickAndUploadAvatar,
                    child: const Text(
                      'Change photo',
                      style: TextStyle(
                        color: kUzinduziRed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Identity ───────────────────────────
                const _SectionLabel('Identity'),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstName,
                        decoration:
                            const InputDecoration(labelText: 'First name'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastName,
                        decoration:
                            const InputDecoration(labelText: 'Last name'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nationalId,
                  decoration: const InputDecoration(
                    labelText: 'National ID',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date of birth',
                      prefixIcon: Icon(Icons.cake_outlined),
                    ),
                    child: Text(
                      _dateOfBirth == null ? 'Not set' : _fmtDate(_dateOfBirth!),
                      style: TextStyle(
                        color: _dateOfBirth == null
                            ? kUzinduziGrey
                            : kUzinduziBlack,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _gender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: Icon(Icons.wc_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) => setState(() => _gender = v),
                ),
                const SizedBox(height: 24),

                // ── Contact ────────────────────────────
                const _SectionLabel('Contact'),
                TextFormField(
                  controller: _contactEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Contact email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 14),

                // Phone
                SmartPhoneField(
                  controller: _phoneController,
                  initialCountryCode: _phoneInitialIso,
                  onChanged: (dialCode, phoneNumber, isoCode) {
                    if (phoneNumber.isEmpty) {
                      _phoneE164 = null;
                    } else {
                      _phoneE164 = '$dialCode$phoneNumber';
                    }
                    _phoneInitialIso = isoCode;
                    if (_whatsappSameAsPhone) {
                      setState(() => _whatsappE164 = _phoneE164);
                    }
                  },
                ),
                const SizedBox(height: 4),

                // Same-as-phone toggle
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    'WhatsApp is the same as phone',
                    style: TextStyle(
                      fontSize: 13,
                      color: kUzinduziBlack,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  value: _whatsappSameAsPhone,
                  onChanged: _saving
                      ? null
                      : (v) => setState(() {
                            _whatsappSameAsPhone = v ?? false;
                            if (_whatsappSameAsPhone) {
                              _whatsappE164 = _phoneE164;
                            }
                          }),
                ),

                // WhatsApp (only shown when different)
                if (!_whatsappSameAsPhone)
                  SmartPhoneField(
                    controller: _whatsappController,
                    initialCountryCode: _whatsappInitialIso,
                    onChanged: (dialCode, phoneNumber, isoCode) {
                      if (phoneNumber.isEmpty) {
                        _whatsappE164 = null;
                      } else {
                        _whatsappE164 = '$dialCode$phoneNumber';
                      }
                      _whatsappInitialIso = isoCode;
                    },
                  ),
                const SizedBox(height: 24),

                // ── Location ───────────────────────────
                const _SectionLabel('Location'),

                // Country — searchable picker
                InkWell(
                  onTap: _saving ? null : _pickCountry,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Country',
                      prefixIcon: _countryIso == null
                          ? const Icon(Icons.public)
                          : Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                _flagEmoji(_countryIso!),
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _country.text.isEmpty
                                ? 'Not set'
                                : _country.text,
                            style: TextStyle(
                              color: _country.text.isEmpty
                                  ? kUzinduziGrey
                                  : kUzinduziBlack,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: kUzinduziGrey,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _address,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),

                // ── About ──────────────────────────────
                const _SectionLabel('About'),
                TextFormField(
                  controller: _bio,
                  maxLines: 3,
                  maxLength: 300,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    alignLabelWithHint: true,
                    hintText: 'Tell people a bit about yourself',
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save changes'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Convert an ISO 3166-1 alpha-2 code to its flag emoji.
  String _flagEmoji(String iso) {
    if (iso.length != 2) return '🌍';
    const base = 0x1F1E6; // Regional Indicator Symbol Letter A
    final upper = iso.toUpperCase();
    final first = upper.codeUnitAt(0) - 0x41 + base;
    final second = upper.codeUnitAt(1) - 0x41 + base;
    return String.fromCharCodes([first, second]);
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: kUzinduziGrey,
        ),
      ),
    );
  }
}