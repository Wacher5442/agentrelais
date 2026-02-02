import 'package:fpdart/fpdart.dart';

import '../errors/failure.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Classe de paramètre pour les UseCases qui n'ont pas besoin d'arguments.
class NoParams {}
