import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/models/recu_model.dart';
import '../../../../../core/utils/usecase.dart';
import '../entities/home_stats.dart';
import '../repositories/i_home_repository.dart';

/// Usecase combiné pour charger toutes les données de la page d'accueil
class GetHomeDataUseCase implements UseCase<HomeData, HomeDataParams> {
  final IHomeRepository repository;

  GetHomeDataUseCase(this.repository);

  @override
  Future<Either<Failure, HomeData>> call(HomeDataParams params) async {
    // Appelle les deux méthodes du repo en parallèle
    final statsResult = await repository.getStats();
    final receiptsResult = await repository.getReceipts(
      search: params.search,
      filter: params.filter,
    );

    // Combine les résultats
    return statsResult.fold(
      (failure) => Left(failure),
      (stats) => receiptsResult.fold(
        (failure) => Left(failure),
        (receipts) => Right(HomeData(stats: stats, receipts: receipts)),
      ),
    );
  }
}

/// Wrapper pour les données de la page d'accueil
class HomeData {
  final HomeStats stats;
  final List<Recu> receipts;
  HomeData({required this.stats, required this.receipts});
}

/// Paramètres pour le Usecase
class HomeDataParams {
  final String? search;
  final String? filter;
  HomeDataParams({this.search, this.filter});
}
