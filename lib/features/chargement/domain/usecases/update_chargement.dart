import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/chargement_entity.dart';
import '../repositories/chargement_repository.dart';

class UpdateChargement {
  final ChargementRepository repository;

  UpdateChargement(this.repository);

  Future<Either<Failure, ChargementEntity>> call(ChargementEntity chargement) {
    return repository.updateChargement(chargement);
  }
}

class UpdateChargementStatus {
  final ChargementRepository repository;

  UpdateChargementStatus(this.repository);

  Future<Either<Failure, ChargementEntity>> call(
    String numeroFiche,
    String codeCampaign,
    String status,
  ) {
    return repository.updateStatus(numeroFiche, codeCampaign, status);
  }
}
