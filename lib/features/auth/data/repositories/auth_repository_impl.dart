import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> login(String username, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.login(username, password);

        // Parse Token
        final tokenData = response['token'];
        final accessToken = tokenData['access_token'];
        final refreshToken = tokenData['refresh_token'];

        // Parse User
        final userModel = UserModel.fromJson(response['userinfo']);

        // Cache
        await localDataSource.cacheToken(accessToken, refreshToken);
        await localDataSource.cacheUser(userModel);

        return Right(userModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(ServerFailure("No internet connection"));
    }
  }

  @override
  Future<Either<Failure, User>> getProfile() async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.getProfile();
        await localDataSource.cacheUser(userModel);
        return Right(userModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      // Return cached user if offline
      final localUser = await localDataSource.getLastUser();
      if (localUser != null) {
        return Right(localUser);
      }
      return Left(ServerFailure("No internet and no cached data"));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
    String userId,
    String newPassword,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.changePassword(userId, newPassword);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ServerFailure("No internet connection"));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure("Logout Failed"));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getLastUser();
      return Right(user);
    } catch (e) {
      return Left(CacheFailure("Get Current User Failed"));
    }
  }

  @override
  Future<void> saveActiveRegion(String region) async {
    await localDataSource.saveActiveRegion(region);
  }

  @override
  Future<String?> getActiveRegion() async {
    return await localDataSource.getActiveRegion();
  }
}
