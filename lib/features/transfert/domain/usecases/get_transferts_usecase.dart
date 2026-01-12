import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/transfert_entity.dart';
import '../repositories/transfert_repository.dart';

class GetTransfertsUseCase implements UseCase<List<TransfertEntity>, NoParams> {
  final TransfertRepository repository;

  GetTransfertsUseCase(this.repository);

  @override
  Future<Either<Failure, List<TransfertEntity>>> call(NoParams params) async {
    return await repository.getTransferts();
  }
}
