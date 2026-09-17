import 'package:dio/dio.dart';

class AppError implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  AppError(this.message, {this.statusCode, this.code});

  @override
  String toString() => message;

  /// Maps a DioException to a user-facing AppError.
  /// Prefers the server's `message` field, but falls back to
  /// curated messages for known HTTP status codes.
  factory AppError.fromDio(DioException error) {
    final response = error.response;
    final data = response?.data;
    final status = response?.statusCode;

    // Server returned a JSON body with a message — prefer it.
    if (data is Map && data['message'] is String) {
      final serverMsg = (data['message'] as String).trim();

      // Optionally swap known raw messages for friendlier ones.
      final friendly = _friendlyForStatus(status);
      final chosen = _looksFriendly(serverMsg) ? serverMsg : (friendly ?? serverMsg);

      return AppError(
        chosen,
        statusCode: status,
        code: data['code']?.toString(),
      );
    }

    // No usable message body — use status-based fallback.
    final friendly = _friendlyForStatus(status);
    if (friendly != null) {
      return AppError(friendly, statusCode: status);
    }

    // No response at all (network, timeout, DNS)
    return AppError(_networkMessage(error), statusCode: status);
  }

  // ── Helpers ──────────────────────────────────────────────

  static String? _friendlyForStatus(int? status) {
    switch (status) {
      case 400:
        return "That request didn't go through. Check your details and try again.";
      case 401:
        return "The email or password you entered doesn't match our records.";
      case 403:
        return "You don't have access to this yet.";
      case 404:
        return "We couldn't find what you were looking for.";
      case 409:
        return "That already exists. Try a different value.";
      case 422:
        return "Some of the information doesn't look right. Please check and try again.";
      case 429:
        return "Too many attempts. Please wait a moment and try again.";
      case 500:
      case 502:
      case 503:
      case 504:
        return "Something went wrong on our end. Please try again shortly.";
      default:
        return null;
    }
  }

  static bool _looksFriendly(String s) {
    // Treat lowercase-only or all-caps server strings as raw and replace them.
    if (s.isEmpty) return false;
    if (s == s.toLowerCase()) return false;
    if (s == s.toUpperCase()) return false;
    // Has sentence casing or punctuation — assume it's user-ready.
    return s.contains(' ') && (s.endsWith('.') || s.endsWith('!') || s.endsWith('?') || s[0] == s[0].toUpperCase());
  }

  static String _networkMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return "The connection timed out. Check your internet and try again.";
      case DioExceptionType.connectionError:
        return "We couldn't reach the server. Check your internet and try again.";
      case DioExceptionType.cancel:
        return "The request was cancelled.";
      case DioExceptionType.badCertificate:
        return "Secure connection failed. Try again on a different network.";
      case DioExceptionType.unknown:
      default:
        return "Something went wrong. Please try again.";
    }
  }
}