import 'package:equatable/equatable.dart';

class CommodityEntity extends Equatable {
  final String id;
  final String name;
  final String code;
  final bool isActive;

  const CommodityEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, code, isActive];
}
