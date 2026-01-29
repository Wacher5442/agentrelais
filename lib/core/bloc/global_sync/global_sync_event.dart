import 'package:equatable/equatable.dart';

abstract class GlobalSyncEvent extends Equatable {
  const GlobalSyncEvent();

  @override
  List<Object> get props => [];
}

class SyncStarted extends GlobalSyncEvent {}

class SyncFinished extends GlobalSyncEvent {}
