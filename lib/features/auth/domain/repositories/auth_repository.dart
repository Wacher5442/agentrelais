import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String username, String password);
  Future<Either<Failure, User>> getProfile();
  Future<Either<Failure, void>> changePassword(
    String userId,
    String newPassword,
  );
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User?>> getCurrentUser();
  Future<void> saveActiveRegion(String region);
  Future<String?> getActiveRegion();
}
