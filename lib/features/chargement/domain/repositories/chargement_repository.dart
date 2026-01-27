import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/chargement_entity.dart';

abstract class ChargementRepository {
  // Récupérer la liste des chargements/déchargements
  Future<Either<Failure, List<ChargementEntity>>> getChargements();

  // Mettre à jour un chargement (Destination info)
  Future<Either<Failure, ChargementEntity>> updateChargement(
    ChargementEntity chargement,
  );

  // Mettre à jour le statut
  Future<Either<Failure, ChargementEntity>> updateStatus(
    String numeroFiche,
    String codeCampaign,
    String status,
  );
}
