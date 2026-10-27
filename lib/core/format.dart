// lib/core/format.dart
String maskEmail(String? e) {
  if (e == null || e.isEmpty) return '';
  final at = e.indexOf('@');
  if (at < 0) return e;
  final local = e.substring(0, at);
  final domain = e.substring(at + 1);
  final dot = domain.lastIndexOf('.');
  final domainName = dot > 0 ? domain.substring(0, dot) : domain;
  final tld = dot > 0 ? domain.substring(dot) : '';

  final vLocal = local.length <= 2 ? local[0] : local.substring(0, 2);
  final vDomain = domainName.isEmpty
      ? '***'
      : domainName.length <= 2
          ? domainName[0]
          : domainName.substring(0, 2);

  return '$vLocal***@$vDomain***$tld';
}