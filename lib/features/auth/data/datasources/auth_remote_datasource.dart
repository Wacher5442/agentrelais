import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions.dart';
import '../models/user_model.dart';
import '../models/commodity_model.dart';
import '../models/campaign_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String username, String password);
  Future<UserModel> getProfile();
  Future<void> changePassword(String userId, String newPassword);
  Future<List<CommodityModel>> getCommodities();
  Future<List<CampaignModel>> getOpenCampaigns();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await dioClient.post(
        '/login',
        data: {'username': username, 'password': password},
      );
      log('login response.data: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      throw ServerException.fromDioError(e);
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final baseUrlUser =
          dotenv.env['BASE_URL_USER'] ??
          'https://maracko-backend.dev.go.incubtek.com/profiles/';
      final response = await dioClient.get('${baseUrlUser}me');
      log('profile response.data: ${response.data}');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException.fromDioError(e);
    }
  }

  @override
  Future<void> changePassword(String userId, String newPassword) async {
    try {
      await dioClient.put(
        '/change-password/$userId',
        data: {'password': newPassword},
      );
    } on DioException catch (e) {
      throw ServerException.fromDioError(e);
    }
  }

  @override
  Future<List<CommodityModel>> getCommodities() async {
    try {
      final response = await dioClient.get('/commodities');
      final items = response.data['items'] as List;
      log('commodities response.data: ${response.data}');
      return items.map((item) => CommodityModel.fromJson(item)).toList();
    } on DioException catch (e) {
      log('Exception commodities: ${e.message}');
      throw ServerException.fromDioError(e);
    }
  }

  @override
  Future<List<CampaignModel>> getOpenCampaigns() async {
    try {
      final response = await dioClient.get(
        '/campaigns',
        queryParameters: {'status': 'OPEN'},
      );
      final items = response.data['items'] as List;
      log('campaigns response.data: ${response.data}');
      return items.map((item) => CampaignModel.fromJson(item)).toList();
    } on DioException catch (e) {
      log('Exception campaigns: ${e.message}');
      throw ServerException.fromDioError(e);
    }
  }
}
