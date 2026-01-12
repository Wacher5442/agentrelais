import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/transfert_entity.dart';

class SubmissionResult {
  final String submissionId;
  final bool viaHttp;
  final int totalUssdParts; // 0 si HTTP

  SubmissionResult({
    required this.submissionId,
    required this.viaHttp,
    this.totalUssdParts = 0,
  });
}

abstract class TransfertRepository {
  // Soumettre un nouveau transfert
  Future<Either<Failure, SubmissionResult>> submitTransfert({
    required TransfertEntity transfert,
    required bool forceUssd,
  });

  // Récupérer la liste des transferts (Clean Architecture)
  Future<Either<Failure, List<TransfertEntity>>> getTransferts();

  // Synchroniser les attente
  Future<int> syncPendingHttpTransferts();
}
