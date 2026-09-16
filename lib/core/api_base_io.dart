import 'dart:io';

const _override = String.fromEnvironment('API_BASE');

String platformDefaultApiBase() {
  // 1. Explicit override always wins (real devices, CI, staging)
  if (_override.isNotEmpty) return _override;

  // 2. Emulator/simulator defaults
  if (Platform.isAndroid) return 'http://10.0.2.2:5000';
  if (Platform.isIOS) return 'http://localhost:5000';

  // 3. Desktop
  return 'http://localhost:5000';
}