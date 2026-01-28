import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/db/db_helper.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info_impl.dart';
import '../../../../core/widgets/full_image_widget.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../data/datasources/chargement_remote_datasource.dart';
import '../../data/models/receipt_model.dart';
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
      child: _LoadingDetailView(
        chargement: chargement,
        remoteDataSource: remoteDataSource,
      ),
    );
  }
}

class _LoadingDetailView extends StatefulWidget {
  final ChargementEntity chargement;
  final ChargementRemoteDataSource remoteDataSource;

  const _LoadingDetailView({
    required this.chargement,
    required this.remoteDataSource,
  });

  @override
  State<_LoadingDetailView> createState() => _LoadingDetailViewState();
}

class _LoadingDetailViewState extends State<_LoadingDetailView> {
  late ChargementEntity _currentChargement;
  List<ReceiptModel> _receipts = [];
  bool _isLoadingReceipts = false;

  @override
  void initState() {
    super.initState();
    _currentChargement = widget.chargement;
    _fetchReceipts();
  }

  Future<void> _fetchReceipts() async {
    if (_currentChargement.bundleId == null) return;

    setState(() => _isLoadingReceipts = true);

    try {
      final receiptsData = await widget.remoteDataSource.getReceipts(
        _currentChargement.bundleId.toString(),
      );
      setState(() {
        _receipts = receiptsData
            .map((data) => ReceiptModel.fromJson(data))
            .toList();
        _isLoadingReceipts = false;
      });
    } catch (e) {
      setState(() => _isLoadingReceipts = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des reçus: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool get _isPending {
    return [
      'pending',
      'en_attente',
    ].contains(_currentChargement.status.toLowerCase());
  }

  bool get _isOkForControl {
    return [
      'ok_for_control',
      'ok_pour_controle',
    ].contains(_currentChargement.status.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoadingBloc, LoadingState>(
      listener: (context, state) {
        if (state is LoadingActionSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          Navigator.pop(context);
        }
        if (state is LoadingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
        if (state is LoadingStatusSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
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
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(color: Colors.black),
          centerTitle: false,
          title: Text(
            'Détails du chargement',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 16),
              _buildGeneralInfo(),
              const SizedBox(height: 16),
              _buildLocationInfo(),
              const SizedBox(height: 16),
              _buildDestinationInfo(),
              const SizedBox(height: 16),
              _buildTransportInfo(),
              const SizedBox(height: 16),
              _buildLoadingDetails(),
              const SizedBox(height: 16),
              if (_currentChargement.destDateDechargement != null)
                _buildUnloadingInfo(),
              if (_currentChargement.destDateDechargement != null)
                const SizedBox(height: 16),
              if (_currentChargement.image != null) _buildFicheImage(),
              if (_currentChargement.image != null) const SizedBox(height: 16),
              if (_receipts.isNotEmpty || _isLoadingReceipts)
                _buildReceiptsSection(),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
        floatingActionButton: _buildActionButton(context),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC2C3C4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fiche #${_currentChargement.numeroFiche}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_currentChargement.typeTransfert != null)
                  Text(
                    'Type : ${_currentChargement.typeTransfert}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _getStatusColor(_currentChargement.status),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              _getStatusLabel(_currentChargement.status),
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildActionButton(BuildContext context) {
    if (_isPending) {
      return FloatingActionButton.extended(
        onPressed: () => _showOkForControlDialog(context),
        backgroundColor: primaryColor,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        label: Text(
          'OK pour contrôle',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else if (_isOkForControl) {
      return FloatingActionButton.extended(
        onPressed: () => _showUnloadingFormDialog(context),
        backgroundColor: primaryColor,
        icon: const Icon(Icons.edit_outlined, color: Colors.white),
        label: Text(
          'Saisir déchargement',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return null;
  }

  void _showOkForControlDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Confirmation',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Marquer cette fiche comme "OK pour contrôle" ?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Annuler', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<LoadingBloc>().add(
                UpdateLoadingStatusEvent(_currentChargement, 'OK_FOR_CONTROL'),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: Text(
              'Confirmer',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showUnloadingFormDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final controllers = {
      'date': TextEditingController(
        text: _currentChargement.destDateDechargement ?? '',
      ),
      'heure': TextEditingController(text: _currentChargement.destHeure ?? ''),
      'exportateur': TextEditingController(
        text: _currentChargement.destNomExportateur ?? '',
      ),
      'codeExportateur': TextEditingController(
        text: _currentChargement.destCodeExportateur ?? '',
      ),
      'portUsine': TextEditingController(
        text: _currentChargement.destPortUsineDechargement ?? '',
      ),
      'pontBascule': TextEditingController(
        text: _currentChargement.destPontBascule ?? '',
      ),
      'magasin': TextEditingController(
        text: _currentChargement.destNomMagasin ?? '',
      ),
      'kor': TextEditingController(text: _currentChargement.destKor ?? ''),
      'sacsDecharges': TextEditingController(
        text: _currentChargement.destNombreSacsDecharges?.toString() ?? '',
      ),
      'sacsRembourses': TextEditingController(
        text: _currentChargement.destNombreSacsRembourses?.toString() ?? '',
      ),
      'tauxHumidite': TextEditingController(
        text: _currentChargement.destTauxHumidite?.toString() ?? '',
      ),
      'poidsBrut': TextEditingController(
        text: _currentChargement.destPoidsBrut?.toString() ?? '',
      ),
      'tare': TextEditingController(
        text: _currentChargement.destTare?.toString() ?? '',
      ),
      'poidsNet': TextEditingController(
        text: _currentChargement.destPoidsNet?.toString() ?? '',
      ),
      'prixKg': TextEditingController(
        text: _currentChargement.destPrixKg?.toString() ?? '',
      ),
    };

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Informations de déchargement',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildDialogTextField(
                          'Date déchargement',
                          controllers['date']!,
                          isDate: true,
                          isRequired: true,
                        ),
                        _buildDialogTextField('Heure', controllers['heure']!),
                        _buildDialogTextField(
                          'Nom exportateur',
                          controllers['exportateur']!,
                          isRequired: true,
                        ),
                        _buildDialogTextField(
                          'Code exportateur',
                          controllers['codeExportateur']!,
                          isRequired: true,
                        ),
                        _buildDialogTextField(
                          'Port/Usine',
                          controllers['portUsine']!,
                          isRequired: true,
                        ),
                        _buildDialogTextField(
                          'Pont bascule',
                          controllers['pontBascule']!,
                          isRequired: true,
                        ),
                        _buildDialogTextField(
                          'Nom magasin',
                          controllers['magasin']!,
                          isRequired: true,
                        ),
                        _buildDialogTextField(
                          'KOR',
                          controllers['kor']!,
                          isRequired: true,
                        ),
                        _buildDialogTextField(
                          'Sacs déchargés',
                          controllers['sacsDecharges']!,
                          isNumber: true,
                          isRequired: true,
                        ),
                        _buildDialogTextField(
                          'Sacs remboursés',
                          controllers['sacsRembourses']!,
                          isNumber: true,
                        ),
                        _buildDialogTextField(
                          'Taux humidité (%)',
                          controllers['tauxHumidite']!,
                          isNumber: true,
                        ),
                        _buildDialogTextField(
                          'Poids brut (T)',
                          controllers['poidsBrut']!,
                          isNumber: true,
                          isRequired: true,
                        ),
                        _buildDialogTextField(
                          'Tare (Kg)',
                          controllers['tare']!,
                          isNumber: true,
                        ),
                        _buildDialogTextField(
                          'Poids net (T)',
                          controllers['poidsNet']!,
                          isNumber: true,
                          isRequired: true,
                        ),
                        _buildDialogTextField(
                          'Prix/Kg (F)',
                          controllers['prixKg']!,
                          isNumber: true,
                          isRequired: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text('Annuler', style: GoogleFonts.poppins()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Validate form before submission
                          if (!formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Veuillez remplir tous les champs obligatoires avec des valeurs valides',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final updatedEntity = _currentChargement.copyWith(
                            destDateDechargement: controllers['date']!.text,
                            destHeure: controllers['heure']!.text.isNotEmpty
                                ? controllers['heure']!.text
                                : TimeOfDay.now().format(context),
                            destNomExportateur:
                                controllers['exportateur']!.text,
                            destCodeExportateur:
                                controllers['codeExportateur']!.text,
                            destPortUsineDechargement:
                                controllers['portUsine']!.text,
                            destPontBascule: controllers['pontBascule']!.text,
                            destNomMagasin: controllers['magasin']!.text,
                            destKor: controllers['kor']!.text,
                            destNombreSacsDecharges: num.tryParse(
                              controllers['sacsDecharges']!.text,
                            ),
                            destNombreSacsRembourses: num.tryParse(
                              controllers['sacsRembourses']!.text,
                            ),
                            destTauxHumidite: num.tryParse(
                              controllers['tauxHumidite']!.text,
                            ),
                            destPoidsBrut: num.tryParse(
                              controllers['poidsBrut']!.text,
                            ),
                            destTare: num.tryParse(controllers['tare']!.text),
                            destPoidsNet: num.tryParse(
                              controllers['poidsNet']!.text,
                            ),
                            destPrixKg: num.tryParse(
                              controllers['prixKg']!.text,
                            ),
                          );

                          Navigator.pop(dialogContext);
                          context.read<LoadingBloc>().add(
                            UpdateLoadingDetailsEvent(updatedEntity),
                          );
                          context.read<LoadingBloc>().add(
                            UpdateLoadingStatusEvent(updatedEntity, 'UNLOADED'),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                        ),
                        child: Text(
                          'Valider',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool isDate = false,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          labelStyle: GoogleFonts.poppins(fontSize: 13),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        style: GoogleFonts.poppins(fontSize: 14),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'Ce champ est obligatoire';
          }
          if (isNumber && value != null && value.isNotEmpty) {
            if (num.tryParse(value) == null) {
              return 'Veuillez entrer un nombre valide';
            }
          }
          return null;
        },
        onTap: isDate
            ? () async {
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
            : null,
      ),
    );
  }

  // Build sections (keeping existing methods)
  Widget _buildGeneralInfo() {
    if (_currentChargement.date == null &&
        _currentChargement.sticker == null &&
        _currentChargement.campagne == null)
      return const SizedBox.shrink();

    return _SectionCard(
      title: "Informations générales",
      icon: Icons.info_outline,
      children: [
        if (_currentChargement.date != null)
          _buildRow("Date :", _currentChargement.date!),
        if (_currentChargement.sticker != null)
          _buildRow("Sticker :", _currentChargement.sticker!),
        _buildRow("Campagne :", _currentChargement.campagne ?? 'N/A'),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return _SectionCard(
      title: "Localisation Départ",
      icon: Icons.location_on_outlined,
      children: [
        if (_currentChargement.region != null)
          _buildRow("Région :", _currentChargement.region!),
        if (_currentChargement.departement != null)
          _buildRow("Département :", _currentChargement.departement!),
        if (_currentChargement.sousPrefecture != null)
          _buildRow("Sous-préfecture :", _currentChargement.sousPrefecture!),
        if (_currentChargement.village != null)
          _buildRow("Village :", _currentChargement.village!),
      ],
    );
  }

  Widget _buildDestinationInfo() {
    return _SectionCard(
      title: "Destination",
      icon: Icons.place_outlined,
      children: [
        if (_currentChargement.destinationVille != null)
          _buildRow("Ville :", _currentChargement.destinationVille!),
        if (_currentChargement.destinateur != null)
          _buildRow("Destinataire :", _currentChargement.destinateur!),
        if (_currentChargement.nomMagasin != null)
          _buildRow("Magasin :", _currentChargement.nomMagasin!),
      ],
    );
  }

  Widget _buildTransportInfo() {
    return _SectionCard(
      title: "Transport",
      icon: Icons.local_shipping_outlined,
      children: [
        if (_currentChargement.nomTransporteur != null)
          _buildRow("Transporteur :", _currentChargement.nomTransporteur!),
        if (_currentChargement.contactTransporteur != null)
          _buildRow("Contact :", _currentChargement.contactTransporteur!),
        if (_currentChargement.marqueCamion != null)
          _buildRow("Marque camion :", _currentChargement.marqueCamion!),
        if (_currentChargement.immatriculation != null)
          _buildRow("Immatriculation :", _currentChargement.immatriculation!),
        if (_currentChargement.nomChauffeur != null)
          _buildRow("Chauffeur :", _currentChargement.nomChauffeur!),
        if (_currentChargement.permisConduire != null)
          _buildRow("Permis :", _currentChargement.permisConduire!),
      ],
    );
  }

  Widget _buildLoadingDetails() {
    return _SectionCard(
      title: "Détails du chargement",
      icon: Icons.inventory_outlined,
      children: [
        if (_currentChargement.sacs != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildText("Nombre de sacs", _currentChargement.sacs.toString()),
              if (_currentChargement.poids != null)
                _buildText("Poids", "${_currentChargement.poids} Kg"),
            ],
          ),
        if (_currentChargement.sacs != null) const SizedBox(height: 8),
        if (_currentChargement.denomination != null)
          _buildRow("Dénomination :", _currentChargement.denomination!),
        if (_currentChargement.thDepart != null)
          _buildRow("TH Départ :", _currentChargement.thDepart!),
      ],
    );
  }

  Widget _buildUnloadingInfo() {
    return _SectionCard(
      title: "Informations de destination",
      icon: Icons.unarchive_outlined,
      children: [
        if (_currentChargement.destDateDechargement != null)
          _buildRow(
            "Date déchargement :",
            _currentChargement.destDateDechargement!,
          ),
        if (_currentChargement.destHeure != null)
          _buildRow("Heure :", _currentChargement.destHeure!),
        if (_currentChargement.destNomExportateur != null)
          _buildRow("Exportateur :", _currentChargement.destNomExportateur!),
        if (_currentChargement.destPortUsineDechargement != null)
          _buildRow(
            "Port/Usine :",
            _currentChargement.destPortUsineDechargement!,
          ),
        if (_currentChargement.destKor != null)
          _buildRow(
            "KOR :",
            _currentChargement.destKor!,
            isBold: true,
            color: primaryColor,
          ),
        if (_currentChargement.destPoidsNet != null)
          _buildRow(
            "Poids net :",
            "${_currentChargement.destPoidsNet} Kg",
            isBold: true,
            color: primaryColor,
          ),
      ],
    );
  }

  Widget _buildFicheImage() {
    return _SectionCard(
      title: "Photo de la fiche",
      icon: Icons.photo_outlined,
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: ClipRRectImage(
            tag:
                'receipt_${_currentChargement.numeroFiche}-${_currentChargement.image}',
            imagePath:
                "https://s3.dev.go.incubtek.com/proof/${_currentChargement.image}",
            borderRadius: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptsSection() {
    return _SectionCard(
      title: _isLoadingReceipts
          ? "Chargement des reçus..."
          : "Reçus (${_receipts.length})",
      icon: Icons.receipt_outlined,
      children: [
        if (_isLoadingReceipts)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else
          ..._receipts.map((receipt) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reçu #${receipt.numeroRecu}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (receipt.image != null)
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: ClipRRectImage(
                      tag: 'receipt_${receipt.numeroRecu}-${receipt.image}',
                      imagePath:
                          "https://s3.dev.go.incubtek.com/proof/${receipt.image}",
                      borderRadius: 10,
                    ),
                  )
                else
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey.shade500,
                        size: 50,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
              ],
            );
          }).toList(),
      ],
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
    double fontsize = 14,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: fontsize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: fontsize,
                fontWeight: isBold ? FontWeight.w500 : FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'VALIDATED':
      case 'UNLOADED':
        return Colors.green;
      case 'PENDING':
      case 'EN_ATTENTE':
        return Colors.orange;
      case 'OK_FOR_CONTROL':
      case 'OK_POUR_CONTROLE':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'VALIDATED':
        return 'Validé';
      case 'PENDING':
      case 'EN_ATTENTE':
        return 'En attente';
      case 'OK_FOR_CONTROL':
      case 'OK_POUR_CONTROLE':
        return 'OK pour contrôle';
      case 'UNLOADED':
        return 'Déchargé';
      default:
        return status;
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: primaryColor, size: 18),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFC2C3C4)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [...children],
          ),
        ),
      ],
    );
  }
}

class ClipRRectImage extends StatelessWidget {
  final String imagePath;
  final double borderRadius;
  final String tag;

  const ClipRRectImage({
    super.key,
    required this.imagePath,
    required this.tag,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                FullscreenImagePage(imagePath: imagePath, tag: tag),
          ),
        );
      },
      child: Hero(
        tag: tag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.network(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Colors.grey.shade500,
                  size: 50,
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
