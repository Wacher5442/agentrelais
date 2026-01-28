import 'dart:developer';

import 'package:agent_relais/core/constants/ussd_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/receipt/data/datasources/local/receipt_local_datasource.dart';
import '../../features/receipt/data/datasources/remote/receipt_remote_datasource.dart';
import '../../features/receipt/data/repositories/receipt_repository_impl.dart';
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
        final authLocalDs = AuthLocalDataSourceImpl(
          const FlutterSecureStorage(),
          dbHelper,
        );
        final dioClient = DioClient(
          baseUrl: 'https://maracko-backend.dev.go.incubtek.com',
          accessTokenGetter: authLocalDs.getAccessToken,
        ); // Use env var in real app
        final networkInfo = NetworkInfoImpl(InternetConnection());
        final ussdTransport = MockUssdTransport();

        final transfertRemoteDs = TransfertRemoteDataSource(dioClient);
        final transfertLocalDs = TransfertLocalDataSourceImpl(dbHelper);

        final receiptRemoteDs = ReceiptRemoteDataSource(dioClient);
        final receiptLocalDs = ReceiptLocalDataSource(dbHelper);

        final transfertRepo = TransfertRepositoryImpl(
          localDataSource: transfertLocalDs,
          remoteDataSource: transfertRemoteDs,
          ussdTransport: ussdTransport,
          networkInfo: networkInfo,
        );

        final receiptRepo = ReceiptRepositoryImpl(
          dbHelper: dbHelper,
          localDataSource: receiptLocalDs,
          remoteDataSource: receiptRemoteDs,
          networkInfo: networkInfo,
        );

        log("Starting background transferts sync...");
        final count = await transfertRepo.syncPendingHttpTransferts();
        log("Background transferts sync completed: $count items synced.");

        log("Starting background receipts sync...");
        final count2 = await receiptRepo.syncPendingReceipts();
        log("Background receipts sync completed: $count2 items synced.");

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
