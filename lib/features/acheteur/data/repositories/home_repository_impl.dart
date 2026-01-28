import 'package:agent_relais/core/errors/failure.dart';
import 'package:agent_relais/core/models/recu_model.dart';
import 'package:agent_relais/features/acheteur/domain/entities/home_stats.dart';
import 'package:agent_relais/features/acheteur/domain/repositories/i_home_repository.dart';
import 'package:fpdart/fpdart.dart';

import '../datasources/home_local_datasource.dart';

class HomeRepositoryImpl implements IHomeRepository {
  final IHomeLocalDataSource localDataSource;

  HomeRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, HomeStats>> getStats() async {
    try {
      final stats = await localDataSource.getStats();
      return Right(stats);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Recu>>> getReceipts({
    String? search,
    String? filter,
  }) async {
    try {
      final receipts = await localDataSource.getReceipts(
        search: search,
        filter: filter,
      );
      return Right(receipts);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
