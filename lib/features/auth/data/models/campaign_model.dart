import '../../domain/entities/campaign_entity.dart';

class CampaignModel extends CampaignEntity {
  const CampaignModel({
    required super.id,
    required super.name,
    required super.code,
    required super.commodityCode,
    required super.startDate,
    required super.endDate,
    required super.isActive,
    required super.status,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      commodityCode: json['commodity_code'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      isActive: json['is_active'] ?? false,
      status: json['status'] ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'commodity_code': commodityCode,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
      'status': status,
    };
  }

  factory CampaignModel.fromMap(Map<String, dynamic> map) {
    return CampaignModel(
      id: map['id'] as String,
      name: map['name'] as String,
      code: map['code'] as String,
      commodityCode: map['commodity_code'] as String,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['end_date'] as int),
      isActive: (map['is_active'] as int) == 1,
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'commodity_code': commodityCode,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate.millisecondsSinceEpoch,
      'is_active': isActive ? 1 : 0,
      'status': status,
    };
  }
}
