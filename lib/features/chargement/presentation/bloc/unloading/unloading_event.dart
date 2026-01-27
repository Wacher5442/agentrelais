part of 'unloading_bloc.dart';

abstract class UnloadingEvent {}

class LoadUnloadingsEvent extends UnloadingEvent {}

class SearchUnloadingEvent extends UnloadingEvent {
  final String query;
  SearchUnloadingEvent(this.query);
}

class UpdateUnloadingKOREvent extends UnloadingEvent {
  final ChargementEntity chargement;
  final String kor;
  UpdateUnloadingKOREvent(this.chargement, this.kor);
}
