import 'dart:io';

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

  @override
  void initState() {
    super.initState();
    _checkPermissions();
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
    if (!_formKey.currentState!.validate()) return;

    final entity = TransfertEntity(
      submissionId: '',
      formId: 1,
      status: 'draft',
      submissionMethod: _forceUssd ? 'ussd' : 'http',
      agentId: 'AGENT_007',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,

      // Tous les champs mappés aux contrôleurs
      numeroFiche: numeroFicheController.text,
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
      photoFiche: photoFiche?.path,
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
                  color: Colors.white,
                  children: [
                    textField(
                      dateChargementController,
                      label: "Date de déchargement *",
                      hint: "jj/mm/aaaa",
                      validator: requiredValidator,
                      keyboardType: TextInputType.datetime,
                    ),
                    textField(
                      regionController,
                      label: "Région *",
                      hint: "Ex : Poro",
                      validator: requiredValidator,
                      keyboardType: TextInputType.text,
                    ),
                    textField(
                      departementController,
                      label: "Département *",
                      hint: "Ex : Korhogo",
                      validator: requiredValidator,
                      keyboardType: TextInputType.text,
                    ),
                    textField(
                      sousprefectureController,
                      label: "Sous-préfecture *",
                      hint: "Ex : Korhogo",
                      validator: requiredValidator,
                      keyboardType: TextInputType.text,
                    ),
                    textField(
                      villageController,
                      label: "Village *",
                      hint: "Ex : Nawalakaha",
                      validator: requiredValidator,
                      keyboardType: TextInputType.text,
                    ),
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
                    textField(
                      nomMagasinController,
                      label: "Nom magasin *",
                      hint: "Ex: Magasin 105 A",
                      validator: requiredValidator,
                    ),
                  ],
                ),
                sectionTitle(
                  "D. Informations sur le Transport",
                  color: Colors.blueAccent,
                ),
                sectionCard(
                  color: Colors.white,
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
                      keyboardType: TextInputType.text,
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
                      keyboardType: TextInputType.text,
                    ),
                    textField(
                      immatriculationController,
                      label: "Immatriculation *",
                      hint: "",
                      validator: requiredValidator,
                      keyboardType: TextInputType.text,
                    ),
                    textField(
                      remorqueController,
                      label: "Remorque *",
                      hint: "",
                      validator: requiredValidator,
                      keyboardType: TextInputType.text,
                    ),
                    textField(
                      avantCamionController,
                      label: "Avant du camion *",
                      hint: "",
                      validator: requiredValidator,
                      keyboardType: TextInputType.text,
                    ),
                    textField(
                      nomChauffeurController,
                      label: "Nom du chauffeur *",
                      hint: "",
                      validator: requiredValidator,
                      keyboardType: TextInputType.text,
                    ),
                    textField(
                      permisConduireController,
                      label: "N° du permis de conduire *",
                      hint: "",
                      validator: requiredValidator,
                      keyboardType: TextInputType.text,
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
                    : Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(photoFiche!.path),
                              fit: BoxFit.cover,
                              height: 250,
                              width: double.infinity,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      setState(() => photoFiche = null),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Supprimer",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: prendrePhoto,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Reprendre",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                const SizedBox(height: 20),
                Text(
                  "Reçus (${_receipts.length})",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),

                ..._receipts
                    .map(
                      (receipt) => Card(
                        margin: EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: Image.file(
                            File(receipt.imagePath),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(
                            "N° ${receipt.receiptNumber}",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _receipts.remove(receipt);
                              });
                            },
                          ),
                        ),
                      ),
                    )
                    .toList(),

                ElevatedButton.icon(
                  onPressed: _showAddReceiptDialog,
                  icon: Icon(Icons.add),
                  label: Text("Ajouter un reçu"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      "Forcer l'envoi hors-ligne (USSD)",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "Activez si la connexion internet est instable.",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    value: _forceUssd,
                    onChanged: (bool value) {
                      setState(() {
                        _forceUssd = value;
                      });
                    },
                    activeColor: primaryColor,
                  ),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _isLoading ? null : enregistrer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.save, color: Colors.white),
                            const SizedBox(width: 10),
                            Text(
                              "Enregistrer le reçu",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget inputSection({required String title, required Widget child}) =>
      Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD9D9D9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      );

  Widget sectionTitle(String title, {required Color color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(
      title,
      style: GoogleFonts.poppins(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    ),
  );

  Widget sectionCard({required Color color, required List<Widget> children}) =>
      Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD9D9D9)),
        ),
        child: Column(children: children),
      );

  Widget infoBanner() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFEFF6FF),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline, color: Colors.blue),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "Le reçu sera automatiquement synchronisé dans le système SND.",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0XFF5D8BCC),
            ),
          ),
        ),
      ],
    ),
  );

  Widget textField(
    TextEditingController controller, {
    String label = "",
    String? hint,
    Function(String)? onChanged,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: validator,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(fontSize: 14),

          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            suffixIcon: suffixIcon,
            hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    ),
  );

  String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Champ obligatoire";
    }
    return null;
  }
}
