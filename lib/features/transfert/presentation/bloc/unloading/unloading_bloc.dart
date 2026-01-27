import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../domain/entities/transfert_entity.dart';
import '../../../domain/usecases/get_remote_transferts.dart';
import '../../../domain/usecases/update_transfert_usecase.dart';

part 'unloading_event.dart';
part 'unloading_state.dart';

class UnloadingBloc extends Bloc<UnloadingEvent, UnloadingState> {
  final GetRemoteTransferts getRemoteTransferts;
  final UpdateTransfertRemote updateRemote;
  final FlutterSecureStorage secureStorage;

  UnloadingBloc({
    required this.getRemoteTransferts,
    required this.updateRemote,
    required this.secureStorage,
  }) : super(UnloadingInitial()) {
    on<LoadUnloadingsEvent>(_onLoadUnloadings);
    on<SearchUnloadingEvent>(_onSearchUnloading);
    on<UpdateUnloadingKOREvent>(_onUpdateKOR);
  }

  Future<void> _onLoadUnloadings(
    LoadUnloadingsEvent event,
    Emitter<UnloadingState> emit,
  ) async {
    emit(UnloadingLoading());
    final result = await getRemoteTransferts();
    result.fold((failure) => emit(UnloadingError(failure.message)), (
      transferts,
    ) {
      final validStatuses = ['UNLOADED', 'dechargé'];
      final unloadingList = transferts
          .where(
            (t) =>
                validStatuses.contains(t.status) ||
                validStatuses.contains(t.status.toUpperCase()),
          )
          .toList();

      emit(UnloadingLoaded(unloadingList));
    });
  }

  void _onSearchUnloading(
    SearchUnloadingEvent event,
    Emitter<UnloadingState> emit,
  ) {
    if (state is UnloadingLoaded) {
      final currentState = state as UnloadingLoaded;
      final query = event.query.toLowerCase();
      final filtered = currentState.transferts.where((t) {
        return t.numeroFiche.toLowerCase().contains(query) ||
            (t.sticker != null && t.sticker!.toLowerCase().contains(query));
      }).toList();
      emit(UnloadingLoaded(currentState.transferts, filtered: filtered));
    }
  }

  Future<void> _onUpdateKOR(
    UpdateUnloadingKOREvent event,
    Emitter<UnloadingState> emit,
  ) async {
    // Check if already modified
    final key = 'kor_modified_${event.transfert.numeroFiche}';
    final alreadyModified = await secureStorage.read(key: key);

    if (alreadyModified == 'true') {
      emit(UnloadingError("Le KOR ne peut être modifié qu'une seule fois."));
      return;
    }

    emit(UnloadingLoading());

    // Update the local entity with new KOR
    final updatedTransfert = event.transfert.copyWith(destKor: event.kor);

    // Call updateRemote
    final result = await updateRemote(updatedTransfert);
    result.fold((failure) => emit(UnloadingError(failure.message)), (_) async {
      // Mark as modified
      await secureStorage.write(key: key, value: 'true');
      add(LoadUnloadingsEvent());
    });
  }
}
