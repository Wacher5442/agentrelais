part of 'loading_bloc.dart';

abstract class LoadingState {}

class LoadingInitial extends LoadingState {}

class LoadingLoading extends LoadingState {}

class LoadingLoaded extends LoadingState {
  final List<TransfertEntity> transferts;
  final List<TransfertEntity> filteredTransferts;

  LoadingLoaded(this.transferts, {List<TransfertEntity>? filtered})
    : filteredTransferts = filtered ?? transferts;
}

class LoadingError extends LoadingState {
  final String message;
  LoadingError(this.message);
}

class LoadingActionSuccess extends LoadingState {
  final String message;
  LoadingActionSuccess(this.message);
}
