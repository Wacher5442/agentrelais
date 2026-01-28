import 'dart:developer';
import '../../../../core/network/dio_client.dart';

class ChargementRemoteDataSource {
  final DioClient dioClient;

  ChargementRemoteDataSource(this.dioClient);

  Future<List<dynamic>> getChargements() async {
    try {
      final resp = await dioClient.get('/transfers');
      if (resp.statusCode == 200) {
        return resp.data['items'] as List<dynamic>;
      }
      throw Exception('Failed to get transfers: ${resp.statusCode}');
    } catch (e) {
      log("Error fetching transfers: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateChargement(
    String sheetNumber,
    String codeCampaign,
    Map<String, dynamic> data,
  ) async {
    try {
      final resp = await dioClient.patch(
        '/transfer/$sheetNumber/$codeCampaign',
        data: data,
      );
      if (resp.statusCode == 200) {
        return resp.data;
      }
      throw Exception('Failed to update transfer: ${resp.statusCode}');
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
        '/transfer/$sheetNumber/$codeCampaign/status',
        data: {'status': status},
      );
      if (resp.statusCode == 200) {
        return resp.data;
      }
      throw Exception('Failed to update status: ${resp.statusCode}');
    } catch (e) {
      log("Error updating status: $e");
      rethrow;
    }
  }

  /// Fetch receipts for a specific bundle
  Future<List<Map<String, dynamic>>> getReceipts(String bundleId) async {
    try {
      final resp = await dioClient.get(
        '/receipts',
        queryParameters: {'bundle_id': bundleId},
      );
      if (resp.statusCode == 200) {
        final items = resp.data['items'] as List<dynamic>?;
        return items?.cast<Map<String, dynamic>>() ?? [];
      }
      throw Exception('Failed to get receipts: ${resp.statusCode}');
    } catch (e) {
      log("Error fetching receipts: $e");
      rethrow;
    }
  }
}
