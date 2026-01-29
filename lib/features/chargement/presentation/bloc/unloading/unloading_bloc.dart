import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../domain/entities/chargement_entity.dart';
import '../../../domain/usecases/get_chargements.dart';
import '../../../domain/usecases/update_chargement.dart';

part 'unloading_event.dart';
part 'unloading_state.dart';

class UnloadingBloc extends Bloc<UnloadingEvent, UnloadingState> {
  final GetChargements getChargements;
  final UpdateChargement updateChargement;
  final FlutterSecureStorage secureStorage;

  UnloadingBloc({
    required this.getChargements,
    required this.updateChargement,
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
    final result = await getChargements();
    result.fold((failure) => emit(UnloadingError(failure.message)), (
      chargements,
    ) {
      final validStatuses = [
        'UNLOADED',
        'dechargé',
        'RETURNED',
        'REJECTED',
        'retourner',
        'rejeter',
      ];
      final unloadingList = chargements
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
      final filtered = currentState.chargements.where((t) {
        return t.numeroFiche.toLowerCase().contains(query) ||
            (t.sticker.toLowerCase().contains(query));
      }).toList();
      emit(UnloadingLoaded(currentState.chargements, filtered: filtered));
    }
  }

  Future<void> _onUpdateKOR(
    UpdateUnloadingKOREvent event,
    Emitter<UnloadingState> emit,
  ) async {
    final key = 'kor_modified_${event.chargement.numeroFiche}';
    final alreadyModified = await secureStorage.read(key: key);

    if (alreadyModified == 'true') {
      emit(UnloadingError("Le KOR ne peut être modifié qu'une seule fois."));
      return;
    }

    emit(UnloadingLoading());

    // Update the local entity with new KOR
    final updatedChargement = event.chargement.copyWith(destKor: event.kor);

    // Call updateRemote
    final result = await updateChargement(updatedChargement);
    result.fold((failure) => emit(UnloadingError(failure.message)), (_) async {
      // Mark as modified
      await secureStorage.write(key: key, value: 'true');
      add(LoadUnloadingsEvent());
    });
  }
}
