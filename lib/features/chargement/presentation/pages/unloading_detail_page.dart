import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
import '../bloc/unloading/unloading_bloc.dart';

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
      child: _UnloadingDetailView(
        chargement: chargement,
        remoteDataSource: remoteDataSource,
      ),
    );
  }
}

class _UnloadingDetailView extends StatefulWidget {
  final ChargementEntity chargement;
  final ChargementRemoteDataSource remoteDataSource;

  const _UnloadingDetailView({
    required this.chargement,
    required this.remoteDataSource,
  });

  @override
  State<_UnloadingDetailView> createState() => _UnloadingDetailViewState();
}

class _UnloadingDetailViewState extends State<_UnloadingDetailView> {
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

  bool get _isUnloaded {
    return [
      'UNLOADED',
      'unloaded',
    ].contains(_currentChargement.status.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UnloadingBloc, UnloadingState>(
      listener: (context, state) {
        if (state is UnloadingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('KOR mis à jour avec succès')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(color: Colors.black),
          centerTitle: false,
          title: Text(
            'Détails du déchargement',
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
              _buildUnloadingInfo(),
              const SizedBox(height: 16),
              if (_currentChargement.destNombreSacsDecharges != null ||
                  _currentChargement.destPoidsNet != null)
                _buildMeasures(),
              if (_currentChargement.destNombreSacsDecharges != null ||
                  _currentChargement.destPoidsNet != null)
                const SizedBox(height: 16),

              if (_currentChargement.destObservations != null)
                _buildObservations(),
              if (_currentChargement.destObservations != null)
                const SizedBox(height: 16),

              if (_currentChargement.image != null) _buildFicheImage(),
              if (_currentChargement.image != null) const SizedBox(height: 16),
              if (_receipts.isNotEmpty || _isLoadingReceipts)
                _buildReceiptsSection(),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
        floatingActionButton: _isUnloaded
            ? FloatingActionButton.extended(
                onPressed: () => _showKorEditDialog(context),
                backgroundColor: primaryColor,
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                label: Text(
                  'Modifier KOR',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  void _showKorEditDialog(BuildContext context) {
    final korController = TextEditingController(
      text: _currentChargement.destKor ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Modifier KOR',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: korController,
          decoration: InputDecoration(
            labelText: 'KOR',
            labelStyle: GoogleFonts.poppins(),
            border: const OutlineInputBorder(),
            hintText: 'Entrez le nouveau KOR',
          ),
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Annuler', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              if (korController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Le KOR ne peut pas être vide'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(dialogContext);
              context.read<UnloadingBloc>().add(
                UpdateUnloadingKOREvent(_currentChargement, korController.text),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: Text(
              'Enregistrer',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
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
      title: "Provenance",
      icon: Icons.location_on_outlined,
      children: [
        _currentChargement.regionLibelle != null
            ? _buildRow("Région :", _currentChargement.regionLibelle!)
            : _currentChargement.region != null
            ? _buildRow("Région :", _currentChargement.region!)
            : const SizedBox.shrink(),

        _currentChargement.departementLibelle != null
            ? _buildRow("Département :", _currentChargement.departementLibelle!)
            : _currentChargement.departement != null
            ? _buildRow("Département :", _currentChargement.departement!)
            : const SizedBox.shrink(),

        _currentChargement.villageLibelle != null
            ? _buildRow("Village :", _currentChargement.villageLibelle!)
            : _currentChargement.village != null
            ? _buildRow("Village :", _currentChargement.village!)
            : const SizedBox.shrink(),

        _currentChargement.magasinLibelle != null
            ? _buildRow(
                "Magasin provenance :",
                _currentChargement.magasinLibelle!,
              )
            : _currentChargement.nomMagasin != null
            ? _buildRow("Magasin provenance :", _currentChargement.nomMagasin!)
            : const SizedBox.shrink(),
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
        if (_currentChargement.destNomMagasin != null)
          _buildRow(
            "Magasin destination :",
            _currentChargement.destNomMagasin!,
          ),
        if (_currentChargement.destPortUsineDechargement != null)
          _buildRow(
            "Port/Usine :",
            _currentChargement.destPortUsineDechargement!,
          ),
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
      title: "Détails au départ",
      icon: Icons.inventory_outlined,
      children: [
        if (_currentChargement.sacs != null && _currentChargement.poids != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildText("Sacs départ", _currentChargement.sacs.toString()),
              _buildText("Poids départ", "${_currentChargement.poids!} T"),
            ],
          ),
        if (_currentChargement.sacs != null) const SizedBox(height: 8),
        if (_currentChargement.thDepart != null)
          _buildRow("TH Départ :", _currentChargement.thDepart!),
      ],
    );
  }

  Widget _buildUnloadingInfo() {
    return _SectionCard(
      title: "Informations de déchargement",
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
        if (_currentChargement.destCodeExportateur != null)
          _buildRow(
            "Code exportateur :",
            _currentChargement.destCodeExportateur!,
          ),
        if (_currentChargement.destPontBascule != null)
          _buildRow("Pont bascule :", _currentChargement.destPontBascule!),
        if (_currentChargement.destKor != null)
          _buildRow(
            "KOR :",
            _currentChargement.destKor!,
            isBold: true,
            color: primaryColor,
            fontsize: 15,
          ),
      ],
    );
  }

  Widget _buildMeasures() {
    return _SectionCard(
      title: "Mesures à l'arrivée",
      icon: Icons.scale_outlined,
      children: [
        if (_currentChargement.destNombreSacsDecharges != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildText(
                "Sacs déchargés",
                _currentChargement.destNombreSacsDecharges.toString(),
              ),
              if (_currentChargement.destNombreSacsRembourses != null)
                _buildText(
                  "Sacs remboursés",
                  _currentChargement.destNombreSacsRembourses.toString(),
                ),
            ],
          ),
        const SizedBox(height: 8),
        if (_currentChargement.destTauxHumidite != null)
          _buildRow(
            "Taux humidité :",
            "${_currentChargement.destTauxHumidite}%",
          ),
        if (_currentChargement.destTauxDefectueux != null)
          _buildRow(
            "Taux défectueux :",
            "${_currentChargement.destTauxDefectueux}%",
          ),
        if (_currentChargement.destGrainage != null)
          _buildRow("Grainage :", "${_currentChargement.destGrainage}"),
        if (_currentChargement.destPoidsBrut != null)
          _buildRow("Poids brut :", "${_currentChargement.destPoidsBrut} T"),
        if (_currentChargement.destTare != null)
          _buildRow("Tare :", "${_currentChargement.destTare} Kg"),
        if (_currentChargement.destPoidsNet != null)
          _buildRow(
            "Poids net :",
            "${_currentChargement.destPoidsNet} T",
            isBold: true,
            color: primaryColor,
            fontsize: 16,
          ),
        if (_currentChargement.destPrixKg != null)
          _buildRow(
            "Prix/Kg :",
            "${_currentChargement.destPrixKg} F",
            color: primaryColor,
          ),
      ],
    );
  }

  Widget _buildObservations() {
    return _SectionCard(
      title: "Observations",
      icon: Icons.note_alt_outlined,
      children: [
        _buildRow("Observations :", "${_currentChargement.destObservations}"),
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
            tag: "fiche-${_currentChargement.numeroFiche}",
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
                      tag: 'receipt_${receipt.numeroRecu}',
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
      case 'RETURNED':
      case 'RETOURNER':
        return const Color.fromARGB(255, 236, 213, 3);
      case 'REJECTED':
      case 'REJETER':
        return Colors.red;
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
      case 'RETURNED':
        return 'Retourné';
      case 'REJECTED':
        return 'Rejeté';
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
