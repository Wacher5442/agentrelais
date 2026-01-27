part of 'unloading_bloc.dart';

abstract class UnloadingState {}

class UnloadingInitial extends UnloadingState {}

class UnloadingLoading extends UnloadingState {}

class UnloadingLoaded extends UnloadingState {
  final List<TransfertEntity> transferts;
  final List<TransfertEntity> filteredTransferts;

  UnloadingLoaded(this.transferts, {List<TransfertEntity>? filtered})
    : filteredTransferts = filtered ?? transferts;
}

class UnloadingError extends UnloadingState {
  final String message;
  UnloadingError(this.message);
}

class UnloadingActionSuccess extends UnloadingState {
  final String message;
  UnloadingActionSuccess(this.message);
}
