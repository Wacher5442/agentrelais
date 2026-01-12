import 'package:equatable/equatable.dart';

import '../../../domain/entities/transfert_entity.dart';

abstract class TransfertListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TransfertListInitial extends TransfertListState {}

class TransfertListLoading extends TransfertListState {}

class TransfertListLoaded extends TransfertListState {
  final List<TransfertEntity> transferts;

  TransfertListLoaded(this.transferts);

  @override
  List<Object?> get props => [transferts];
}

class TransfertListEmpty extends TransfertListState {}

class TransfertListError extends TransfertListState {
  final String message;

  TransfertListError(this.message);

  @override
  List<Object?> get props => [message];
}
