const _override = String.fromEnvironment('API_BASE');

String platformDefaultApiBase() => _override.isNotEmpty
    ? _override
    : 'https://api.uzinduziafrica.com';