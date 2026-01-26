part of 'sync_bloc.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object> get props => [];
}

class SyncStarted extends SyncEvent {
  final User? user; // Optional user to get region from

  const SyncStarted({this.user});

  @override
  List<Object> get props => [if (user != null) user!];
}
