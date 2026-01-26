import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/db/db_helper.dart';
import '../models/user_model.dart';
import '../models/commodity_model.dart';
import '../models/campaign_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String accessToken, String refreshToken);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearCache();
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getLastUser();
  Future<void> saveActiveRegion(String region);
  Future<String?> getActiveRegion();

  // Commodities
  Future<void> saveCommodities(List<CommodityModel> commodities);
  Future<List<CommodityModel>> getCommodities();

  // Campaigns
  Future<void> saveCampaigns(List<CampaignModel> campaigns);
  Future<List<CampaignModel>> getCampaigns();
  Future<CampaignModel?> getActiveCampaignForCommodity(String commodityCode);

  // App Preferences
  Future<void> saveSelectedCommodity(String commodityCode);
  Future<String?> getSelectedCommodity();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final DbHelper dbHelper;

  AuthLocalDataSourceImpl(this.secureStorage, this.dbHelper);

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

  // Commodities
  @override
  Future<void> saveCommodities(List<CommodityModel> commodities) async {
    final db = await dbHelper.database;
    // Clear existing commodities
    await db.delete('commodities');
    // Insert new ones
    for (var commodity in commodities) {
      await db.insert('commodities', commodity.toMap());
    }
  }

  @override
  Future<List<CommodityModel>> getCommodities() async {
    final rows = await dbHelper.query('commodities', orderBy: 'name ASC');
    return rows.map((row) => CommodityModel.fromMap(row)).toList();
  }

  // Campaigns
  @override
  Future<void> saveCampaigns(List<CampaignModel> campaigns) async {
    final db = await dbHelper.database;
    // Clear existing campaigns
    await db.delete('campaigns');
    // Insert new ones
    for (var campaign in campaigns) {
      await db.insert('campaigns', campaign.toMap());
    }
  }

  @override
  Future<List<CampaignModel>> getCampaigns() async {
    final rows = await dbHelper.query('campaigns', orderBy: 'name ASC');
    return rows.map((row) => CampaignModel.fromMap(row)).toList();
  }

  @override
  Future<CampaignModel?> getActiveCampaignForCommodity(
    String commodityCode,
  ) async {
    final rows = await dbHelper.query(
      'campaigns',
      where: 'commodity_code = ? AND is_active = ? AND status = ?',
      whereArgs: [commodityCode, 1, 'OPEN'],
    );

    if (rows.isEmpty) return null;
    return CampaignModel.fromMap(rows.first);
  }

  // App Preferences
  @override
  Future<void> saveSelectedCommodity(String commodityCode) async {
    await dbHelper.database;
    await dbHelper.update(
      'app_preferences',
      {'value': commodityCode},
      'key = ?',
      ['selected_commodity'],
    );
  }

  @override
  Future<String?> getSelectedCommodity() async {
    final rows = await dbHelper.query(
      'app_preferences',
      where: 'key = ?',
      whereArgs: ['selected_commodity'],
    );

    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }
}
