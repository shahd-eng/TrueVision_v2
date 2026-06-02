import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:true_vision/features/detection/core/detection_media_type.dart';
import 'package:true_vision/features/auth/data/token_storage.dart';

class DetectionUploadException implements Exception {
  DetectionUploadException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => 'DetectionUploadException(statusCode: $statusCode, message: $message)';
}

class DetectionUploadService {
  DetectionUploadService({http.Client? client, TokenStorage? tokenStorage})
      : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage;
  static const String _baseUrl = 'http://graduationapiproject.runasp.net/api/v1/upload';
  final http.Client _client;
  final TokenStorage? _tokenStorage;


  Future<Map<String, dynamic>> getAiDetectionResult(File file, DetectionMediaType type) async {
    String finalUrl;
    String fileKey;
    switch (type) {
      case DetectionMediaType.image:
        finalUrl = 'https://manicure-sulphuric-sputter.ngrok-free.dev/classify';
        fileKey = 'image';
        break;
      case DetectionMediaType.audio:
        finalUrl = 'https://unmarine-virgen-spiriferous.ngrok-free.dev/Predict_Audio';
        fileKey = 'audio';
        break;
      case DetectionMediaType.video:
        finalUrl = 'https://starlet-navigate-appealing.ngrok-free.dev/predict';
        fileKey = 'file';
        break;

    }
    var request = http.MultipartRequest('POST', Uri.parse(finalUrl));
    request.files.add(await http.MultipartFile.fromPath(fileKey, file.path));
    try {
      final streamedResponse = await _client.send(request).timeout(const Duration(minutes: 5));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw DetectionUploadException('AI Server Error: ${response.statusCode}', statusCode: response.statusCode);
      }
    } catch (e) {
      throw DetectionUploadException('Failed to connect to AI server: $e');
    }
  }

  // ---------------------------------------------------------
  // 2. وظيفة الرفع للباك إند الأساسي (للأرشفة) - بدون تغيير
  // ---------------------------------------------------------
  Future<Map<String, dynamic>> uploadMedia({required File file, required DetectionMediaType type}) async {
    final token = _tokenStorage?.getToken();
    if (token == null || token.isEmpty) {
      throw DetectionUploadException('Authentication token is missing.');
    }

    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/image'));
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    final fileExtension = file.path.split('.').last;
    request.files.add(await http.MultipartFile.fromPath('File', file.path, contentType: MediaType(_getMainType(type), fileExtension)));
    request.fields['Path'] = _pathFor(type);

    try {
      final streamedResponse = await _client.send(request).timeout(const Duration(minutes: 2));
      final response = await http.Response.fromStream(streamedResponse);
      return _handleJsonResponse(response);
    } catch (e) {
      throw DetectionUploadException('Upload failed: $e');
    }
  }

  String _getMainType(DetectionMediaType type) => type.name;
  String _pathFor(DetectionMediaType type) {
    switch (type) {
      case DetectionMediaType.image: return '1';
      case DetectionMediaType.video: return '4';
      case DetectionMediaType.audio: return '5';
    }
  }

  Map<String, dynamic> _handleJsonResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) ?? {};
    }
    throw DetectionUploadException('Server error', statusCode: response.statusCode);
  }
}