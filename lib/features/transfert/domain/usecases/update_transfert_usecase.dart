import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/transfert_entity.dart';
import '../repositories/transfert_repository.dart';

class UpdateTransfertRemote {
  final TransfertRepository repository;

  UpdateTransfertRemote(this.repository);

  Future<Either<Failure, TransfertEntity>> call(TransfertEntity transfert) {
    return repository.updateRemoteTransfert(transfert);
  }
}

class UpdateTransfertStatus {
  final TransfertRepository repository;

  UpdateTransfertStatus(this.repository);

  Future<Either<Failure, TransfertEntity>> call(
    String numeroFiche,
    String codeCampaign,
    String status,
  ) {
    return repository.updateTransfertStatus(numeroFiche, codeCampaign, status);
  }
}
