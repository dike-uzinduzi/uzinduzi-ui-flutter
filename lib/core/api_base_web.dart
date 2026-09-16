const _override = String.fromEnvironment('API_BASE');

String platformDefaultApiBase() {
  // 1. Build-time override still wins (staging, previews)
  if (_override.isNotEmpty) return _override;

  // 2. Production default
  return 'https://apI.uzinduziafrica.com';
}
