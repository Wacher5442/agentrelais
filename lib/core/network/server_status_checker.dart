import 'dart:developer';

import 'exceptions.dart';
import 'network_info.dart';
import 'ping_remote_datasource.dart';

class ServerStatusChecker {
  final NetworkInfo networkInfo;
  final PingRemoteDataSource pingRemoteDataSource;

  ServerStatusChecker({
    required this.networkInfo,
    required this.pingRemoteDataSource,
  });

  /// Vérifie internet + serveur
  Future<bool> isBackendAvailable() async {
    final hasInternet = await networkInfo.isConnected;
    log('hasInternet $hasInternet');

    if (!hasInternet) throw NoInternetException();

    final backendOk = await pingRemoteDataSource.pingServer();

    log('backendOk $backendOk');

    if (!backendOk) throw ServerNotReachableException();

    return true;
  }
}
