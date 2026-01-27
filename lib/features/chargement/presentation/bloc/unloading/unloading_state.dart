part of 'unloading_bloc.dart';

abstract class UnloadingState {}

class UnloadingInitial extends UnloadingState {}

class UnloadingLoading extends UnloadingState {}

class UnloadingLoaded extends UnloadingState {
  final List<ChargementEntity> chargements;
  final List<ChargementEntity> filteredChargements;

  UnloadingLoaded(this.chargements, {List<ChargementEntity>? filtered})
    : filteredChargements = filtered ?? chargements;
}

class UnloadingError extends UnloadingState {
  final String message;
  UnloadingError(this.message);
}

class UnloadingActionSuccess extends UnloadingState {
  final String message;
  UnloadingActionSuccess(this.message);
}
