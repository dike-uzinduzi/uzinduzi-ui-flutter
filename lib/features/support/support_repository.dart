// ignore_for_file: use_null_aware_elements
import '../../core/api_client.dart';

class SupportResult {
  final bool launchIsActive;
  final String? launchStatus;
  final dynamic payment;
  final dynamic plaque;
  final String message;

  SupportResult({
    required this.launchIsActive,
    this.launchStatus,
    this.payment,
    this.plaque,
    required this.message,
  });

  bool get hasPlaque => plaque != null;
  String? get plaqueSerial => plaque?['serialNumber'];
  String? get plaqueTier => plaque?['plaqueType'];
  String? get plaqueImageUrl => plaque?['plaqueImageUrl'];
  String? get paymentReference => payment?['referenceNumber'];
  String? get paymentStatus => payment?['status'];
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
      launchIsActive: res['launchIsActive'] == true,
      launchStatus: res['launchStatus']?.toString(),
      payment: res['payment'],
      plaque: res['plaque'],
      message: (res['message'] ?? 'Support placed').toString(),
    );
  }
}