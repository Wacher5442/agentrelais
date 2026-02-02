import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/transfert_entity.dart';
import '../repositories/transfert_repository.dart';

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
    return await repo.submitTransfert(
      transfert: params.transfert,
      forceUssd: params.forceUssd,
    );
  }
}
