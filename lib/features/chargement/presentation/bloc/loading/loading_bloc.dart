import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/chargement_entity.dart';
import '../../../domain/usecases/get_chargements.dart';
import '../../../domain/usecases/update_chargement.dart';

part 'loading_event.dart';
part 'loading_state.dart';

class LoadingBloc extends Bloc<LoadingEvent, LoadingState> {
  final GetChargements getChargements;
  final UpdateChargementStatus updateChargementStatus;
  final UpdateChargement updateChargement;

  LoadingBloc({
    required this.getChargements,
    required this.updateChargementStatus,
    required this.updateChargement,
  }) : super(LoadingInitial()) {
    on<LoadLoadingsEvent>(_onLoadLoadings);
    on<SearchLoadingEvent>(_onSearchLoading);
    on<UpdateLoadingStatusEvent>(_onUpdateStatus);
    on<UpdateLoadingDetailsEvent>(_onUpdateDetails);
  }

  Future<void> _onLoadLoadings(
    LoadLoadingsEvent event,
    Emitter<LoadingState> emit,
  ) async {
    emit(LoadingLoading());
    final result = await getChargements();
    result.fold((failure) => emit(LoadingError(failure.message)), (
      chargements,
    ) {
      final validStatuses = [
        'PENDING',
        'OK_FOR_CONTROL',
        'en_attente',
        'ok_pour_controle',
      ];
      final loadingList = chargements
          .where(
            (t) =>
                validStatuses.contains(t.status) ||
                validStatuses.contains(t.status.toUpperCase()),
          )
          .toList();
      emit(LoadingLoaded(loadingList));
    });
  }

  void _onSearchLoading(SearchLoadingEvent event, Emitter<LoadingState> emit) {
    if (state is LoadingLoaded) {
      final currentState = state as LoadingLoaded;
      final query = event.query.toLowerCase();
      final filtered = currentState.chargements.where((t) {
        return t.numeroFiche.toString().toLowerCase().contains(query) ||
            (t.sticker.toString().toLowerCase().contains(query));
      }).toList();
      emit(LoadingLoaded(currentState.chargements, filtered: filtered));
    }
  }

  Future<void> _onUpdateStatus(
    UpdateLoadingStatusEvent event,
    Emitter<LoadingState> emit,
  ) async {
    emit(LoadingLoading());
    final result = await updateChargementStatus(
      event.chargement.numeroFiche,
      event.chargement.campagne,
      event.status,
    );
    result.fold((failure) => emit(LoadingError(failure.message)), (_) {
      emit(LoadingStatusSuccess("Statut mis à jour"));
      add(LoadLoadingsEvent());
    });
  }

  Future<void> _onUpdateDetails(
    UpdateLoadingDetailsEvent event,
    Emitter<LoadingState> emit,
  ) async {
    emit(LoadingLoading());
    final result = await updateChargement(event.chargement);
    result.fold((failure) => emit(LoadingError(failure.message)), (_) {
      // Success message handled by UI listening to stream or rebuilt logic
      // Ideally we emit LoadingActionSuccess but then we lose list state.
      // For simplicity we reload. UI should handle transition.
      emit(LoadingActionSuccess("Mise à jour effectuée"));
      add(LoadLoadingsEvent());
    });
  }
}
