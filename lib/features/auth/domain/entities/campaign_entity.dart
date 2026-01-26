import 'package:equatable/equatable.dart';

class CampaignEntity extends Equatable {
  final String id;
  final String name;
  final String code;
  final String commodityCode;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String status; // PENDING, OPEN, CLOSED

  const CampaignEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.commodityCode,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    commodityCode,
    startDate,
    endDate,
    isActive,
    status,
  ];
}
