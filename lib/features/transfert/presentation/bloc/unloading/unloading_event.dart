part of 'unloading_bloc.dart';

abstract class UnloadingEvent {}

class LoadUnloadingsEvent extends UnloadingEvent {}

class SearchUnloadingEvent extends UnloadingEvent {
  final String query;
  SearchUnloadingEvent(this.query);
}

class UpdateUnloadingKOREvent extends UnloadingEvent {
  final TransfertEntity transfert;
  final String kor;
  UpdateUnloadingKOREvent(this.transfert, this.kor);
}
