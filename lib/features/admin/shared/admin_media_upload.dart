import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api_client.dart';
import '../../../core/errors.dart';

/// Media slots supported by the backend (`/api/users/me/media/:slot`).
class MediaSlot {
  static const album = 'album';
  static const tier = 'tier';
  static const artistProfile = 'avatar';
  static const artistCover = 'cover';
  static const plaque = 'plaque';
  static const news = 'news';
}

class AdminMediaUpload {
  final ApiClient api;
  AdminMediaUpload(this.api);

  /// Picks from gallery, uploads to the given slot, and confirms.
  /// Returns the public URL on success, or null if cancelled.
  Future<String?> pickAndUpload({
    required String slot,
    Map<String, dynamic>? confirmExtra,
  }) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 88,
    );
    if (picked == null) return null;

    final bytes = await picked.readAsBytes();
    final contentType = _guessContentType(picked.name);

    // 1. presign
    final presign = await api.post(
      '/api/users/me/media/$slot/presign',
      body: {
        'contentType': contentType,
        'contentLength': bytes.length,
      },
    );
    if (presign['success'] != true) {
      throw AppError(
          presign['message']?.toString() ?? 'Could not start upload');
    }

    final uploadUrl = presign['uploadUrl'] as String;
    final key = presign['key'] as String;

    // 2. PUT to storage
    final rawDio = Dio();
    final put = await rawDio.put(
      uploadUrl,
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: {
          Headers.contentTypeHeader: contentType,
          Headers.contentLengthHeader: bytes.length,
        },
      ),
    );
    if (put.statusCode == null || put.statusCode! >= 300) {
      throw AppError('Upload failed (${put.statusCode})');
    }

    // 3. confirm
    final body = <String, dynamic>{
      'key': key,
      ...?confirmExtra,
    };
    final confirm = await api.post('/api/users/me/media/$slot', body: body);
    if (confirm['success'] != true) {
      throw AppError(
          confirm['message']?.toString() ?? 'Could not save image');
    }

    final url = confirm['url']?.toString();
    if (url == null || url.isEmpty) {
      throw AppError('Upload confirmed but no URL returned');
    }
    return url;
  }

  String _guessContentType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}