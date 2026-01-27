import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:agent_relais/core/constants/ussd_constants.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/services/ussd_service.dart';
import '../../domain/entities/receipt_entity.dart';
import '../../domain/entities/transfert_entity.dart';
import '../bloc/transfert_submission_bloc.dart';
import '../bloc/transfert_submission_event.dart';
import '../bloc/transfert_submission_state.dart';
import '../widgets/receipt_number_scanner.dart';
import '../../../../core/widgets/searchable_dropdown.dart';
import '../../../../features/reference_data/presentation/bloc/sync_bloc.dart';
import '../../../../features/auth/presentation/bloc/login_bloc.dart';

class NewTransfertPage extends StatefulWidget {
  const NewTransfertPage({super.key});

  @override
  State<NewTransfertPage> createState() => _NewTransfertPageState();
}

class _NewTransfertPageState extends State<NewTransfertPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController numeroFicheController = TextEditingController();
  final TextEditingController stickerController = TextEditingController();
  // ORIGINE DU PRODUIT
  final TextEditingController dateChargementController =
      TextEditingController();
  final TextEditingController regionController = TextEditingController();
  final TextEditingController departementController = TextEditingController();
  final TextEditingController sousprefectureController =
      TextEditingController();

  final TextEditingController villageController = TextEditingController();
  final TextEditingController destinationVilleController =
      TextEditingController();
  final TextEditingController destinationAcheteurController =
      TextEditingController();

  // INFORMATION SUR L'ACHETEUR
  final TextEditingController nomAcheteurController = TextEditingController();
  final TextEditingController contactAcheteurController =
      TextEditingController();
  final TextEditingController codeAcheteurController = TextEditingController();
  final TextEditingController nomMagasinController = TextEditingController();

  // TRANSPORT
  final TextEditingController denominationController = TextEditingController();
  final TextEditingController thDepartController = TextEditingController();
  final TextEditingController nbreSacsController = TextEditingController();
  final TextEditingController poidsController = TextEditingController();
  final TextEditingController nomTransporteurController =
      TextEditingController();
  final TextEditingController contactTransporteurController =
      TextEditingController();
  final TextEditingController marqueCamionController = TextEditingController();
  final TextEditingController immatriculationController =
      TextEditingController();
  final TextEditingController remorqueController = TextEditingController();
  final TextEditingController avantCamionController = TextEditingController();
  final TextEditingController nomChauffeurController = TextEditingController();
  final TextEditingController permisConduireController =
      TextEditingController();

  List<ReceiptEntity> _receipts = [];
  double valeurTotale = 0;
  bool _isLoading = false;
  bool _hasPermission = false;
  XFile? photoFiche;

  bool _forceUssd = false;

  String _typeTransfert = "ORDINAIRE";

  // Geo Data
  List<Map<String, dynamic>> _warehouses = [];
  List<Map<String, dynamic>> _regions = [];
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _subPrefectures = [];
  List<Map<String, dynamic>> _sectors = [];

  Map<String, dynamic>? _selectedRegion;
  Map<String, dynamic>? _selectedDepartment;
  Map<String, dynamic>? _selectedSubPrefecture;
  Map<String, dynamic>? _selectedSector;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadWarehouses();
    _initializeRealValues();
    _loadRegions();
  }

  Future<void> _loadWarehouses() async {
    try {
      final items = await context.read<SyncBloc>().localDataSource.getAll(
        'warehouses',
      );
      setState(() {
        _warehouses = items;
      });
    } catch (e) {
      print("Error loading warehouses: $e");
    }
  }

  Future<void> _loadRegions() async {
    try {
      final items = await context.read<SyncBloc>().localDataSource.getAll(
        'regions',
      );
      setState(() => _regions = items);

      // Attempt to auto-select from LoginBloc Active Region
      final loginState = context.read<LoginBloc>().state;
      if (loginState is LoginSuccess && loginState.activeRegion.isNotEmpty) {
        final activeRegion = loginState.activeRegion;
        try {
          final region = items.firstWhere(
            (r) =>
                (r['name'] as String).toLowerCase() ==
                activeRegion.toLowerCase(),
          );
          setState(() {
            _selectedRegion = region;
            regionController.text = region['name'];
          });
          _loadDepartments(region['id']);
        } catch (_) {
          // Region not found or mismatch
        }
      }
    } catch (e) {
      print("Error loading regions: $e");
    }
  }

  Future<void> _loadDepartments(String regionId) async {
    try {
      final items = await context.read<SyncBloc>().localDataSource.getByParent(
        'departments',
        'region_id',
        regionId,
      );
      setState(() {
        _departments = items;
        _departments.sort(
          (a, b) => (a['name'] as String).compareTo(b['name'] as String),
        );
        // Reset children
        _selectedDepartment = null;
        _selectedSubPrefecture = null;
        _selectedSector = null;
        _subPrefectures = [];
        _sectors = [];
        departementController.clear();
        sousprefectureController.clear();
        villageController.clear();
      });
    } catch (e) {
      print("Error loading departments: $e");
    }
  }

  Future<void> _loadSubPrefectures(String depId) async {
    try {
      final items = await context.read<SyncBloc>().localDataSource.getByParent(
        'sub_prefectures',
        'department_id',
        depId,
      );
      setState(() {
        _subPrefectures = items;
        _subPrefectures.sort(
          (a, b) => (a['name'] as String).compareTo(b['name'] as String),
        );
        // Reset children
        _selectedSubPrefecture = null;
        _selectedSector = null;
        _sectors = [];
        sousprefectureController.clear();
        villageController.clear();
      });
    } catch (e) {
      print("Error loading sub-prefectures: $e");
    }
  }

  Future<void> _loadSectors(String subId) async {
    try {
      final items = await context.read<SyncBloc>().localDataSource.getByParent(
        'sectors',
        'sub_prefecture_id',
        subId,
      );
      setState(() {
        _sectors = items;
        _sectors.sort(
          (a, b) => (a['name'] as String).compareTo(b['name'] as String),
        );
        _selectedSector = null;
        villageController.clear();
      });
    } catch (e) {
      print("Error loading sectors: $e");
    }
  }

  @override
  void dispose() {
    numeroFicheController.dispose();
    stickerController.dispose();
    dateChargementController.dispose();
    regionController.dispose();
    departementController.dispose();
    villageController.dispose();
    destinationVilleController.dispose();
    destinationAcheteurController.dispose();
    nomAcheteurController.dispose();
    contactAcheteurController.dispose();
    codeAcheteurController.dispose();
    nomMagasinController.dispose();
    denominationController.dispose();
    thDepartController.dispose();
    nbreSacsController.dispose();
    poidsController.dispose();

    nomTransporteurController.dispose();
    contactTransporteurController.dispose();
    marqueCamionController.dispose();
    immatriculationController.dispose();
    remorqueController.dispose();
    avantCamionController.dispose();
    nomChauffeurController.dispose();
    permisConduireController.dispose();

    super.dispose();
  }

  void _checkPermissions() async {
    final hasPermission = await UssdService.hasPermissions();
    setState(() => _hasPermission = hasPermission);
  }

  void _requestPermissions() async {
    final hasPermission = await UssdService.checkAndRequestPermissions();
    setState(() => _hasPermission = hasPermission);
  }

  Future<void> prendrePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        photoFiche = image;
      });
    }
  }

  Future<void> _showAddReceiptDialog() async {
    final picker = ImagePicker();
    XFile? tempImage;
    final numberController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(
            "Ajouter un reçu",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final img = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (img != null) {
                    setStateDialog(() => tempImage = img);
                  }
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: tempImage != null
                      ? Image.file(File(tempImage!.path), fit: BoxFit.cover)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.grey,
                            ),
                            Text(
                              "Prendre photo",
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: numberController,
                decoration: InputDecoration(
                  labelText: "Numéro du reçu",
                  hintText: "Ex: 1234567",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.qr_code_scanner, color: primaryColor),
                    tooltip: "Scanner le numéro",
                    onPressed: () async {
                      final scannedNumber = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) => ReceiptNumberScanner(
                            onNumberDetected: (number) {
                              Navigator.pop(context, number);
                            },
                            // Pattern pour les numéros de reçu (5 à 10 chiffres)
                            numberPattern: RegExp(r'\b\d{5,10}\b'),
                          ),
                        ),
                      );

                      if (scannedNumber != null) {
                        setStateDialog(() {
                          numberController.text = scannedNumber;
                        });
                      }
                    },
                  ),
                ),
                keyboardType: TextInputType.number,
              ),

              SizedBox(height: 12),

              // Bouton proéminent pour scanner
              OutlinedButton.icon(
                onPressed: () async {
                  final scannedNumber = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => ReceiptNumberScanner(
                        onNumberDetected: (number) {
                          Navigator.pop(context, number);
                        },
                        numberPattern: RegExp(r'\b\d{5,10}\b'),
                      ),
                    ),
                  );

                  if (scannedNumber != null) {
                    setStateDialog(() {
                      numberController.text = scannedNumber;
                    });
                  }
                },
                icon: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.document_scanner),
                ),
                label: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text("Scanner le numéro automatiquement"),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                if (tempImage != null && numberController.text.isNotEmpty) {
                  setState(() {
                    _receipts.add(
                      ReceiptEntity(
                        imagePath: tempImage!.path,
                        receiptNumber: numberController.text,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: Text("Ajouter"),
            ),
          ],
        ),
      ),
    );
  }

  void enregistrer() {
    if (!_hasPermission) {
      _requestPermissions();
      return;
    }

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez corriger les champs obligatoires'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    } // Extract username and campagne from LoginBloc
    final loginState = context.read<LoginBloc>().state;
    String username = 'agent_unknown';
    String campagne = '2025-2026';

    if (loginState is LoginSuccess) {
      username = loginState.user.username;
      campagne = loginState.campagne;
    }

    // Generate bundle_id from receipt numbers
    final bundleId = _receipts.map((r) => r.receiptNumber).join('');

    final entity = TransfertEntity(
      numeroFiche: numeroFicheController.text,
      formId: TRANSFERT_FORM_ID,
      status: 'draft',
      submissionMethod: _forceUssd ? 'ussd' : 'http',
      username: username,
      bundleId: bundleId,
      campagne: campagne,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,

      typeTransfert: _typeTransfert,
      sticker: stickerController.text,
      date: dateChargementController.text,
      region: regionController.text,
      departement: departementController.text,
      sousPrefecture: sousprefectureController.text,
      village: villageController.text,
      destinationVille: destinationVilleController.text,
      destinateur: destinationAcheteurController.text,
      acheteur: nomAcheteurController.text,
      contactAcheteur: contactAcheteurController.text,
      codeAcheteur: codeAcheteurController.text,
      nomMagasin: nomMagasinController.text,
      denomination: denominationController.text,
      thDepart: thDepartController.text,
      sacs: nbreSacsController.text,
      poids: poidsController.text,
      nomTransporteur: nomTransporteurController.text,
      contactTransporteur: contactTransporteurController.text,
      marqueCamion: marqueCamionController.text,
      immatriculation: immatriculationController.text,
      remorque: remorqueController.text,
      avantCamion: avantCamionController.text,
      nomChauffeur: nomChauffeurController.text,
      permisConduire: permisConduireController.text,
      image: photoFiche?.path,
      receipts: _receipts,
    );

    context.read<TransfertSubmissionBloc>().add(
      SubmitTransfertEvent(entity, forceUssd: _forceUssd),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        centerTitle: false,
        title: Text(
          "Nouvelle fiche de transfert",
          style: GoogleFonts.poppins(
            color: greenSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<TransfertSubmissionBloc, TransfertSubmissionState>(
        listener: (context, state) {
          if (state is TransfertSubmitting) {
            setState(() => _isLoading = true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Soumission en cours...",
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: Colors.blueAccent,
              ),
            );
          }

          if (state is TransfertSubmissionSuccess) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Succès: Reçu ${state.result.submissionId} envoyé (via ${state.result.viaHttp ? 'HTTP' : 'USSD'}).",
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: Color(0xFF0E8446),
              ),
            );

            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteConstants.confirmation,
              (route) => false,
            );
          }

          if (state is TransfertSubmissionFailure) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Échec: ${state.message}",
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                infoBanner(),
                const SizedBox(height: 15),

                sectionTitle("Type de transfert *", color: primaryColor),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E8446),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFA5D6A7)),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: Text(
                          "ORDINAIRE",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        value: "ORDINAIRE",
                        groupValue: _typeTransfert,

                        activeColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _typeTransfert = value!;
                          });
                        },
                      ),
                      SizedBox(height: 1),
                      RadioListTile<String>(
                        title: Text(
                          "INTÉRIEURE",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        value: "INTÉRIEURE",
                        groupValue: _typeTransfert,
                        activeColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _typeTransfert = value!;
                          });
                        },
                      ),
                      SizedBox(height: 1),
                      RadioListTile<String>(
                        title: Text(
                          "USINE",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        value: "USINE",
                        groupValue: _typeTransfert,
                        activeColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _typeTransfert = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                inputSection(
                  title: "N° Fiche *",
                  child: textField(
                    numeroFicheController,
                    hint: "Ex: RBC-2025-001",
                    validator: requiredValidator,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.qr_code_scanner, color: primaryColor),
                      tooltip: "Scanner le numéro",
                      onPressed: () async {
                        final scannedNumber = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => ReceiptNumberScanner(
                              onNumberDetected: (number) {
                                Navigator.pop(context, number);
                              },
                              numberPattern: RegExp(r'\b\d{5,10}\b'),
                            ),
                          ),
                        );

                        if (scannedNumber != null) {
                          setState(() {
                            numeroFicheController.text = scannedNumber;
                          });
                        }
                      },
                    ),
                  ),
                ),
                inputSection(
                  title: "Sticker *",
                  child: textField(
                    stickerController,
                    hint: "Ex: RBC-2025-001",
                    validator: requiredValidator,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.qr_code_scanner, color: primaryColor),
                      tooltip: "Scanner le numéro",
                      onPressed: () async {
                        final scannedNumber = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => ReceiptNumberScanner(
                              onNumberDetected: (number) {
                                Navigator.pop(context, number);
                              },
                              // Pattern pour les numéros de reçu (5 à 10 chiffres)
                              numberPattern: RegExp(r'\b\d{5,10}\b'),
                            ),
                          ),
                        );

                        if (scannedNumber != null) {
                          setState(() {
                            stickerController.text = scannedNumber;
                          });
                        }
                      },
                    ),
                  ),
                ),

                sectionTitle("A. Origine du produit", color: greenSecondary),
                sectionCard(
                  color: Colors.grey.shade200,
                  children: [
                    textField(
                      dateChargementController,
                      label: "Date de chargement *",
                      hint: "jj/mm/aaaa",
                      validator: requiredValidator,
                      keyboardType: TextInputType.datetime,
                    ),
                    SearchableDropdown<Map<String, dynamic>>(
                      label: "Région *",
                      items: _regions,
                      value: _selectedRegion,
                      itemLabel: (item) => item['name'] as String,
                      onChanged: (value) {
                        setState(() {
                          _selectedRegion = value;
                          regionController.text = value?['id'] ?? "";
                        });
                        if (value != null)
                          _loadDepartments(value['id'] as String);
                      },
                      validator: (value) => value == null ? "Requis" : null,
                    ),
                    const SizedBox(height: 15),
                    SearchableDropdown<Map<String, dynamic>>(
                      label: "Département *",
                      items: _departments,
                      value: _selectedDepartment,
                      itemLabel: (item) => item['name'] as String,
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartment = value;
                          departementController.text = value?['name'] ?? "";
                        });
                        if (value != null)
                          _loadSubPrefectures(value['id'] as String);
                      },
                      validator: (value) => value == null ? "Requis" : null,
                    ),
                    const SizedBox(height: 15),
                    SearchableDropdown<Map<String, dynamic>>(
                      label: "Sous-préfecture *",
                      items: _subPrefectures,
                      value: _selectedSubPrefecture,
                      itemLabel: (item) => item['name'] as String,
                      onChanged: (value) {
                        setState(() {
                          _selectedSubPrefecture = value;
                          sousprefectureController.text = value?['id'] ?? "";
                        });
                        if (value != null) _loadSectors(value['id'] as String);
                      },
                      validator: (value) => value == null ? "Requis" : null,
                    ),
                    const SizedBox(height: 15),
                    SearchableDropdown<Map<String, dynamic>>(
                      label: "Village *",
                      items: _sectors,
                      value: _selectedSector,
                      itemLabel: (item) => item['name'] as String,
                      onChanged: (value) {
                        setState(() {
                          _selectedSector = value;
                          villageController.text = value?['id'] ?? "";
                        });
                      },
                      validator: (value) => value == null ? "Requis" : null,
                    ),
                    const SizedBox(height: 15),
                    textField(
                      destinationVilleController,
                      label: "Destination Prevue/Ville *",
                      hint: "Ex : Abidjan",
                      validator: requiredValidator,
                      keyboardType: TextInputType.text,
                    ),
                    textField(
                      destinationAcheteurController,
                      label: "Destination Exportateur/Usine *",
                      hint: "Ex : XXXXX",
                      validator: requiredValidator,
                      keyboardType: TextInputType.text,
                    ),
                  ],
                ),

                sectionTitle(
                  "B. Informations sur l'Acheteur",
                  color: Colors.orange,
                ),
                sectionCard(
                  color: const Color(0xFFFFF3E0),
                  children: [
                    textField(
                      nomAcheteurController,
                      label: "Nom acheteur *",
                      hint: "Ex: Coopérative XYZ / 105 A",
                      validator: requiredValidator,
                      keyboardType: TextInputType.text,
                    ),
                    textField(
                      contactAcheteurController,
                      label: "Contact *",
                      hint: "Ex: 0707080808",
                      validator: requiredValidator,
                      keyboardType: TextInputType.phone,
                    ),
                    textField(
                      codeAcheteurController,
                      label: "Code de l'Acheteur *",
                      hint: "",
                      validator: requiredValidator,
                    ),
                    _warehouses.isEmpty
                        ? textField(
                            nomMagasinController,
                            label: "Nom magasin *",
                            hint: "Ex: Magasin 105 A",
                            validator: requiredValidator,
                          )
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: "Nom magasin *",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: _warehouses.map((w) {
                                return DropdownMenuItem<String>(
                                  value: w['name'] as String,
                                  child: Text(
                                    w['name'] as String,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  nomMagasinController.text = value ?? "";
                                });
                              },
                              validator: (value) =>
                                  value == null ? "Champ requis" : null,
                            ),
                          ),
                  ],
                ),
                sectionTitle(
                  "D. Informations sur le Transport",
                  color: Colors.blueAccent,
                ),
                sectionCard(
                  color: const Color.fromARGB(255, 197, 216, 245),
                  children: [
                    textField(
                      denominationController,
                      label: "Dénomination du produit *",
                      hint: "",
                      validator: requiredValidator,
                    ),
                    textField(
                      thDepartController,
                      label: "TH Départ *",
                      hint: "",
                      validator: requiredValidator,
                    ),
                    textField(
                      nbreSacsController,
                      label: "Nombre de sacs *",
                      hint: "Ex: 1",
                      validator: requiredValidator,
                      keyboardType: TextInputType.number,
                    ),
                    textField(
                      poidsController,
                      label: "Poids théorique en tonne (T)*",
                      hint: "Ex: 800",
                      validator: requiredValidator,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    textField(
                      nomTransporteurController,
                      label: "Nom du transporteur *",
                      hint: "Ex: Soro Yaya",
                      validator: requiredValidator,
                    ),
                    textField(
                      contactTransporteurController,
                      label: "Contact du transporteur *",
                      hint: "Ex: 0708080809",
                      validator: requiredValidator,
                      keyboardType: TextInputType.phone,
                    ),
                    textField(
                      marqueCamionController,
                      label: "Marque camion *",
                      hint: "Ex: Kia",
                      validator: requiredValidator,
                    ),
                    textField(
                      immatriculationController,
                      label: "Immatriculation *",
                      hint: "",
                      validator: requiredValidator,
                    ),
                    textField(
                      remorqueController,
                      label: "Remorque *",
                      hint: "",
                      validator: requiredValidator,
                    ),
                    textField(
                      avantCamionController,
                      label: "Avant du camion *",
                      hint: "",
                      validator: requiredValidator,
                    ),
                    textField(
                      nomChauffeurController,
                      label: "Nom du chauffeur *",
                      hint: "",
                      validator: requiredValidator,
                    ),
                    textField(
                      permisConduireController,
                      label: "N° du permis de conduire *",
                      hint: "",
                      validator: requiredValidator,
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Text(
                  "Photo de la fiche",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                photoFiche == null
                    ? GestureDetector(
                        onTap: _isLoading ? null : prendrePhoto,
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          height: 200,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9D9D9).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DottedBorder(
                            options: RoundedRectDottedBorderOptions(
                              dashPattern: [5, 5],
                              strokeWidth: 2,
                              padding: const EdgeInsets.all(16),
                              color: Colors.grey,
                              radius: const Radius.circular(10),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Appuyer pour prendre une photo",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : Stack(
                        children: [
                          Image.file(
                            File(photoFiche!.path),
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  photoFiche = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 15),

                // Reçu List
                sectionTitle("Reçus associés", color: Colors.purple),
                if (_receipts.isEmpty)
                  Text(
                    "Aucun reçu ajouté",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  )
                else
                  Column(
                    children: _receipts.map((e) {
                      return ListTile(
                        leading: Icon(Icons.receipt),
                        title: Text("Reçu ${e.receiptNumber}"),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _receipts.remove(e);
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),

                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _showAddReceiptDialog,
                  icon: Icon(Icons.add),
                  label: Text("Ajouter un reçu"),
                ),

                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : enregistrer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E8446),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Soumettre la fiche",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 20),
                // CheckboxListTile(
                //   title: Text("Forcer envoi USSD (Simulation)"),
                //   value: _forceUssd,
                //   onChanged: (val) {
                //     setState(() {
                //       _forceUssd = val ?? false;
                //     });
                //   },
                // ),
                // SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title, {required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 10.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: color,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget sectionCard({required List<Widget> children, Color? color}) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 10),
      child: Column(children: children),
    );
  }

  Widget inputSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 15),
      ],
    );
  }

  Widget textField(
    TextEditingController controller, {
    String? hint,
    String? label,
    FormFieldValidator<String>? validator,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  String? requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Champ requis';
    }
    return null;
  }

  Widget infoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Remplissez soigneusement les champs. Les données seront synchronisées automatiquement.",
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String generateNumeroFiche() {
    final year = DateTime.now().year;
    final random = Random();
    final number = random.nextInt(10000).toString().padLeft(4, '0');

    return 'FICH-$year-$number';
  }

  void _initializeRealValues() {
    setState(() {
      numeroFicheController.text = generateNumeroFiche();
      stickerController.text = "STK-ABJ-9921";
      dateChargementController.text = "2025-01-27";
      destinationVilleController.text = "SAN-PEDRO";
      destinationAcheteurController.text = "USINE CARGILL";

      nomAcheteurController.text = "COOP CA-N'ZRAMA";
      contactAcheteurController.text = "0708091011";
      codeAcheteurController.text = "COOP-882";
      nomMagasinController.text = "MAGASIN CENTRAL B";

      denominationController.text = "CACAO GRADE 1";
      thDepartController.text = "12.5";
      nbreSacsController.text = "1500";
      poidsController.text = "45";

      nomTransporteurController.text = "SOTRACI LOGISTICS";
      contactTransporteurController.text = "0102030405";
      marqueCamionController.text = "VOLVO FH16";
      immatriculationController.text = "1234 HK 01";
      remorqueController.text = "RE-9902";
      avantCamionController.text = "AV-7712";
      nomChauffeurController.text = "KOUASSI AMANI";
      permisConduireController.text = "AB-00982-2015";
    });
  }
}
