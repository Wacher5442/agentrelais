import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/usecase.dart'; // Assumant que vous avez une classe paramètre
import '../entities/transfert_entity.dart';
import '../repositories/transfert_repository.dart';

// Classe de paramètres pour le UseCase
class SubmitTransfertParams {
  final TransfertEntity transfert;
  final bool forceUssd;

  SubmitTransfertParams({required this.transfert, this.forceUssd = false});
}

class SubmitTransfertUseCase
    implements UseCase<SubmissionResult, SubmitTransfertParams> {
  final TransfertRepository repo;

  SubmitTransfertUseCase({required this.repo});

  @override
  Future<Either<Failure, SubmissionResult>> call(
    SubmitTransfertParams params,
  ) async {
    // Le UseCase délègue simplement au Repository qui gère la logique technique (HTTP/USSD/DB)
    return await repo.submitTransfert(
      transfert: params.transfert,
      forceUssd: params.forceUssd,
    );
  }
}
