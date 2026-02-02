import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/models/recu_model.dart';
import '../entities/home_stats.dart';

abstract class IHomeRepository {
  Future<Either<Failure, HomeStats>> getStats();

  Future<Either<Failure, List<Recu>>> getReceipts({
    String? search,
    String? filter,
  });
}
