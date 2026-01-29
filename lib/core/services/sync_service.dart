import 'dart:async';
import 'dart:developer';

import '../network/network_info.dart';
import '../../features/transfert/domain/repositories/transfert_repository.dart';

import '../bloc/global_sync/global_sync_bloc.dart';
import '../bloc/global_sync/global_sync_event.dart';

class SyncService {
  final NetworkInfo networkInfo;
  final TransfertRepository transfertRepository;
  final GlobalSyncBloc globalSyncBloc;
  StreamSubscription<bool>? _subscription;

  SyncService({
    required this.networkInfo,
    required this.transfertRepository,
    required this.globalSyncBloc,
  });

  void initialize() {
    _subscription = networkInfo.onConnectivityChanged.listen((isConnected) {
      if (isConnected) {
        log("Connexion rétablie. Lancement de la synchronisation...");
        syncPendingData();
      }
    });
  }

  Future<void> syncPendingData() async {
    try {
      globalSyncBloc.add(SyncStarted());
      final count = await transfertRepository.syncPendingHttpTransferts();
      if (count > 0) {
        log("Synchronisation terminée : $count transferts envoyés.");
      } else {
        log("Aucun transfert en attente.");
      }
    } catch (e) {
      log("Erreur lors de la synchronisation : $e");
    } finally {
      globalSyncBloc.add(SyncFinished());
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
