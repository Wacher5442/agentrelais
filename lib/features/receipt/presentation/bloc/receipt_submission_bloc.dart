import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/network_info.dart';
import '../../../../core/utils/usecase.dart';
import '../../domain/usecases/submit_receipt_usecase.dart';
import '../../domain/usecases/sync_pending_receipts.dart';
import 'receipt_submission_event.dart';
import 'receipt_submission_state.dart';

class ReceiptSubmissionBloc
    extends Bloc<ReceiptSubmissionEvent, ReceiptSubmissionState> {
  final SubmitReceiptUseCase submitUseCase;
  final SyncPendingReceipts syncUseCase;
  final NetworkInfo networkInfo;

  ReceiptSubmissionBloc({
    required this.submitUseCase,
    required this.syncUseCase,
    required this.networkInfo,
  }) : super(ReceiptInitial()) {
    on<SubmitReceiptEvent>(_onSubmit);
    on<RetryPendingReceiptsEvent>(_onRetry);
  }

  Future<void> _onSubmit(SubmitReceiptEvent e, Emitter emit) async {
    emit(ReceiptSubmitting());
    try {
      final result = await submitUseCase.execute(
        numeroRecu: e.form.numeroRecu ?? '',
        campagne: e.form.campagne ?? '2025-2026',
        fields: e.form.toJson(),
        agentId: e.form.agentId ?? 'AGENT_UNKNOWN',
        photoPath: e.form.photoPath,
      );
      emit(ReceiptSubmissionSuccess(result));
    } catch (ex) {
      emit(ReceiptSubmissionFailure(ex.toString()));
    }
  }

  Future<void> _onRetry(RetryPendingReceiptsEvent e, Emitter emit) async {
    emit(ReceiptSyncInProgress());
    try {
      // 1. Vérifier la connexion
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        emit(
          ReceiptSyncFailure(
            "Pas de connexion internet pour la synchronisation.",
          ),
        );
        return;
      }

      // 2. Appeler le use case
      final result = await syncUseCase.call(NoParams());

      // 3. Gérer le résultat
      result.fold(
        (failure) => emit(ReceiptSyncFailure(failure.message)),
        (syncedCount) => emit(ReceiptSyncSuccess(syncedCount)),
      );
    } catch (ex) {
      emit(ReceiptSyncFailure(ex.toString()));
    }
  }
}
