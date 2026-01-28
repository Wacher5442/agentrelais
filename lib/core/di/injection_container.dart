import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/transfert/data/datasources/local/transfert_local_datasource.dart';
import '../../features/transfert/data/datasources/remote/transfert_remote_datasource.dart';
import '../../features/transfert/data/repositories/transfert_repository_impl.dart';
import '../db/db_helper.dart';
import '../network/dio_client.dart';
import '../network/network_info_impl.dart';
import '../utils/ussd_transport.dart';

class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  // On expose uniquement ce qui est nécessaire pour l'extérieur
  late TransfertRepositoryImpl transfertRepository;
  late AuthLocalDataSourceImpl authLocalDataSource;

  Future<void> init() async {
    // 1. Initialisations de base (Vital pour l'isolate de fond)
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");

    // 2. Core
    final dbHelper = DbHelper.instance;
    authLocalDataSource = AuthLocalDataSourceImpl(
      const FlutterSecureStorage(),
      dbHelper,
    );

    final dioClient = DioClient(
      baseUrl:
          dotenv.env['BASE_URL'] ??
          'https://maracko-backend.dev.go.incubtek.com',
      accessTokenGetter: authLocalDataSource.getAccessToken,
    );

    final networkInfo = NetworkInfoImpl(InternetConnection());
    final ussdTransport = MockUssdTransport();

    // 3. DataSources
    final transfertRemoteDs = TransfertRemoteDataSource(dioClient);
    final transfertLocalDs = TransfertLocalDataSourceImpl(dbHelper);

    // 4. Repositories
    transfertRepository = TransfertRepositoryImpl(
      localDataSource: transfertLocalDs,
      remoteDataSource: transfertRemoteDs,
      ussdTransport: ussdTransport,
      networkInfo: networkInfo,
    );
  }
}
