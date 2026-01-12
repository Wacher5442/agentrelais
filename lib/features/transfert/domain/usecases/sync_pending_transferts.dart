import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/transfert_repository.dart';

class SyncPendingTransferts implements UseCase<int, NoParams> {
  final TransfertRepository repo;

  SyncPendingTransferts(this.repo);

  /// Exécute la synchronisation de TOUS les reçus non-HTTP.
  /// Retourne un 'Right(int)' avec le nombre de reçus synchronisés,
  /// ou un 'Left(Failure)' en cas d'erreur.
  @override
  Future<Either<Failure, int>> call(NoParams params) async {
    try {
      final count = await repo.syncPendingHttpTransferts();
      return Right(count); // Retourne un "Right" en cas de succès
    } catch (e) {
      print('Sync UseCase a échoué: ${e.toString()}');
      // Retourne un "Left" en cas d'échec
      return Left(
        GenericFailure('Échec de la synchronisation : ${e.toString()}'),
      );
    }
  }
}
