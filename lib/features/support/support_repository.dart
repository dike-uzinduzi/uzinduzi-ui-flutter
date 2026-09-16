// ignore_for_file: use_null_aware_elements

import '../../core/api_client.dart';

class SupportResult {
  final bool demo;
  final bool launchIsActive;
  final String? launchStatus;
  final String? provider;
  final String? referenceNumber;
  final String? redirectUrl;
  final String? pollUrl;
  final dynamic payment;
  final dynamic plaque;
  final String message;

  SupportResult({
    required this.demo,
    required this.launchIsActive,
    this.launchStatus,
    this.provider,
    this.referenceNumber,
    this.redirectUrl,
    this.pollUrl,
    this.payment,
    this.plaque,
    required this.message,
  });

  bool get hasPlaque => plaque != null;
  bool get needsRedirect => redirectUrl != null && redirectUrl!.isNotEmpty;
  bool get needsPolling => pollUrl != null && pollUrl!.isNotEmpty;

  String? get plaqueSerial => plaque?['serialNumber'];
  String? get plaqueTier => plaque?['plaqueType'];
  String? get plaqueImageUrl => plaque?['plaqueImageUrl'];
}

class PaymentStatus {
  final String referenceNumber;
  final String status;
  final String? transactionStatus;
  final bool paid;
  final bool terminal;
  final dynamic plaque;

  PaymentStatus({
    required this.referenceNumber,
    required this.status,
    this.transactionStatus,
    required this.paid,
    required this.terminal,
    this.plaque,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> j) {
    final payment = j['payment'];
    final map = payment is Map ? Map<String, dynamic>.from(payment) : j;

    return PaymentStatus(
      referenceNumber: (map['referenceNumber'] ?? j['referenceNumber'] ?? '').toString(),
      status: (map['status'] ?? j['status'] ?? 'PENDING').toString(),
      transactionStatus: (map['transactionStatus'] ?? j['transactionStatus'])?.toString(),
      paid: map['paid'] == true || j['paid'] == true,
      terminal: map['terminal'] == true ||
          j['terminal'] == true ||
          (map['status'] ?? j['status']) == 'SUCCESS' ||
          (map['status'] ?? j['status']) == 'FAILED',
      plaque: j['plaque'],
    );
  }
}

class SupportRepository {
  final ApiClient _api;
  SupportRepository(this._api);

  Future<SupportResult> support({
    required String albumId,
    required double amount,
    required String currency,
    required String paymentMethod,
    String? paymentMethodCode,
    String? customerPhone,
    String? customerEmail,
    Map<String, dynamic>? shippingAddress,
  }) async {
    final body = <String, dynamic>{
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod,
      if (paymentMethodCode != null) 'paymentMethodCode': paymentMethodCode,
      if (customerPhone != null) 'customerPhone': customerPhone,
      if (customerEmail != null) 'customerEmail': customerEmail,
      if (shippingAddress != null) 'shippingAddress': shippingAddress,
    };

    final res = await _api.post('/api/albums/$albumId/support', body: body);

    if (res['success'] != true) {
      throw Exception((res['message'] ?? 'Support failed').toString());
    }

    return SupportResult(
      demo: res['demo'] == true,
      launchIsActive: res['launchIsActive'] == true,
      launchStatus: res['launchStatus']?.toString(),
      provider: res['provider']?.toString(),
      referenceNumber: res['referenceNumber']?.toString(),
      redirectUrl: res['redirectUrl']?.toString(),
      pollUrl: res['pollUrl']?.toString(),
      payment: res['payment'],
      plaque: res['plaque'],
      message: (res['message'] ?? 'Support placed').toString(),
    );
  }

  Future<PaymentStatus> checkStatus(String referenceNumber) async {
    final res = await _api.get('/api/payments/status/$referenceNumber');
    return PaymentStatus.fromJson(res);
  }

  /// Fetch the final support result after a payment succeeds.
  /// Used by PaymentPendingScreen to build the success payload.
  Future<SupportResult> fetchResult(String referenceNumber) async {
    final res = await _api.get('/api/payments/status/$referenceNumber');
    final payment = res['payment'] ?? res;
    final plaque = res['plaque'];

    return SupportResult(
      demo: false,
      launchIsActive: false,
      provider: res['provider']?.toString(),
      referenceNumber: referenceNumber,
      payment: payment,
      plaque: plaque,
      message: 'Payment complete',
    );
  }
}