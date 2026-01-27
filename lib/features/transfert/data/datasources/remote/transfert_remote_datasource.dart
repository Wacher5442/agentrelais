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
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'X-Amz-Meta-Source': 'http',
        },
      ),
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

  Future<List<dynamic>> getRemoteTransferts() async {
    try {
      final resp = await dioClient.get('/transfers');
      if (resp.statusCode == 200) {
        return resp.data['items'] as List<dynamic>;
      }
      throw Exception('Failed to get transfers');
    } catch (e) {
      log("Error fetching transfers: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateTransfert(
    String sheetNumber,
    String codeCampaign,
    Map<String, dynamic> data,
  ) async {
    try {
      final resp = await dioClient.patch(
        '/commodities/transfer/$sheetNumber/$codeCampaign',
        data: data,
      );
      if (resp.statusCode == 200) {
        return resp.data;
      }
      throw Exception('Failed to update transfer');
    } catch (e) {
      log("Error updating transfer: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateStatus(
    String sheetNumber,
    String codeCampaign,
    String status,
  ) async {
    try {
      final resp = await dioClient.patch(
        '/commodities/transfer/$sheetNumber/$codeCampaign/status',
        data: {'status': status},
      );
      if (resp.statusCode == 200) {
        return resp.data;
      }
      throw Exception('Failed to update status');
    } catch (e) {
      log("Error updating status: $e");
      rethrow;
    }
  }
}
