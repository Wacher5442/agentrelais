import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/chargement_entity.dart';
import '../repositories/chargement_repository.dart';

class GetChargements {
  final ChargementRepository repository;

  GetChargements(this.repository);

  Future<Either<Failure, List<ChargementEntity>>> call() {
    return repository.getChargements();
  }
}
