import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../../core/network/dio_client.dart';

class TransfertRemoteDataSource {
  final DioClient dioClient;
  TransfertRemoteDataSource(this.dioClient);

  Future<String> getUploadUrl(String filetype, String username) async {
    try {
      log("Submission ID fetching url $filetype");
      final baseUrl =
          dotenv.env['BASE_URL_OBJECT_GATEWAY'] ??
          'https://maracko-backend.dev.go.incubtek.com/object-gateway/api/presigned/get-upload-url';

      final resp = await dioClient.post(
        baseUrl,
        data: {'file_type': filetype, 'agent_id': username},
      );

      log("Upload URL: ${resp.data['url']}");
      if (resp.statusCode == 200 && resp.data['url'] != null) {
        return resp.data['url'];
      }
      throw Exception('Failed to get upload URL');
    } catch (e) {
      log("Error fetching upload URL: $e");
      rethrow;
    }
  }

  Future<void> uploadTransfert({
    required String url,
    required Map<String, dynamic> payload,
  }) async {
    // The API expects a PUT request with application/json
    final resp = await dioClient.put(
      url,
      data: payload,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('HTTP upload failed: ${resp.statusCode}');
    }
  }

  Future<bool> ping() async {
    try {
      final resp = await dioClient.get('/ping');
      log("ping $resp");
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void logFormData(FormData formData) {
    log('================ FORM DATA =================');

    // Champs simples
    for (final field in formData.fields) {
      log('FIELD → ${field.key}: ${field.value}');
    }

    log('============== END FORM DATA ==============');
  }
}
