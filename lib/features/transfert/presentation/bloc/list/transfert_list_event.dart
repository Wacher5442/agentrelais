import 'package:equatable/equatable.dart';

abstract class TransfertListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Événement pour charger (ou recharger) la liste des transferts depuis la BDD
class LoadTransfertsEvent extends TransfertListEvent {}

/// (Optionnel) Événement pour filtrer la liste localement dans le BLoC
class FilterTransfertsEvent extends TransfertListEvent {
  final String? type;
  final String? status;

  FilterTransfertsEvent({this.type, this.status});

  @override
  List<Object?> get props => [type, status];
}
