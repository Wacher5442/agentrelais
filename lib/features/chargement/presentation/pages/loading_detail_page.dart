import 'package:agent_relais/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/db/db_helper.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info_impl.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../data/datasources/chargement_remote_datasource.dart';
import '../../data/repositories/chargement_repository_impl.dart';
import '../../domain/entities/chargement_entity.dart';
import '../../domain/usecases/get_chargements.dart';
import '../../domain/usecases/update_chargement.dart';
import '../bloc/loading/loading_bloc.dart';

class LoadingDetailPage extends StatelessWidget {
  final ChargementEntity chargement;

  const LoadingDetailPage({super.key, required this.chargement});

  @override
  Widget build(BuildContext context) {
    // DI Setup
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
      create: (context) => LoadingBloc(
        getChargements: GetChargements(repository),
        updateChargementStatus: UpdateChargementStatus(repository),
        updateChargement: UpdateChargement(repository),
      ),
      child: _LoadingDetailView(chargement: chargement),
    );
  }
}

class _LoadingDetailView extends StatefulWidget {
  final ChargementEntity chargement;

  const _LoadingDetailView({required this.chargement});

  @override
  State<_LoadingDetailView> createState() => _LoadingDetailViewState();
}

class _LoadingDetailViewState extends State<_LoadingDetailView> {
  late ChargementEntity _currentChargement;
  final _formKey = GlobalKey<FormState>();

  final _destDateController = TextEditingController();
  final _destHeureController = TextEditingController();
  final _destNomExportateurController = TextEditingController();
  final _destCodeExportateurController = TextEditingController();
  final _destPortUsineController = TextEditingController();
  final _destPontBasculeController = TextEditingController();
  final _destNomMagasinController = TextEditingController();
  final _destKorController = TextEditingController();
  final _destNbSacsDechargesController = TextEditingController();
  final _destNbSacsRemboursesController = TextEditingController();
  final _destTauxHumiditeController = TextEditingController();
  final _destPoidsBrutController = TextEditingController();
  final _destTareController = TextEditingController();
  final _destPoidsNetController = TextEditingController();
  final _destPrixKgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentChargement = widget.chargement;
    _initializeControllers();
  }

  void _initializeControllers() {
    _destDateController.text = _currentChargement.destDateDechargement ?? '';
    _destHeureController.text = _currentChargement.destHeure ?? '';
    _destNomExportateurController.text =
        _currentChargement.destNomExportateur ?? '';
    _destCodeExportateurController.text =
        _currentChargement.destCodeExportateur ?? '';
    _destPortUsineController.text =
        _currentChargement.destPortUsineDechargement ?? '';
    _destPontBasculeController.text = _currentChargement.destPontBascule ?? '';
    _destNomMagasinController.text = _currentChargement.destNomMagasin ?? '';
    _destKorController.text = _currentChargement.destKor ?? '';
    _destNbSacsDechargesController.text =
        _currentChargement.destNombreSacsDecharges?.toString() ?? '';
    _destNbSacsRemboursesController.text =
        _currentChargement.destNombreSacsRembourses?.toString() ?? '';
    _destTauxHumiditeController.text =
        _currentChargement.destTauxHumidite?.toString() ?? '';
    _destPoidsBrutController.text =
        _currentChargement.destPoidsBrut?.toString() ?? '';
    _destTareController.text = _currentChargement.destTare?.toString() ?? '';
    _destPoidsNetController.text =
        _currentChargement.destPoidsNet?.toString() ?? '';
    _destPrixKgController.text =
        _currentChargement.destPrixKg?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    bool isPending =
        ['PENDING', 'en_attente'].contains(_currentChargement.status) ||
        [
          'PENDING',
          'en_attente',
        ].contains(_currentChargement.status.toUpperCase());
    bool isOkForControl =
        [
          'OK_FOR_CONTROL',
          'ok_pour_controle',
        ].contains(_currentChargement.status) ||
        [
          'OK_FOR_CONTROL',
          'ok_pour_controle',
        ].contains(_currentChargement.status.toUpperCase());

    return Scaffold(
      appBar: AppBar(
        title: Text('Détail Chargement ${_currentChargement.numeroFiche}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: BlocListener<LoadingBloc, LoadingState>(
        listener: (context, state) {
          if (state is LoadingActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          }
          if (state is LoadingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is LoadingLoaded) {
            final updated = List<ChargementEntity>.from(state.chargements)
                .firstWhere(
                  (element) =>
                      element.numeroFiche == _currentChargement.numeroFiche,
                  orElse: () => _currentChargement,
                );
            setState(() {
              _currentChargement = updated;
            });
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInfoSection(),
                const SizedBox(height: 20),

                if (isPending)
                  ElevatedButton(
                    onPressed: () {
                      context.read<LoadingBloc>().add(
                        UpdateLoadingStatusEvent(
                          _currentChargement,
                          'OK_FOR_CONTROL',
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'OK pour contrôle',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                if (isOkForControl) ...[
                  const Text(
                    'Informations Destination',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    "Date Déchargement",
                    _destDateController,
                    isDate: true,
                  ),
                  _buildTextField("Heure", _destHeureController),
                  _buildTextField(
                    "Nom Exportateur",
                    _destNomExportateurController,
                  ),
                  _buildTextField(
                    "Code Exportateur",
                    _destCodeExportateurController,
                  ),
                  _buildTextField("Port/Usine", _destPortUsineController),
                  _buildTextField("Pont Bascule", _destPontBasculeController),
                  _buildTextField("Nom Magasin", _destNomMagasinController),
                  _buildTextField("KOR", _destKorController),
                  _buildTextField(
                    "Nb Sacs Déchargés",
                    _destNbSacsDechargesController,
                    isNumber: true,
                  ),
                  _buildTextField(
                    "Nb Sacs Remboursés",
                    _destNbSacsRemboursesController,
                    isNumber: true,
                  ),
                  _buildTextField(
                    "Taux Humidité",
                    _destTauxHumiditeController,
                    isNumber: true,
                  ),
                  _buildTextField(
                    "Poids Brut",
                    _destPoidsBrutController,
                    isNumber: true,
                  ),
                  _buildTextField("Tare", _destTareController, isNumber: true),
                  _buildTextField(
                    "Poids Net",
                    _destPoidsNetController,
                    isNumber: true,
                  ),
                  _buildTextField(
                    "Prix Kg",
                    _destPrixKgController,
                    isNumber: true,
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitDestinationDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Valider Déchargement',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
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
            const SizedBox(height: 5),
            Text("Statut: ${_currentChargement.status}"),
            Text(
              "Transporteur: ${_currentChargement.nomTransporteur ?? 'N/A'}",
            ),
            Text("Chauffeur: ${_currentChargement.nomChauffeur ?? 'N/A'}"),
            const Divider(),
            Text(
              "Départ: ${_currentChargement.village ?? 'N/A'} (${_currentChargement.departement ?? 'N/A'})",
            ),
            Text(
              "Magasin Provenance: ${_currentChargement.nomMagasin ?? 'N/A'}",
            ),
            Text("Sacs départ: ${_currentChargement.sacs ?? '0'}"),
            Text("Poids départ: ${_currentChargement.poids ?? '0'}"),

            // afficher l'image de la fiche
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool isDate = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        onTap: () async {
          if (isDate) {
            FocusScope.of(context).requestFocus(FocusNode());
            DateTime? picked = await showDatePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              initialDate: DateTime.now(),
            );
            if (picked != null) {
              controller.text = DateFormat('yyyy-MM-dd').format(picked);
            }
          }
        },
      ),
    );
  }

  void _submitDestinationDetails() {
    final updatedEntity = _currentChargement.copyWith(
      destDateDechargement: _destDateController.text,
      destHeure: _destHeureController.text,
      destNomExportateur: _destNomExportateurController.text,
      destCodeExportateur: _destCodeExportateurController.text,
      destPortUsineDechargement: _destPortUsineController.text,
      destPontBascule: _destPontBasculeController.text,
      destNomMagasin: _destNomMagasinController.text,
      destKor: _destKorController.text,
      destNombreSacsDecharges: num.tryParse(
        _destNbSacsDechargesController.text,
      ),
      destNombreSacsRembourses: num.tryParse(
        _destNbSacsRemboursesController.text,
      ),
      destTauxHumidite: num.tryParse(_destTauxHumiditeController.text),
      destPoidsBrut: num.tryParse(_destPoidsBrutController.text),
      destTare: num.tryParse(_destTareController.text),
      destPoidsNet: num.tryParse(_destPoidsNetController.text),
      destPrixKg: num.tryParse(_destPrixKgController.text),
    );

    context.read<LoadingBloc>().add(UpdateLoadingDetailsEvent(updatedEntity));
    context.read<LoadingBloc>().add(
      UpdateLoadingStatusEvent(updatedEntity, 'UNLOADED'),
    );
  }
}
