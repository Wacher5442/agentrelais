import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/transfert_repository.dart';

class SyncPendingTransferts implements UseCase<int, NoParams> {
  final TransfertRepository repo;

  SyncPendingTransferts(this.repo);

  @override
  Future<Either<Failure, int>> call(NoParams params) async {
    try {
      final count = await repo.syncPendingHttpTransferts();
      return Right(count);
    } catch (e) {
      print('Sync UseCase a échoué: ${e.toString()}');
      return Left(
        GenericFailure('Échec de la synchronisation : ${e.toString()}'),
      );
    }
  }
}
