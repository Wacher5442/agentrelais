// lib/domain/usecases/sync_pending_receipts.dart

import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/receipt_repository.dart';

class SyncPendingReceipts implements UseCase<int, NoParams> {
  final ReceiptRepository repo;

  SyncPendingReceipts(this.repo);

  /// Synchronise tous les reçus en attente
  /// Retourne le nombre de reçus synchronisés avec succès
  @override
  Future<Either<Failure, int>> call(NoParams params) async {
    try {
      final count = await repo.syncPendingReceipts();
      return Right(count);
    } catch (e) {
      return Left(
        GenericFailure('Échec de la synchronisation: ${e.toString()}'),
      );
    }
  }
}
