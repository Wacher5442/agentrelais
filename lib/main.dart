import 'package:agent_relais/features/auth/presentation/bloc/login_bloc.dart';
import 'package:agent_relais/features/reference_data/data/datasources/reference_local_datasource.dart';
import 'package:agent_relais/features/reference_data/data/datasources/reference_remote_datasource.dart';
import 'package:agent_relais/features/reference_data/presentation/bloc/sync_bloc.dart';
import 'package:agent_relais/features/reference_data/presentation/pages/sync_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agent_relais/core/db/db_helper.dart';
import 'package:agent_relais/core/services/background_sync_service.dart';
import 'package:agent_relais/core/services/sync_service.dart';
import 'package:agent_relais/core/utils/ussd_transport.dart';
import 'package:agent_relais/features/transfert/data/datasources/local/transfert_local_datasource.dart';
import 'package:agent_relais/features/transfert/presentation/bloc/transfert_submission_bloc.dart';
import 'package:agent_relais/features/transfert/presentation/pages/confirmation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'core/constants/route_constants.dart';
import 'core/network/dio_client.dart';
import 'core/network/network_info_impl.dart';
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
import 'package:agent_relais/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:agent_relais/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:agent_relais/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:agent_relais/features/auth/domain/usecases/login_usecase.dart';
import 'package:agent_relais/features/auth/domain/usecases/logout_usecase.dart';
import 'package:agent_relais/features/auth/domain/usecases/check_auth_usecase.dart';

import 'features/auth/domain/usecases/change_password_usecase.dart';
import 'features/auth/presentation/bloc/change_password_bloc.dart';
import 'features/auth/presentation/pages/change_password_page.dart';
import 'features/transfert/presentation/pages/loading_list_page.dart';
import 'features/transfert/presentation/pages/loading_detail_page.dart';
import 'features/transfert/presentation/pages/unloading_list_page.dart';
import 'features/transfert/presentation/pages/unloading_detail_page.dart';
import 'features/transfert/domain/entities/transfert_entity.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 0. Environment Init
  await dotenv.load(fileName: ".env");

  // 0. Background Sync Init
  await BackgroundSyncService.initialize();
  await BackgroundSyncService.registerPeriodicTask();
  // 1. Services Core & Datasources Early Set
  final dbHelper = DbHelper.instance;
  final authLocalDs = AuthLocalDataSourceImpl(
    const FlutterSecureStorage(),
    dbHelper,
  );

  final dioClient = DioClient(
    baseUrl:
        dotenv.env['BASE_URL_AUTH'] ??
        'https://maracko-backend.dev.go.incubtek.com/auth/',
    accessTokenGetter: authLocalDs.getAccessToken,
  );

  final networkInfo = NetworkInfoImpl(InternetConnection());
  final ussdTransport = MockUssdTransport();

  // 3. Datasources (continued)
  final transfertRemoteDs = TransfertRemoteDataSource(dioClient);
  final transfertLocalDs = TransfertLocalDataSourceImpl(dbHelper);
  var authRemoteDs = AuthRemoteDataSourceImpl(dioClient);

  // Reference Data Logic
  final refRemoteDs = ReferenceRemoteDataSource(dioClient);
  final refLocalDs = ReferenceLocalDataSource(dbHelper);

  // 4. Repository
  final transfertRepo = TransfertRepositoryImpl(
    localDataSource: transfertLocalDs,
    remoteDataSource: transfertRemoteDs,
    ussdTransport: ussdTransport,
    networkInfo: networkInfo,
    //serverStatusChecker: serverStatusChecker,
  );
  final authRepo = AuthRepositoryImpl(
    remoteDataSource: authRemoteDs,
    localDataSource: authLocalDs,
    networkInfo: networkInfo,
  );

  // 5. Sync Service (Foreground)
  final syncService = SyncService(
    networkInfo: networkInfo,
    transfertRepository: transfertRepo,
  );
  syncService.initialize();

  // 6. Blocs
  final syncBloc = SyncBloc(
    remoteDataSource: refRemoteDs,
    localDataSource: refLocalDs,
    authLocalDataSource: authLocalDs,
    networkInfo: networkInfo,
  );

  // 6. UseCases
  final submitUseCase = SubmitTransfertUseCase(repo: transfertRepo);
  final syncUseCase = SyncPendingTransferts(transfertRepo);
  final getTransfertsUseCase = GetTransfertsUseCase(transfertRepo);
  final loginUseCase = LoginUseCase(authRepo);
  final logoutUseCase = LogoutUseCase(authRepo);
  final checkAuthUseCase = CheckAuthUseCase(authRepo);
  final changePasswordUseCase = ChangePasswordUseCase(authRepo);

  final transfertSubmissionBloc = TransfertSubmissionBloc(
    submitUseCase: submitUseCase,
    syncUseCase: syncUseCase,
    networkInfo: networkInfo,
  );

  final transfertListBloc = TransfertListBloc(
    getTransfertsUseCase: getTransfertsUseCase,
  );

  // ... (existing blocs)

  final loginBloc = LoginBloc(
    loginUseCase: loginUseCase,
    logoutUseCase: logoutUseCase,
    checkAuthUseCase: checkAuthUseCase,
  );

  final changePasswordBloc = ChangePasswordBloc(
    changePasswordUseCase: changePasswordUseCase,
  );

  runApp(
    MyApp(
      submissionBloc: transfertSubmissionBloc,
      listBloc: transfertListBloc,
      loginBloc: loginBloc,
      syncBloc: syncBloc,
      changePasswordBloc: changePasswordBloc,
    ),
  );
}

class MyApp extends StatelessWidget {
  final TransfertSubmissionBloc submissionBloc;
  final TransfertListBloc listBloc;
  final LoginBloc loginBloc;
  final SyncBloc syncBloc;
  final ChangePasswordBloc changePasswordBloc;

  const MyApp({
    Key? key,
    required this.submissionBloc,
    required this.listBloc,
    required this.loginBloc,
    required this.syncBloc,
    required this.changePasswordBloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: submissionBloc),
        BlocProvider.value(value: listBloc),
        BlocProvider.value(value: loginBloc),
        BlocProvider.value(value: syncBloc),
        BlocProvider.value(value: changePasswordBloc),
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
          RouteConstants.changePassword: (context) =>
              const ChangePasswordPage(),
          RouteConstants.sync: (context) => const SyncPage(),
          RouteConstants.loadingList: (context) => const LoadingListPage(),
          // RouteConstants.loadingDetail is navigated with arguments, so it might need onGenerateRoute or just pushNamed with arguments handling inside?
          // Actually standard routes map doesn't support arguments in constructor easily.
          // Usually we use onGenerateRoute or MaterialPageRoute builder.
          // But here I used Navigator.pushNamed(context, RouteConstants.loadingDetail, arguments: transfert)
          // So I need a wrapper widget that extracts arguments.
          RouteConstants.loadingDetail: (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments as TransfertEntity;
            return LoadingDetailPage(transfert: args);
          },
          RouteConstants.unloadingList: (context) => const UnloadingListPage(),
          RouteConstants.unloadingDetail: (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments as TransfertEntity;
            return UnloadingDetailPage(transfert: args);
          },
        },
      ),
    );
  }
}
