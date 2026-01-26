import '../../domain/entities/commodity_entity.dart';

class CommodityModel extends CommodityEntity {
  const CommodityModel({
    required super.id,
    required super.name,
    required super.code,
    required super.isActive,
  });

  factory CommodityModel.fromJson(Map<String, dynamic> json) {
    return CommodityModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'code': code, 'is_active': isActive};
  }

  factory CommodityModel.fromMap(Map<String, dynamic> map) {
    return CommodityModel(
      id: map['id'] as String,
      name: map['name'] as String,
      code: map['code'] as String,
      isActive: (map['is_active'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'is_active': isActive ? 1 : 0,
    };
  }
}
