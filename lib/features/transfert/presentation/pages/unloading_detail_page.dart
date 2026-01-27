import 'package:agent_relais/core/constants/colors.dart';
import 'package:agent_relais/features/transfert/presentation/bloc/unloading/unloading_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../../core/db/db_helper.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info_impl.dart';
import '../../../../core/utils/ussd_transport.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../data/datasources/local/transfert_local_datasource.dart';
import '../../data/datasources/remote/transfert_remote_datasource.dart';
import '../../data/repositories/transfert_repository_impl.dart';
import '../../domain/entities/transfert_entity.dart';
import '../../domain/usecases/get_remote_transferts.dart';
import '../../domain/usecases/update_transfert_usecase.dart';

class UnloadingDetailPage extends StatelessWidget {
  final TransfertEntity transfert;

  const UnloadingDetailPage({super.key, required this.transfert});

  @override
  Widget build(BuildContext context) {
    final dbHelper = DbHelper.instance;
    final localDataSource = TransfertLocalDataSourceImpl(dbHelper);
    final networkInfo = NetworkInfoImpl(InternetConnection.createInstance());
    final ussdTransport = MockUssdTransport();
    final authLocalDs = AuthLocalDataSourceImpl(
      const FlutterSecureStorage(),
      dbHelper,
    );
    final dioClient = DioClient(
      baseUrl:
          dotenv.env['BASE_URL_TRANSFERT'] ??
          'https://maracko-backend.dev.go.incubtek.com/commodities',
      accessTokenGetter: authLocalDs.getAccessToken,
    );
    final remoteDataSource = TransfertRemoteDataSource(dioClient);

    final repository = TransfertRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
      networkInfo: networkInfo,
      ussdTransport: ussdTransport,
    );

    return BlocProvider(
      create: (context) => UnloadingBloc(
        getRemoteTransferts: GetRemoteTransferts(repository),
        updateRemote: UpdateTransfertRemote(
          repository,
        ), // Required for KOR update
        secureStorage: const FlutterSecureStorage(),
      ),
      child: _UnloadingDetailView(transfert: transfert),
    );
  }
}

class _UnloadingDetailView extends StatefulWidget {
  final TransfertEntity transfert;
  const _UnloadingDetailView({required this.transfert});

  @override
  State<_UnloadingDetailView> createState() => _UnloadingDetailViewState();
}

class _UnloadingDetailViewState extends State<_UnloadingDetailView> {
  late TransfertEntity _currentTransfert;
  final _korController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentTransfert = widget.transfert;
    _korController.text = _currentTransfert.destKor ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détail Déchargement ${_currentTransfert.numeroFiche}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: BlocListener<UnloadingBloc, UnloadingState>(
        listener: (context, state) {
          if (state is UnloadingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is UnloadingLoaded) {
            final updated = state.transferts.firstWhere(
              (element) => element.numeroFiche == _currentTransfert.numeroFiche,
              orElse: () => _currentTransfert,
            );
            setState(() {
              _currentTransfert = updated;
              _korController.text = _currentTransfert.destKor ?? '';
            });
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoSection(),
              const SizedBox(height: 20),
              const Text(
                'Modification KOR',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _korController,
                decoration: const InputDecoration(
                  labelText: 'KOR (Modification unique)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.read<UnloadingBloc>().add(
                    UpdateUnloadingKOREvent(
                      _currentTransfert,
                      _korController.text,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Enregistrer KOR',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Fiche: ${_currentTransfert.numeroFiche}"),
            Text("Magasin: ${_currentTransfert.destNomMagasin}"),
            Text("Poids Net: ${_currentTransfert.destPoidsNet}"),
            Text("KOR Actuel: ${_currentTransfert.destKor}"),
          ],
        ),
      ),
    );
  }
}
