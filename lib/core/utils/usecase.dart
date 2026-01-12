import 'package:fpdart/fpdart.dart';

import '../errors/failure.dart'; // Assurez-vous que ce chemin est correct

/// Classe de base abstraite pour les UseCases.
/// [Type] est le type de retour (succès).
/// [Params] est le type des paramètres.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Classe de paramètre pour les UseCases qui n'ont pas besoin d'arguments.
class NoParams {}
