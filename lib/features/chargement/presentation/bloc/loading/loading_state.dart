part of 'loading_bloc.dart';

abstract class LoadingState {}

class LoadingInitial extends LoadingState {}

class LoadingLoading extends LoadingState {}

class LoadingLoaded extends LoadingState {
  final List<ChargementEntity> chargements;
  final List<ChargementEntity> filteredChargements;

  LoadingLoaded(this.chargements, {List<ChargementEntity>? filtered})
    : filteredChargements = filtered ?? chargements;
}

class LoadingError extends LoadingState {
  final String message;
  LoadingError(this.message);
}

class LoadingActionSuccess extends LoadingState {
  final String message;
  LoadingActionSuccess(this.message);
}
