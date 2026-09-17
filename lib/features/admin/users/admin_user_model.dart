class AdminUserRow {
  final String id;
  final String userName;
  final String email;
  final String role;
  final bool isEmailVerified;
  final bool isDemoAccount;
  final bool isSuspended;
  final DateTime? lastLoginAt;
  final DateTime createdAt;

  const AdminUserRow({
    required this.id,
    required this.userName,
    required this.email,
    required this.role,
    required this.isEmailVerified,
    required this.isDemoAccount,
    required this.isSuspended,
    required this.lastLoginAt,
    required this.createdAt,
  });

  factory AdminUserRow.fromJson(Map<String, dynamic> j) => AdminUserRow(
        id: j['id'] as String,
        userName: (j['userName'] ?? '') as String,
        email: (j['email'] ?? '') as String,
        role: (j['role'] ?? 'fan') as String,
        isEmailVerified: j['isEmailVerified'] as bool? ?? false,
        isDemoAccount: j['isDemoAccount'] as bool? ?? false,
        isSuspended: j['isSuspended'] as bool? ?? false,
        lastLoginAt: j['lastLoginAt'] != null
            ? DateTime.tryParse(j['lastLoginAt'].toString())
            : null,
        createdAt: DateTime.tryParse(j['createdAt'].toString()) ??
            DateTime.now(),
      );

  String get initials {
    if (userName.isEmpty) return '?';
    final parts = userName.split(RegExp(r'[._\s]+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return userName[0].toUpperCase();
  }

  String get displayName => userName;
}
