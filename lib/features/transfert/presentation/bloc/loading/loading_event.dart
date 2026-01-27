part of 'loading_bloc.dart';

abstract class LoadingEvent {}

class LoadLoadingsEvent extends LoadingEvent {}

class SearchLoadingEvent extends LoadingEvent {
  final String query;
  SearchLoadingEvent(this.query);
}

class UpdateLoadingStatusEvent extends LoadingEvent {
  final TransfertEntity transfert;
  final String status;
  UpdateLoadingStatusEvent(this.transfert, this.status);
}

class UpdateLoadingDetailsEvent extends LoadingEvent {
  final TransfertEntity transfert;
  UpdateLoadingDetailsEvent(this.transfert);
}
