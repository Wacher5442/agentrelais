import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/route_constants.dart';
import '../bloc/receipt_submission_bloc.dart';
import '../bloc/receipt_submission_event.dart';
import '../bloc/receipt_submission_state.dart';
import '../dtos/receipt_form_data.dart';

class NewRecuPage extends StatefulWidget {
  const NewRecuPage({super.key});

  @override
  State<NewRecuPage> createState() => _NewRecuPageState();
}

class _NewRecuPageState extends State<NewRecuPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController numeroRecuController = TextEditingController();
  final TextEditingController villageController = TextEditingController();
  final TextEditingController agrementController = TextEditingController();
  final TextEditingController acheteurController = TextEditingController();
  final TextEditingController pisteurController = TextEditingController();
  final TextEditingController contactPisteurController =
      TextEditingController();
  final TextEditingController producteurController = TextEditingController();
  final TextEditingController villageProdController = TextEditingController();
  final TextEditingController contactProdController = TextEditingController();
  final TextEditingController sacsAchetesController = TextEditingController();
  final TextEditingController sacsRembController = TextEditingController();
  final TextEditingController poidsController = TextEditingController();
  final TextEditingController prixUnitaireController = TextEditingController();
  final TextEditingController montantPayeController = TextEditingController();

  String? departement;
  String? sousPrefecture;
  XFile? photoRecu;

  double valeurTotale = 0;
  bool _isLoading = false;

  final List<String> departements = ["Gontougo", "Poro", "Tonkpi"];
  final Map<String, List<String>> sousPrefectures = {
    "Gontougo": ["Tanda", "Transua"],
    "Poro": ["Korhogo", "Sinématiali"],
    "Tonkpi": ["Man", "Zouan-Hounien"],
  };

  @override
  void dispose() {
    numeroRecuController.dispose();
    villageController.dispose();
    agrementController.dispose();
    acheteurController.dispose();
    pisteurController.dispose();
    contactPisteurController.dispose();
    producteurController.dispose();
    villageProdController.dispose();
    contactProdController.dispose();
    sacsAchetesController.dispose();
    sacsRembController.dispose();
    poidsController.dispose();
    prixUnitaireController.dispose();
    montantPayeController.dispose();
    super.dispose();
  }

  void calculerValeurTotale() {
    final poids = double.tryParse(poidsController.text) ?? 0;
    final prix = double.tryParse(prixUnitaireController.text) ?? 0;
    setState(() {
      valeurTotale = poids * prix;
    });
  }

  String formatMontant(double montant) {
    final format = NumberFormat.decimalPattern("fr_FR");
    return format.format(montant);
  }

  Future<void> prendrePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        photoRecu = image;
      });
    }
  }

  void enregistrer() {
    // 1. Valider le formulaire
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Créer le DTO
    final formData = ReceiptFormData()
      ..numeroRecu = numeroRecuController.text
      ..campagne =
          '2025-2026' // Campagne par défaut
      ..departement = departement
      ..sousPrefecture = sousPrefecture
      ..village = villageController.text
      ..numeroAgrement = agrementController.text
      ..nomAcheteur = acheteurController.text
      ..nomPisteur = pisteurController.text
      ..contactPisteur = contactPisteurController.text
      ..nomProducteur = producteurController.text
      ..villageProducteur = villageProdController.text
      ..contactProducteur = contactProdController.text
      ..nbSacsAchetes = sacsAchetesController.text
      ..nbSacsRembourses = sacsRembController.text
      ..poidsTotal = poidsController.text
      ..prixUnitaire = prixUnitaireController.text
      ..valeurTotale = "$valeurTotale"
      ..montantPaye = montantPayeController.text
      ..photoPath = photoRecu?.path
      ..agentId = 'AGENT_007';

    // 3. Envoyer l'événement au BLoC
    context.read<ReceiptSubmissionBloc>().add(SubmitReceiptEvent(formData));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        centerTitle: false,
        title: Text(
          "Nouveau reçu bord champ",
          style: GoogleFonts.poppins(
            color: greenSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<ReceiptSubmissionBloc, ReceiptSubmissionState>(
        listener: (context, state) {
          if (state is ReceiptSubmitting) {
            setState(() {
              _isLoading = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Envoi en cours...",
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: Colors.blueAccent,
                duration: const Duration(seconds: 2),
              ),
            );
          }

          if (state is ReceiptSubmissionSuccess) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.result.message,
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: state.result.success
                    ? Colors.green
                    : Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );

            // Navigation après succès
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteConstants.confirmation,
              (route) => false,
            );
          }

          if (state is ReceiptSubmissionFailure) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Erreur: ${state.message}",
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
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
                inputSection(
                  title: "N° Reçu *",
                  child: textField(
                    numeroRecuController,
                    hint: "Ex: RBC-2025-001",
                    validator: requiredValidator,
                  ),
                ),
                sectionTitle(
                  "A. Informations sur le lieu d'achat",
                  color: greenSecondary,
                ),
                sectionCard(
                  color: Colors.white,
                  children: [
                    dropdownField(
                      label: "Département *",
                      value: departement,
                      items: departements,
                      onChanged: (v) => setState(() {
                        departement = v;
                        sousPrefecture = null;
                      }),
                    ),
                    dropdownField(
                      label: "Sous préfecture *",
                      value: sousPrefecture,
                      items: departement != null
                          ? sousPrefectures[departement]!
                          : [],
                      onChanged: (v) => setState(() => sousPrefecture = v),
                    ),
                    textField(
                      villageController,
                      label: "Village *",
                      hint: "Ex: Zaranou",
                      validator: requiredValidator,
                    ),
                  ],
                ),
                sectionTitle(
                  "B. Informations sur l'acheteur",
                  color: secondaryColor,
                ),
                sectionCard(
                  color: orangeSection,
                  children: [
                    textField(
                      agrementController,
                      label: "N° Agrément acheteur",
                      hint: "105 A",
                    ),
                    textField(
                      acheteurController,
                      label: "Nom acheteur",
                      hint: "Yao K.",
                    ),
                    textField(
                      pisteurController,
                      label: "Nom pisteur",
                      hint: "Coulibaly Moussa",
                    ),
                    textField(
                      contactPisteurController,
                      label: "Contact pisteur",
                      hint: "07 75 75 75 55",
                    ),
                  ],
                ),
                sectionTitle(
                  "C. Informations sur le producteur",
                  color: secondaryColor,
                ),
                sectionCard(
                  color: Colors.white,
                  children: [
                    textField(
                      producteurController,
                      label: "Nom producteur *",
                      hint: "Koffi A",
                      validator: requiredValidator,
                    ),
                    textField(
                      villageProdController,
                      label: "Village",
                      hint: "Zaranou",
                    ),
                    textField(
                      contactProdController,
                      label: "Contact",
                      hint: "07 07 75 75 55",
                    ),
                  ],
                ),
                sectionTitle(
                  "D. Informations sur l'achat",
                  color: Colors.blueAccent,
                ),
                sectionCard(
                  color: Colors.white,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: textField(
                            sacsAchetesController,
                            label: "Nb sacs achetés*",
                            hint: "Ex: 1",
                            validator: requiredValidator,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: textField(
                            sacsRembController,
                            label: "Nb sacs remboursés",
                            hint: "Ex: 10",
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    textField(
                      poidsController,
                      label: "Poids total (Kg)*",
                      hint: "Ex: 800",
                      validator: requiredValidator,
                      onChanged: (_) => calculerValeurTotale(),
                      keyboardType: TextInputType.number,
                    ),
                    textField(
                      prixUnitaireController,
                      label: "Prix unitaire (F)*",
                      hint: "Ex: 300",
                      validator: requiredValidator,
                      onChanged: (_) => calculerValeurTotale(),
                      keyboardType: TextInputType.number,
                    ),
                    Container(
                      width: double.infinity,
                      height: 100,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: greenSection,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Valeur totale",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "${formatMontant(valeurTotale)} F",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    textField(
                      montantPayeController,
                      label: "Montant payé (FCFA)*",
                      hint: "Ex: 240 000",
                      validator: requiredValidator,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Photo du reçu",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                photoRecu == null
                    ? _buildPhotoPlaceholder()
                    : _buildPhotoPreview(),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : enregistrer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    minimumSize: const Size(double.infinity, 75),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.receipt_long_outlined,
                              size: 32,
                              color: Colors.white,
                            ),
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

  Widget _buildPhotoPlaceholder() {
    return GestureDetector(
      onTap: _isLoading ? null : prendrePhoto,
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        height: 250,
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9).withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40),
          child: DottedBorder(
            options: RoundedRectDottedBorderOptions(
              dashPattern: [5, 5],
              strokeWidth: 2,
              padding: const EdgeInsets.all(16),
              color: Colors.grey,
              radius: const Radius.circular(10),
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_a_photo_outlined,
                    size: 35,
                    color: Colors.black54,
                  ),
                  const SizedBox(height: 10),
                  Text("Prendre une photo", style: GoogleFonts.poppins()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPreview() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          height: 250,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              File(photoRecu!.path),
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => setState(() => photoRecu = null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.delete, size: 32, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      "Supprimer",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : prendrePhoto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D8BCC),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.autorenew, size: 32, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      "Reprendre",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
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
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              "Le reçu sera automatiquement synchronisé dans le système SND.",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0XFF5D8BCC),
              ),
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
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: validator,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
      ],
    ),
  );

  Widget dropdownField({
    required String label,
    String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (label.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          value: value,
          validator: requiredValidator,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: GoogleFonts.poppins(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    ],
  );

  String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Champ obligatoire";
    }
    return null;
  }
}
