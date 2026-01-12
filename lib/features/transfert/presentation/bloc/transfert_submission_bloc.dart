import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/network_info.dart';
import '../../../../core/utils/usecase.dart';
import '../../domain/usecases/submit_transfert_usecase.dart';
import '../../domain/usecases/sync_pending_transferts.dart';
import 'transfert_submission_event.dart';
import 'transfert_submission_state.dart';

class TransfertSubmissionBloc
    extends Bloc<TransfertSubmissionEvent, TransfertSubmissionState> {
  final SubmitTransfertUseCase submitUseCase;
  final SyncPendingTransferts syncUseCase;
  final NetworkInfo networkInfo;

  TransfertSubmissionBloc({
    required this.submitUseCase,
    required this.syncUseCase,
    required this.networkInfo,
  }) : super(TransfertInitial()) {
    on<SubmitTransfertEvent>(_onSubmit);
    on<RetryPendingTransfertsEvent>(_onRetry);
  }

  /// Gestion de la soumission d'un nouveau transfert
  Future<void> _onSubmit(
    SubmitTransfertEvent event,
    Emitter<TransfertSubmissionState> emit,
  ) async {
    emit(TransfertSubmitting());

    // Préparation des paramètres pour le UseCase
    final params = SubmitTransfertParams(
      transfert: event.transfert,
      forceUssd: event.forceUssd,
    );

    // Appel du UseCase
    final result = await submitUseCase(params);

    // Gestion du résultat avec Either (Fold)
    result.fold(
      (failure) => emit(TransfertSubmissionFailure(failure.message)),
      (success) => emit(TransfertSubmissionSuccess(success)),
    );
  }

  /// Gestion de la synchronisation des transferts en attente (Retry)
  Future<void> _onRetry(
    RetryPendingTransfertsEvent event,
    Emitter<TransfertSubmissionState> emit,
  ) async {
    emit(TransfertSyncInProgress());

    try {
      // 1. Vérification de la connexion via l'interface injectée
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        emit(
          TransfertSyncFailure(
            "Pas de connexion internet pour la synchronisation.",
          ),
        );
        return;
      }

      // 2. Appel du UseCase de synchronisation
      final result = await syncUseCase(NoParams());

      // 3. Gestion du résultat
      result.fold(
        (failure) => emit(TransfertSyncFailure(failure.message)),
        (syncedCount) => emit(TransfertSyncSuccess(syncedCount)),
      );
    } catch (ex) {
      // Filet de sécurité pour les erreurs non gérées par le UseCase
      emit(TransfertSyncFailure("Erreur inattendue lors de la synchro: $ex"));
    }
  }
}
