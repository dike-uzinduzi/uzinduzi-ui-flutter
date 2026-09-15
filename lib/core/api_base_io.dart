import 'dart:io';

String platformDefaultApiBase() {
  if (Platform.isAndroid) {
    // Android emulator can't reach host's localhost directly.
    // 10.0.2.2 is the special alias for the host machine.
    // Real devices must use --dart-define=API_BASE=http://<LAN-IP>:5000
    return 'http://10.0.2.2:5000';
  }
  if (Platform.isIOS) {
    // iOS simulator shares the host's network stack, so localhost works.
    // Real iOS devices need --dart-define=API_BASE=http://<LAN-IP>:5000
    return 'http://localhost:5000';
  }
  // Linux, macOS, Windows desktop
  return 'http://localhost:5000';
}