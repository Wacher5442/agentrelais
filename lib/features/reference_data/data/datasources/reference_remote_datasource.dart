import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions.dart';

class ReferenceRemoteDataSource {
  final DioClient dioClient;

  ReferenceRemoteDataSource(this.dioClient);

  Future<List<Map<String, dynamic>>> getRegions() async {
    return _fetchItems('${_baseUrl}regions');
  }

  Future<List<Map<String, dynamic>>> getDepartments(String regionId) async {
    return _fetchItems('${_baseUrl}regions/$regionId/departments');
  }

  Future<List<Map<String, dynamic>>> getSubPrefectures(
    String departmentId,
  ) async {
    return _fetchItems('${_baseUrl}departments/$departmentId/sub-prefectures');
  }

  Future<List<Map<String, dynamic>>> getSectors(String subPrefectureId) async {
    return _fetchItems('${_baseUrl}sub-prefectures/$subPrefectureId/sectors');
  }

  Future<List<Map<String, dynamic>>> getZds(String sectorId) async {
    return _fetchItems('${_baseUrl}sectors/$sectorId/zds');
  }

  Future<List<Map<String, dynamic>>> getLocalites(String zdId) async {
    return _fetchItems('${_baseUrl}zds/$zdId/localites');
  }

  Future<List<Map<String, dynamic>>> getQuarters(String localiteId) async {
    return _fetchItems('${_baseUrl}localites/$localiteId/quarters');
  }

  Future<List<Map<String, dynamic>>> getWarehouses() async {
    final baseUrl =
        dotenv.env['BASE_URL_WAREHOUSES'] ??
        'https://coco-backend.com/warehouse/';
    try {
      final response = await dioClient.get(baseUrl);
      // Based on USER REQUEST:
      // { "items": [ ... ], "total": ... }
      if (response.data is Map && response.data.containsKey('items')) {
        return List<Map<String, dynamic>>.from(response.data['items']);
      }
      return [];
    } on DioException catch (e) {
      throw ServerException.fromDioError(e);
    }
  }

  String get _baseUrl =>
      dotenv.env['BASE_URL_TERRITORIES'] ??
      'https://coco-backend.com/territories/';

  Future<List<Map<String, dynamic>>> _fetchItems(String url) async {
    try {
      final response = await dioClient.get(url);
      if (response.data is Map && response.data.containsKey('items')) {
        return List<Map<String, dynamic>>.from(response.data['items']);
      }
      return [];
    } on DioException catch (e) {
      throw ServerException.fromDioError(e);
    }
  }
}
