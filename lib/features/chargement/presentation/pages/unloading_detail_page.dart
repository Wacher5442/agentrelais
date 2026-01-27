import 'package:agent_relais/core/constants/colors.dart';
import 'package:agent_relais/features/chargement/presentation/bloc/unloading/unloading_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../../core/db/db_helper.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info_impl.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../data/datasources/chargement_remote_datasource.dart';
import '../../data/repositories/chargement_repository_impl.dart';
import '../../domain/entities/chargement_entity.dart';
import '../../domain/usecases/get_chargements.dart';
import '../../domain/usecases/update_chargement.dart';

class UnloadingDetailPage extends StatelessWidget {
  final ChargementEntity chargement;

  const UnloadingDetailPage({super.key, required this.chargement});

  @override
  Widget build(BuildContext context) {
    final dbHelper = DbHelper.instance;
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
    final remoteDataSource = ChargementRemoteDataSource(dioClient);
    final networkInfo = NetworkInfoImpl(InternetConnection.createInstance());

    final repository = ChargementRepositoryImpl(
      remoteDataSource: remoteDataSource,
      networkInfo: networkInfo,
    );

    return BlocProvider(
      create: (context) => UnloadingBloc(
        getChargements: GetChargements(repository),
        updateChargement: UpdateChargement(repository),
        secureStorage: const FlutterSecureStorage(),
      ),
      child: _UnloadingDetailView(chargement: chargement),
    );
  }
}

class _UnloadingDetailView extends StatefulWidget {
  final ChargementEntity chargement;
  const _UnloadingDetailView({required this.chargement});

  @override
  State<_UnloadingDetailView> createState() => _UnloadingDetailViewState();
}

class _UnloadingDetailViewState extends State<_UnloadingDetailView> {
  late ChargementEntity _currentChargement;
  final _korController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentChargement = widget.chargement;
    _korController.text = _currentChargement.destKor ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détail Déchargement ${_currentChargement.numeroFiche}'),
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
            final updated = List<ChargementEntity>.from(state.chargements)
                .firstWhere(
                  (element) =>
                      element.numeroFiche == _currentChargement.numeroFiche,
                  orElse: () => _currentChargement,
                );
            setState(() {
              _currentChargement = updated;
              _korController.text = _currentChargement.destKor ?? '';
            });
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoSection(),
              const SizedBox(height: 10),
              // Show Full Details as requested
              _buildDetailsSection(),
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
                      _currentChargement,
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
            Text(
              "Fiche: ${_currentChargement.numeroFiche}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("Magasin Dest: ${_currentChargement.destNomMagasin ?? '-'}"),
            Text("KOR Actuel: ${_currentChargement.destKor ?? '-'}"),
            Text(
              "Poids Net Arrivée: ${_currentChargement.destPoidsNet ?? '-'}",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Détails Complets",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text(
              "Départ: ${_currentChargement.village} -> ${_currentChargement.destinationVille}",
            ),
            Text("Transporteur: ${_currentChargement.nomTransporteur}"),
            Text("Chauffeur: ${_currentChargement.nomChauffeur}"),
            Text(
              "Camion: ${_currentChargement.marqueCamion} (${_currentChargement.immatriculation})",
            ),
            const Divider(),
            Text(
              "Date Déch: ${_currentChargement.destDateDechargement ?? '-'}",
            ),
            Text("Heure: ${_currentChargement.destHeure ?? '-'}"),
            Text(
              "Exportateur: ${_currentChargement.destNomExportateur ?? '-'}",
            ),
            Text(
              "Port/Usine: ${_currentChargement.destPortUsineDechargement ?? '-'}",
            ),
            Text("Pont Bascule: ${_currentChargement.destPontBascule ?? '-'}"),
            Text(
              "Sacs Déch: ${_currentChargement.destNombreSacsDecharges ?? '-'}",
            ),
            Text("Taux Hum: ${_currentChargement.destTauxHumidite ?? '-'}"),

            if (_currentChargement.image != null) ...[
              Image.network(
                "https://s3.dev.go.incubtek.com/proof/${_currentChargement.image}",
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
