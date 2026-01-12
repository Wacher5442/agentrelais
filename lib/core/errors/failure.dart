import 'package:equatable/equatable.dart';

/// Classe abstraite pour les échecs (erreurs) dans l'application.
/// L'utilisation d'Equatable permet des comparaisons faciles.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Échec lié à la base de données locale (SQFlite)
class DatabaseFailure extends Failure {
  const DatabaseFailure(String message) : super(message);
}

/// Échec lié au serveur distant (Dio, HTTP)
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

/// Échec générique pour d'autres cas
class GenericFailure extends Failure {
  const GenericFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}
