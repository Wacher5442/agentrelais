import 'package:equatable/equatable.dart';

abstract class GlobalSyncState extends Equatable {
  const GlobalSyncState();

  @override
  List<Object> get props => [];
}

class GlobalSyncInitial extends GlobalSyncState {}

class GlobalSyncInProgress extends GlobalSyncState {}

class GlobalSyncSuccess extends GlobalSyncState {}
