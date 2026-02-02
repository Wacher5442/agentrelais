import 'package:equatable/equatable.dart';

abstract class TransfertListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTransfertsEvent extends TransfertListEvent {}

class FilterTransfertsEvent extends TransfertListEvent {
  final String? type;
  final String? status;

  FilterTransfertsEvent({this.type, this.status});

  @override
  List<Object?> get props => [type, status];
}
