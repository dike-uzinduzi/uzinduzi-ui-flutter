import 'package:flutter/material.dart';

class AdminPayment {
  final String id;
  final String referenceNumber;
  final String? ecocashReference;
  final String status;
  final double amount;
  final String currency;
  final String? reason;
  final String? customerEmail;
  final String? customerPhone;
  final String? paymentMethod;
  final String? plaqueType;
  final bool paid;
  final bool isDemo;
  final bool? qualifiesForPlaque;
  final String? qualifiedTier;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final String? albumId;
  final String? albumTitle;
  final String? albumCoverArt;
  final String? plaqueId;
  final String? plaqueSerial;
  final String? plaqueStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AdminPayment({
    required this.id,
    required this.referenceNumber,
    this.ecocashReference,
    required this.status,
    required this.amount,
    required this.currency,
    this.reason,
    this.customerEmail,
    this.customerPhone,
    this.paymentMethod,
    this.plaqueType,
    this.paid = false,
    this.isDemo = false,
    this.qualifiesForPlaque,
    this.qualifiedTier,
    this.userId,
    this.userName,
    this.userEmail,
    this.albumId,
    this.albumTitle,
    this.albumCoverArt,
    this.plaqueId,
    this.plaqueSerial,
    this.plaqueStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminPayment.fromJson(Map<String, dynamic> j) {
    final user = j['User'] is Map
        ? Map<String, dynamic>.from(j['User'] as Map)
        : j['user'] is Map
            ? Map<String, dynamic>.from(j['user'] as Map)
            : null;
    final album = j['Album'] is Map
        ? Map<String, dynamic>.from(j['Album'] as Map)
        : j['album'] is Map
            ? Map<String, dynamic>.from(j['album'] as Map)
            : null;
    final plaque = j['Plaque'] is Map
        ? Map<String, dynamic>.from(j['Plaque'] as Map)
        : j['plaque'] is Map
            ? Map<String, dynamic>.from(j['plaque'] as Map)
            : null;

    double amt(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return AdminPayment(
      id: (j['id'] ?? '').toString(),
      referenceNumber: (j['referenceNumber'] ?? '').toString(),
      ecocashReference: j['ecocashReference']?.toString(),
      status: (j['status'] ?? 'PENDING').toString(),
      amount: amt(j['amount']),
      currency: (j['currency'] ?? 'USD').toString(),
      reason: j['reason']?.toString(),
      customerEmail: j['customerEmail']?.toString(),
      customerPhone: j['customerPhone']?.toString(),
      paymentMethod: j['paymentMethod']?.toString(),
      plaqueType: j['plaqueType']?.toString(),
      paid: j['paid'] as bool? ?? false,
      isDemo: j['isDemo'] as bool? ?? false,
      qualifiesForPlaque: j['qualifiesForPlaque'] as bool?,
      qualifiedTier: j['qualifiedTier']?.toString(),
      userId: j['userId']?.toString() ?? user?['id']?.toString(),
      userName: user?['userName']?.toString(),
      userEmail:
          user?['email']?.toString() ?? j['customerEmail']?.toString(),
      albumId: j['albumId']?.toString() ?? album?['id']?.toString(),
      albumTitle: album?['title']?.toString(),
      albumCoverArt: album?['cover_art']?.toString(),
      plaqueId: plaque?['id']?.toString(),
      plaqueSerial: plaque?['serialNumber']?.toString(),
      plaqueStatus: plaque?['status']?.toString(),
      createdAt: j['createdAt'] != null
          ? DateTime.tryParse(j['createdAt'].toString())
          : null,
      updatedAt: j['updatedAt'] != null
          ? DateTime.tryParse(j['updatedAt'].toString())
          : null,
    );
  }

  String get amountLabel {
    if (currency == 'USD') return '\$${amount.toStringAsFixed(2)}';
    return '$currency ${amount.toStringAsFixed(2)}';
  }
}

const kPaymentStatuses = <String>[
  'PENDING',
  'SUCCESS',
  'FAILED',
  'SETTLEMENT_COMPLETED',
  'PAID',
];

String paymentStatusLabel(String s) => switch (s) {
      'PENDING' => 'Pending',
      'SUCCESS' => 'Success',
      'FAILED' => 'Failed',
      'SETTLEMENT_COMPLETED' => 'Settled',
      'PAID' => 'Paid',
      _ => s,
    };

Color paymentStatusColor(String s, Color Function() resolve) => s.isEmpty
    ? resolve()
    : switch (s) {
        'SUCCESS' || 'PAID' || 'SETTLEMENT_COMPLETED' =>
          const Color(0xFF2E7D32),
        'PENDING' => const Color(0xFFD32F2F),
        'FAILED' => const Color(0xFF757575),
        _ => const Color(0xFF757575),
      };

String paymentMethodLabel(String? m) => switch (m) {
      'card' => 'Card',
      'mobile_money' => 'Mobile money',
      'bank_transfer' => 'Bank transfer',
      'cash' => 'Cash',
      'paypal' => 'PayPal',
      null => '—',
      _ => m,
    };