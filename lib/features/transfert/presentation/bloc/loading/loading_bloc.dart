import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/transfert_entity.dart';
import '../../../domain/usecases/get_remote_transferts.dart';
import '../../../domain/usecases/update_transfert_usecase.dart';

part 'loading_event.dart';
part 'loading_state.dart';

class LoadingBloc extends Bloc<LoadingEvent, LoadingState> {
  final GetRemoteTransferts getRemoteTransferts;
  final UpdateTransfertStatus updateStatus;
  final UpdateTransfertRemote updateRemote;

  LoadingBloc({
    required this.getRemoteTransferts,
    required this.updateStatus,
    required this.updateRemote,
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
    final result = await getRemoteTransferts();
    result.fold((failure) => emit(LoadingError(failure.message)), (transferts) {
      // Filter for PENDING status (and maybe others like OK_FOR_CONTROL if they appear in list?)
      // User says: "Un chargement est un transfert(chargement ou déchargement) avec le statut en attente."
      // And "Quand il donne sont OK pour le chargement, le statut devient Ok pour contrôle"
      // And "Par la suite... ajoute infos... statut passe à dechargé."
      // So Loading List should show PENDING and possibly OK_FOR_CONTROL?
      // User: "afficher la liste des chargements... Un chargement est un transfert avec le statut en attente."
      // implies ONLY pending? But if it becomes OK_FOR_CONTROL, does it disappear from the list?
      // "Et là les études seront faites, par la suite de quoi il peut venir modifier ou ajouter des informations"
      // This implies he finds it AGAIN. So the list MUST include OK_FOR_CONTROL too.
      final validStatuses = [
        'PENDING',
        'OK_FOR_CONTROL',
        'en_attente',
        'ok_pour_controle',
      ];
      final loadingList = transferts
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
      final filtered = currentState.transferts.where((t) {
        return t.numeroFiche.toLowerCase().contains(query) ||
            (t.sticker != null && t.sticker!.toLowerCase().contains(query));
      }).toList();
      emit(LoadingLoaded(currentState.transferts, filtered: filtered));
    }
  }

  Future<void> _onUpdateStatus(
    UpdateLoadingStatusEvent event,
    Emitter<LoadingState> emit,
  ) async {
    emit(LoadingLoading());
    final result = await updateStatus(
      event.transfert.numeroFiche,
      event.transfert.campagne,
      event.status,
    );
    result.fold((failure) => emit(LoadingError(failure.message)), (_) {
      // Reload list after success
      add(LoadLoadingsEvent());
    });
  }

  Future<void> _onUpdateDetails(
    UpdateLoadingDetailsEvent event,
    Emitter<LoadingState> emit,
  ) async {
    emit(LoadingLoading());
    final result = await updateRemote(event.transfert);
    result.fold((failure) => emit(LoadingError(failure.message)), (_) {
      add(LoadLoadingsEvent());
    });
  }
}
