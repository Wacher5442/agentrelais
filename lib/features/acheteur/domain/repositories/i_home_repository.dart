import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart'; // Vous devriez avoir un fichier Failure générique
import '../../../../../core/models/recu_model.dart'; // Utilise VOTRE modèle de reçu
import '../entities/home_stats.dart';

abstract class IHomeRepository {
  /// Récupère les 3 compteurs pour les cartes de statut.
  Future<Either<Failure, HomeStats>> getStats();

  /// Récupère la liste filtrée et recherchée des reçus.
  Future<Either<Failure, List<Recu>>> getReceipts({
    String? search,
    String? filter,
  });
}
