import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/commodity_entity.dart';
import '../../domain/entities/campaign_entity.dart';
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

        // 1. On récupère les tokens et le user de base (avec permissions)
        final tokenData = response['token'];
        await localDataSource.cacheToken(
          tokenData['access_token'],
          tokenData['refresh_token'],
        );

        UserModel userWithRoles = UserModel.fromJson(response['userinfo']);

        // 2. Appel du profil pour récupérer les infos manquantes (metadata_)
        try {
          final profileData = await remoteDataSource.getProfile();

          // 3. FUSION : On garde les rôles de 'userWithRoles' mais on prend
          // le matricule et le lieu de travail de 'profileData'
          final finalUser = userWithRoles.copyWith(
            agentCode: profileData.agentCode,
            placeOfWork: profileData.placeOfWork,
            firstName: profileData.firstName, // si présent dans profil
            lastName: profileData.lastName, // si présent dans profil
          );

          await localDataSource.cacheUser(finalUser);
          return Right(finalUser);
        } catch (e) {
          // Si le profil échoue, on renvoie quand même l'utilisateur du login
          // pour ne pas bloquer l'accès, même s'il manque des infos.
          await localDataSource.cacheUser(userWithRoles);
          return Right(userWithRoles);
        }
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ServerFailure("Pas de connexion internet"));
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

  // --- Dynamic Commodity & Campaign Management ---

  @override
  Future<Either<Failure, List<CommodityEntity>>>
  fetchAndStoreCommodities() async {
    if (await networkInfo.isConnected) {
      try {
        final commodities = await remoteDataSource.getCommodities();
        await localDataSource.saveCommodities(commodities);
        return Right(commodities);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      // Return cached if offline
      try {
        final local = await localDataSource.getCommodities();
        return Right(local);
      } catch (e) {
        return Left(CacheFailure("Failed to load cached commodities"));
      }
    }
  }

  @override
  Future<Either<Failure, List<CampaignEntity>>>
  fetchAndStoreOpenCampaigns() async {
    if (await networkInfo.isConnected) {
      try {
        final campaigns = await remoteDataSource.getOpenCampaigns();
        await localDataSource.saveCampaigns(campaigns);
        return Right(campaigns);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      // Return cached if offline
      try {
        final local = await localDataSource.getCampaigns();
        return Right(local);
      } catch (e) {
        return Left(CacheFailure("Failed to load cached campaigns"));
      }
    }
  }

  @override
  Future<Either<Failure, String>> getActiveCommodityCode() async {
    try {
      // Logic: Preference > Default "ANACARDE"
      final selected = await localDataSource.getSelectedCommodity();
      return Right(selected ?? "ANACARDE");
    } catch (e) {
      return const Right("ANACARDE");
    }
  }

  @override
  Future<Either<Failure, CampaignEntity?>> getActiveCampaign() async {
    try {
      final commodityCodeResult = await getActiveCommodityCode();
      return await commodityCodeResult.fold((failure) async => Left(failure), (
        code,
      ) async {
        final campaign = await localDataSource.getActiveCampaignForCommodity(
          code,
        );
        return Right(campaign);
      });
    } catch (e) {
      return Left(CacheFailure("Failed to get active campaign: $e"));
    }
  }

  @override
  Future<Either<Failure, void>> setSelectedCommodity(
    String commodityCode,
  ) async {
    try {
      await localDataSource.saveSelectedCommodity(commodityCode);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure("Failed to save selected commodity"));
    }
  }
}
