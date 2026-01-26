import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:agent_relais/features/auth/domain/entities/user_entity.dart';

import '../../../../core/network/network_info.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../data/datasources/reference_local_datasource.dart';
import '../../data/datasources/reference_remote_datasource.dart';

part 'sync_event.dart';
part 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final ReferenceRemoteDataSource remoteDataSource;
  final ReferenceLocalDataSource localDataSource;
  final AuthLocalDataSource authLocalDataSource;
  final NetworkInfo networkInfo;

  SyncBloc({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.authLocalDataSource,
    required this.networkInfo,
  }) : super(SyncInitial()) {
    on<SyncStarted>(_onSyncStarted);
  }

  Future<void> _onSyncStarted(
    SyncStarted event,
    Emitter<SyncState> emit,
  ) async {
    if (!await networkInfo.isConnected) {
      emit(
        const SyncFailure(
          "Aucune connexion internet. Impossible de synchroniser les données pour le mode offline.",
        ),
      );
      return;
    }
    try {
      emit(const SyncInProgress(message: "Initialisation...", progress: 0.0));

      // 1. Sync Warehouses (10% du total)
      emit(
        const SyncInProgress(
          message: "Téléchargement des entrepôts...",
          progress: 0.1,
        ),
      );
      final warehouses = await remoteDataSource.getWarehouses();
      await localDataSource.saveBatch('warehouses', warehouses);

      // 2. Sync Territories (Basé sur la région active)
      await _syncTerritories(emit);

      emit(SyncSuccess());
    } catch (e) {
      emit(SyncFailure("Erreur de synchronisation: ${e.toString()}"));
    }
  }

  Future<void> _syncTerritories(Emitter<SyncState> emit) async {
    final activeRegionId = await authLocalDataSource.getActiveRegion();
    if (activeRegionId == null || activeRegionId.isEmpty) {
      throw Exception("Région active non définie.");
    }

    emit(
      SyncInProgress(message: "Récupération de votre région...", progress: 0.2),
    );

    // Récupérer les départements
    final departments = await remoteDataSource.getDepartments(activeRegionId);
    await localDataSource.saveBatch('departments', departments);

    if (departments.isEmpty) return;

    double step =
        0.7 / departments.length; // On alloue 70% de la barre aux enfants
    double currentProgress = 0.2;

    for (var dep in departments) {
      final depId = dep['id'].toString();
      emit(
        SyncInProgress(
          message: "Synchronisation de : ${dep['name'] ?? depId}...",
          progress: currentProgress,
        ),
      );

      // Sous-Préfectures
      final subPrefs = await remoteDataSource.getSubPrefectures(depId);
      await localDataSource.saveBatch('sub_prefectures', subPrefs);

      for (var sub in subPrefs) {
        final subId = sub['id'].toString();

        // Secteurs
        final sectors = await remoteDataSource.getSectors(subId);
        await localDataSource.saveBatch('sectors', sectors);

        for (var sector in sectors) {
          final sectorId = sector['id'].toString();

          // ZDs
          final zds = await remoteDataSource.getZds(sectorId);
          await localDataSource.saveBatch('zds', zds);

          for (var zd in zds) {
            final zdId = zd['id'].toString();

            // Localités
            final localites = await remoteDataSource.getLocalites(zdId);
            await localDataSource.saveBatch('localites', localites);

            for (var loc in localites) {
              final locId = loc['id'].toString();
              final quarters = await remoteDataSource.getQuarters(locId);
              await localDataSource.saveBatch('quarters', quarters);
            }
          }
        }
      }
      currentProgress += step;
    }
    emit(const SyncInProgress(message: "Finalisation...", progress: 1.0));
  }
}
