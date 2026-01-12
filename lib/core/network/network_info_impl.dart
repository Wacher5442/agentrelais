import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'network_info.dart';

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnection internetConnection;

  NetworkInfoImpl(this.internetConnection);

  @override
  Future<bool> get isConnected => internetConnection.hasInternetAccess;

  @override
  Stream<bool> get onConnectivityChanged => internetConnection.onStatusChange
      .map((status) => status == InternetStatus.connected);
}
