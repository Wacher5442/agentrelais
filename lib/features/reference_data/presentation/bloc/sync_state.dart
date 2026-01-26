part of 'sync_bloc.dart';

abstract class SyncState extends Equatable {
  const SyncState();
  @override
  List<Object> get props => [];
}

class SyncInitial extends SyncState {}

class SyncInProgress extends SyncState {
  final String message;
  final double progress;

  const SyncInProgress({required this.message, required this.progress});

  @override
  List<Object> get props => [message, progress];
}

class SyncSuccess extends SyncState {}

class SyncFailure extends SyncState {
  final String message;
  const SyncFailure(this.message);

  @override
  List<Object> get props => [message];
}
