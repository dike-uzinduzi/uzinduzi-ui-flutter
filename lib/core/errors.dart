class AppError implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  AppError(this.message, {this.statusCode, this.code});

  @override
  String toString() => message;

  factory AppError.fromDio(dynamic error) {
    try {
      final response = error.response;
      if (response?.data is Map) {
        final data = response!.data as Map;
        return AppError(
          (data['message'] ?? data['error'] ?? 'Request failed').toString(),
          statusCode: response.statusCode,
          code: data['code']?.toString(),
        );
      }
      if (response?.statusCode != null) {
        return AppError('Request failed (${response!.statusCode})',
            statusCode: response.statusCode);
      }
    } catch (_) {}
    return AppError(error?.message?.toString() ?? 'Something went wrong');
  }
}
