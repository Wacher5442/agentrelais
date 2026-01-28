import 'package:agent_relais/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/models/recu_model.dart';
import '../../../../core/utils/format_helper.dart';
import '../../../../core/utils/status_helper.dart';

class RecuDetailPage extends StatelessWidget {
  final Recu recu;

  const RecuDetailPage({super.key, required this.recu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        centerTitle: false,
        title: Text(
          'Détails du reçu',
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
            Container(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reçu #${recu.numeroRecu}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Prod : ${recu.nomProducteur}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10),
                      Divider(),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: StatusHelper.getStyle(recu.status).backgroundColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      'Validé',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: StatusHelper.getStyle(recu.status).textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Lieu d’habita
            _SectionCard(
              title: "Lieu d’habitat",
              icon: Icons.location_on_outlined,
              children: [
                _buildRow("Département :", recu.departement),
                _buildRow("Sous préfecture :", recu.sousPrefecture),
                _buildRow("Village :", recu.village),
              ],
            ),
            const SizedBox(height: 16),

            // Acheteu
            _SectionCard(
              title: "Acheteur",
              icon: Icons.shopping_bag_outlined,
              children: [
                _buildRow(
                  "Acheteur :",
                  "${recu.nomAcheteur} (${recu.numeroAgrement})",
                ),
                _buildRow(
                  "Pisteur :",
                  "${recu.nomPisteur} (${recu.contactPisteur})",
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Producteu
            _SectionCard(
              title: "Producteur",
              icon: Icons.person_pin_circle_outlined,
              children: [
                _buildRow("Producteur :", recu.nomProducteur),
                _buildRow("Village :", recu.villageProducteur),
                _buildRow("Contact :", recu.contactProducteur),
              ],
            ),
            const SizedBox(height: 16),

            // Informations d’acha
            _SectionCard(
              title: "Informations d’achat",
              icon: Icons.science_outlined,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildText(
                      "Sachets achetés",
                      recu.nbSacsAchetes.toString(),
                    ),
                    _buildText(
                      "Sacs remboursés",
                      recu.nbSacsRembourses.toString(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildRow("Poids :", FormatHelper.formatPoids(recu.poidsTotal)),
                _buildRow(
                  "Prix unitaire :",
                  "${FormatHelper.formatMontant(recu.prixUnitaire)} F",
                ),
                _buildRow(
                  "Valeur :",
                  FormatHelper.formatMontantFcfa(recu.valeurTotale),
                  isBold: true,
                  color: primaryColor,
                ),
                _buildRow(
                  "Montant payé :",
                  FormatHelper.formatMontantFcfa(recu.montantPaye),
                  isBold: true,
                  color: primaryColor,
                  fontsize: 16,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Photo du reç
            _SectionCard(
              title: "Photo du reçu",
              icon: Icons.photo_outlined,
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade400),
                    image: recu.image != null
                        ? DecorationImage(
                            image: NetworkImage(recu.image!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: recu.image == null
                      ? Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: Colors.grey.shade500,
                            size: 50,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
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
        SizedBox(height: 15),
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
