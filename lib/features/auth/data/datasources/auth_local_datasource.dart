import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String accessToken, String refreshToken);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearCache();
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getLastUser();
  Future<void> saveActiveRegion(String region);
  Future<String?> getActiveRegion();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl(this.secureStorage);

  static const _accessTokenKey = 'ACCESS_TOKEN';
  static const _refreshTokenKey = 'REFRESH_TOKEN';
  static const _userKey = 'USER_DATA';
  static const _regionKey = 'ACTIVE_REGION';

  @override
  Future<void> saveActiveRegion(String region) async {
    await secureStorage.write(key: _regionKey, value: region);
  }

  @override
  Future<String?> getActiveRegion() async {
    return await secureStorage.read(key: _regionKey);
  }

  @override
  Future<void> cacheToken(String accessToken, String refreshToken) async {
    await secureStorage.write(key: _accessTokenKey, value: accessToken);
    await secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  @override
  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: _accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> clearCache() async {
    await secureStorage.deleteAll();
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    final jsonString = json.encode(user.toJson());
    await secureStorage.write(key: _userKey, value: jsonString);
  }

  @override
  Future<UserModel?> getLastUser() async {
    final jsonString = await secureStorage.read(key: _userKey);
    if (jsonString != null) {
      return UserModel.fromJson(json.decode(jsonString));
    }
    return null;
  }
}
