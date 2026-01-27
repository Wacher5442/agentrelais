import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/transfert_entity.dart';
import '../repositories/transfert_repository.dart';

class GetRemoteTransferts {
  final TransfertRepository repository;

  GetRemoteTransferts(this.repository);

  Future<Either<Failure, List<TransfertEntity>>> call() {
    return repository.getRemoteTransferts();
  }
}
