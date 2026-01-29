import 'package:flutter_bloc/flutter_bloc.dart';
import 'global_sync_event.dart';
import 'global_sync_state.dart';

class GlobalSyncBloc extends Bloc<GlobalSyncEvent, GlobalSyncState> {
  GlobalSyncBloc() : super(GlobalSyncInitial()) {
    on<SyncStarted>((event, emit) => emit(GlobalSyncInProgress()));
    on<SyncFinished>((event, emit) => emit(GlobalSyncSuccess()));
  }
}
