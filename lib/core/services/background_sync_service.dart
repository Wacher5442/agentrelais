import 'dart:developer';

import 'package:agent_relais/core/constants/ussd_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/transfert/data/datasources/local/transfert_local_datasource.dart';
import '../../features/transfert/data/datasources/remote/transfert_remote_datasource.dart';
import '../../features/transfert/data/repositories/transfert_repository_impl.dart';
import '../db/db_helper.dart';
import '../network/dio_client.dart';
import '../network/network_info_impl.dart';
import '../utils/ussd_transport.dart';

const simplePeriodicTask = "simplePeriodicTask";
const syncTaskKey = "com.agent_relais.syncTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    log("WorkManager task started: $task");

    if (task == syncTaskKey) {
      try {
        // Re-initialize dependencies for background isolate
        final dbHelper = DbHelper.instance;
        final dioClient = DioClient(
          baseUrl:
              dotenv.env['BASE_URL_AUTH'] ??
              'https://maracko-backend.dev.go.incubtek.com/auth/',
        ); // Use env var in real app
        final networkInfo = NetworkInfoImpl(InternetConnection());
        final ussdTransport =
            MockUssdTransport(); // Not used for HTTP sync but required by Repo

        final transfertRemoteDs = TransfertRemoteDataSource(dioClient);
        final transfertLocalDs = TransfertLocalDataSourceImpl(dbHelper);

        final transfertRepo = TransfertRepositoryImpl(
          localDataSource: transfertLocalDs,
          remoteDataSource: transfertRemoteDs,
          ussdTransport: ussdTransport,
          networkInfo: networkInfo,
        );

        log("Starting background sync...");
        final count = await transfertRepo.syncPendingHttpTransferts();
        log("Background sync completed: $count items synced.");

        return Future.value(true);
      } catch (e) {
        log("Background sync failed: $e");
        return Future.value(false);
      }
    }

    return Future.value(true);
  });
}

class BackgroundSyncService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // Set to false in production
    );
  }

  static Future<void> registerPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      simplePeriodicTask,
      syncTaskKey,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }
}
