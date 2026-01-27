part of 'loading_bloc.dart';

abstract class LoadingEvent {}

class LoadLoadingsEvent extends LoadingEvent {}

class SearchLoadingEvent extends LoadingEvent {
  final String query;
  SearchLoadingEvent(this.query);
}

class UpdateLoadingStatusEvent extends LoadingEvent {
  final ChargementEntity chargement;
  final String status;
  UpdateLoadingStatusEvent(this.chargement, this.status);
}

class UpdateLoadingDetailsEvent extends LoadingEvent {
  final ChargementEntity chargement;
  UpdateLoadingDetailsEvent(this.chargement);
}
