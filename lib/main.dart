import 'package:agent_relais/core/constants/ussd_constants.dart';
import 'package:agent_relais/core/db/db_helper.dart';
import 'package:agent_relais/core/services/background_sync_service.dart';
import 'package:agent_relais/core/services/sync_service.dart';
import 'package:agent_relais/core/utils/ussd_transport.dart';
import 'package:agent_relais/features/transfert/data/datasources/local/transfert_local_datasource.dart';
import 'package:agent_relais/features/transfert/presentation/bloc/transfert_submission_bloc.dart';
import 'package:agent_relais/features/transfert/presentation/pages/confirmation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'core/constants/route_constants.dart';
import 'core/network/dio_client.dart';
import 'core/network/network_info_impl.dart';
import 'core/network/ping_remote_datasource.dart';
import 'core/network/server_status_checker.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/home/pages/home_page.dart';
import 'features/profil/profile_page.dart';
import 'features/transfert/data/datasources/remote/transfert_remote_datasource.dart';
import 'features/transfert/data/repositories/transfert_repository_impl.dart';
import 'features/transfert/domain/usecases/get_transferts_usecase.dart';
import 'features/transfert/domain/usecases/submit_transfert_usecase.dart';
import 'features/transfert/domain/usecases/sync_pending_transferts.dart';
import 'features/transfert/presentation/bloc/list/transfert_list_bloc.dart';
import 'features/transfert/presentation/pages/new_transfert_page.dart';
import 'features/transfert/presentation/pages/tranferts_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 0. Background Sync Init
  await BackgroundSyncService.initialize();
  await BackgroundSyncService.registerPeriodicTask();

  // 1. Services Core
  final dbHelper = DbHelper.instance;
  final dioClient = DioClient(baseUrl: BASE_URL);
  final networkInfo = NetworkInfoImpl(InternetConnection());
  final ussdTransport = MockUssdTransport();

  // 3. Datasources
  final transfertRemoteDs = TransfertRemoteDataSource(dioClient);
  final transfertLocalDs = TransfertLocalDataSourceImpl(dbHelper);

  // 4. Repository
  final transfertRepo = TransfertRepositoryImpl(
    localDataSource: transfertLocalDs,
    remoteDataSource: transfertRemoteDs,
    ussdTransport: ussdTransport,
    networkInfo: networkInfo,
    //serverStatusChecker: serverStatusChecker,
  );

  // 5. Sync Service (Foreground)
  final syncService = SyncService(
    networkInfo: networkInfo,
    transfertRepository: transfertRepo,
  );
  syncService.initialize();

  // 6. UseCases
  final submitUseCase = SubmitTransfertUseCase(repo: transfertRepo);
  final syncUseCase = SyncPendingTransferts(transfertRepo);
  final getTransfertsUseCase = GetTransfertsUseCase(transfertRepo);

  // 6. Blocs
  final transfertSubmissionBloc = TransfertSubmissionBloc(
    submitUseCase: submitUseCase,
    syncUseCase: syncUseCase,
    networkInfo: networkInfo,
  );

  final transfertListBloc = TransfertListBloc(
    getTransfertsUseCase: getTransfertsUseCase,
  );

  runApp(
    MyApp(submissionBloc: transfertSubmissionBloc, listBloc: transfertListBloc),
  );
}

class MyApp extends StatelessWidget {
  final TransfertSubmissionBloc submissionBloc;
  final TransfertListBloc listBloc;

  const MyApp({Key? key, required this.submissionBloc, required this.listBloc})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: submissionBloc),
        BlocProvider.value(value: listBloc),
      ],
      child: MaterialApp(
        title: 'Agent Relais',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: const Color(0xFF0E8446),
        ),
        initialRoute: RouteConstants.login,
        routes: {
          RouteConstants.login: (context) => LoginPage(),
          RouteConstants.home: (context) => HomePage(),
          RouteConstants.profil: (context) => ProfilePage(),
          RouteConstants.transfert: (context) => TranfertsPage(),
          RouteConstants.addTransfert: (context) => NewTransfertPage(),
          RouteConstants.confirmation: (context) => const ConfirmationPage(),
        },
      ),
    );
  }
}
