import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/chargement_entity.dart';
import '../../domain/repositories/chargement_repository.dart';
import '../datasources/chargement_remote_datasource.dart';
import '../models/chargement_model.dart';

class ChargementRepositoryImpl implements ChargementRepository {
  final ChargementRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ChargementRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ChargementEntity>>> getChargements() async {
    if (!await networkInfo.isConnected) {
      return Left(ServerFailure("Pas de connexion internet"));
    }
    try {
      final data = await remoteDataSource.getChargements();
      final List<ChargementEntity> list = data
          .map((e) => ChargementModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(list);
    } catch (e) {
      return Left(ServerFailure("Erreur récupération: $e"));
    }
  }

  @override
  Future<Either<Failure, ChargementEntity>> updateChargement(
    ChargementEntity chargement,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(ServerFailure("Pas de connexion internet"));
    }
    try {
      final data = chargement.toFieldsJson();
      final result = await remoteDataSource.updateChargement(
        chargement.numeroFiche,
        chargement.campagne,
        data,
      );
      return Right(ChargementModel.fromJson(result));
    } catch (e) {
      return Left(ServerFailure("Erreur mise à jour: $e"));
    }
  }

  @override
  Future<Either<Failure, ChargementEntity>> updateStatus(
    String numeroFiche,
    String codeCampaign,
    String status,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(ServerFailure("Pas de connexion internet"));
    }
    try {
      final result = await remoteDataSource.updateStatus(
        numeroFiche,
        codeCampaign,
        status,
      );
      return Right(ChargementModel.fromJson(result));
    } catch (e) {
      return Left(ServerFailure("Erreur changement statut: $e"));
    }
  }
}
