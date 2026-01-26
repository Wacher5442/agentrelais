import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String username, String password);
  Future<UserModel> getProfile();
  Future<void> changePassword(String userId, String newPassword);
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
      return response.data;
    } on DioException catch (e) {
      throw ServerException.fromDioError(e);
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final baseUrlUser =
          dotenv.env['BASE_URL_USER'] ?? 'https://coco-backend.com/profiles/';
      final response = await dioClient.get('${baseUrlUser}me');
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
}
