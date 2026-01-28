import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agent_relais/core/constants/colors.dart';
import '../../../../core/widgets/full_image_widget.dart';
import '../../domain/entities/transfert_entity.dart';

class TransfertDetailPage extends StatelessWidget {
  final TransfertEntity transfert;

  const TransfertDetailPage({super.key, required this.transfert});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        centerTitle: false,
        title: Text(
          'Détails de la fiche',
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
            // Header Card
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
                        'Fiche #${transfert.numeroFiche}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (transfert.typeTransfert != null)
                        Text(
                          'Type : ${transfert.typeTransfert}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const SizedBox(height: 10),
                      const Divider(),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(transfert.status),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      _getStatusLabel(transfert.status),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Informations générales
            if (transfert.date != null || transfert.sticker != null)
              _SectionCard(
                title: "Informations générales",
                icon: Icons.info_outline,
                children: [
                  if (transfert.date != null)
                    _buildRow("Date :", transfert.date!),
                  if (transfert.sticker != null)
                    _buildRow("Sticker :", transfert.sticker!),
                  _buildRow("Campagne :", transfert.campagne),
                ],
              ),
            if (transfert.date != null || transfert.sticker != null)
              const SizedBox(height: 16),

            // Localisation
            _SectionCard(
              title: "Localisation",
              icon: Icons.location_on_outlined,
              children: [
                if (transfert.region != null)
                  _buildRow("Région :", transfert.region!),
                if (transfert.departement != null)
                  _buildRow("Département :", transfert.departement!),
                if (transfert.sousPrefecture != null)
                  _buildRow("Sous-préfecture :", transfert.sousPrefecture!),
                if (transfert.village != null)
                  _buildRow("Village :", transfert.village!),
              ],
            ),
            const SizedBox(height: 16),

            // Destination et Acheteur
            _SectionCard(
              title: "Destination et Acheteur",
              icon: Icons.shopping_bag_outlined,
              children: [
                if (transfert.destinationVille != null)
                  _buildRow("Destination :", transfert.destinationVille!),
                if (transfert.destinateur != null)
                  _buildRow("Destinataire :", transfert.destinateur!),
                if (transfert.acheteur != null)
                  _buildRow("Acheteur :", transfert.acheteur!),
                if (transfert.contactAcheteur != null)
                  _buildRow("Contact :", transfert.contactAcheteur!),
                if (transfert.codeAcheteur != null)
                  _buildRow("Code :", transfert.codeAcheteur!),
                if (transfert.nomMagasin != null)
                  _buildRow("Magasin :", transfert.nomMagasin!),
              ],
            ),
            const SizedBox(height: 16),

            // Informations de transport
            if (transfert.nomTransporteur != null ||
                transfert.nomChauffeur != null)
              _SectionCard(
                title: "Transport",
                icon: Icons.local_shipping_outlined,
                children: [
                  if (transfert.nomTransporteur != null)
                    _buildRow("Transporteur :", transfert.nomTransporteur!),
                  if (transfert.contactTransporteur != null)
                    _buildRow("Contact :", transfert.contactTransporteur!),
                  if (transfert.marqueCamion != null)
                    _buildRow("Marque camion :", transfert.marqueCamion!),
                  if (transfert.immatriculation != null)
                    _buildRow("Immatriculation :", transfert.immatriculation!),
                  if (transfert.remorque != null)
                    _buildRow("Remorque :", transfert.remorque!),
                  if (transfert.nomChauffeur != null)
                    _buildRow("Chauffeur :", transfert.nomChauffeur!),
                  if (transfert.permisConduire != null)
                    _buildRow("Permis :", transfert.permisConduire!),
                ],
              ),
            if (transfert.nomTransporteur != null ||
                transfert.nomChauffeur != null)
              const SizedBox(height: 16),

            // Détails du chargement
            _SectionCard(
              title: "Détails du chargement",
              icon: Icons.inventory_outlined,
              children: [
                if (transfert.sacs != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildText("Nombre de sacs", transfert.sacs!),
                      if (transfert.poids != null)
                        _buildText("Poids", "${transfert.poids!} Kg"),
                    ],
                  ),
                if (transfert.sacs != null) const SizedBox(height: 8),
                if (transfert.denomination != null)
                  _buildRow("Dénomination :", transfert.denomination!),
                if (transfert.thDepart != null)
                  _buildRow("TH Départ :", transfert.thDepart!),
                if (transfert.prix != null)
                  _buildRow(
                    "Prix :",
                    "${transfert.prix!} F",
                    isBold: true,
                    color: primaryColor,
                    fontsize: 16,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Photo de la fiche
            if (transfert.image != null)
              _SectionCard(
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
                      imagePath: transfert.image!,
                      borderRadius: 10,
                      tag:
                          'receipt_${transfert.numeroFiche}-${transfert.image}',
                    ),
                  ),
                ],
              ),
            if (transfert.image != null) const SizedBox(height: 16),

            // Photos des reçus
            if (transfert.receipts.isNotEmpty)
              _SectionCard(
                title: "Reçus (${transfert.receipts.length})",
                icon: Icons.receipt_outlined,
                children: [
                  ...transfert.receipts.map((receipt) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reçu #${receipt.receiptNumber}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: ClipRRectImage(
                            imagePath: receipt.imagePath,
                            borderRadius: 10,
                            tag:
                                'receipt_${receipt.receiptNumber}-${receipt.imagePath}',
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }).toList(),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'synchronisé':
        return Colors.green;
      case 'en_attente':
        return Colors.orange;
      case 'draft':
        return Colors.grey;
      case 'echec':
        return Colors.red;
      case 'envoyé_ussd':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'synchronisé':
        return 'Synchronisé';
      case 'en_attente':
        return 'En attente';
      case 'draft':
        return 'Brouillon';
      case 'echec':
        return 'Échec';
      case 'envoyé_ussd':
        return 'Envoyé USSD';
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

// Widget helper to display images (local files or network URLs)
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
    final isNetworkImage =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');

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
          child: isNetworkImage
              ? Image.network(
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
                )
              : Image.file(
                  File(imagePath),
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
                ),
        ),
      ),
    );
  }
}
