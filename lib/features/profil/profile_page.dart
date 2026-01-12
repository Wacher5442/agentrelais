import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models/recu_model.dart';
import '../../core/constants/route_constants.dart';
import '../../core/widgets/button_widget.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/stats_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.symmetric(horizontal: 19, vertical: 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileHeaderCard(
              user: "Kouassi Jean",
              subtitle: "AG-CCA-2025",
              location: "Bouaké",
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Mes informations",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            StatsCard(
              icon: Icons.emoji_events_outlined,
              title: "Statistiques",
              items: const {
                "Validation totale :": 25,
                "Fiches validées :": 18,
                "Entrepôts validés :": 7,
                "En attente :": 7,
              },
            ),
            const SizedBox(height: 20),
            StatsCard(
              icon: Icons.emoji_events_outlined,
              title: "Information application",
              items: const {
                "Version :": "1.0.5",
                "Dernière synchro :": "16/05/25 10:30",
                "Statut :": "Connecté au SND",
              },
            ),
            const SizedBox(height: 40),
            CustomButton(
              buttonColor: Colors.red,
              text: "Déconnecter",
              textColor: Colors.white,
              onPressed: () async {
                Navigator.pushNamed(context, RouteConstants.login);
              },
            ),
          ],
        ),
      ),
    );
  }

  final List<Recu> receipts = List.generate(5, (index) {
    final data = {
      "numeroRecu": "R-${1000 + index}",
      "date": "2025-09-${10 + index}",
      "departement": "Korhogo",
      "sousPrefecture": "Sinématiali",
      "village": "Village ${index + 1}",
      "numeroAgrement": "AG-${200 + index}",
      "nomAcheteur": "Acheteur ${index + 1}",
      "nomPisteur": "Pisteur ${index + 1}",
      "contactPisteur": "07 00 00 0${index + 1}",
      "nomProducteur": "Producteur ${index + 1}",
      "villageProducteur": "Village Prod ${index + 1}",
      "contactProducteur": "05 00 00 0${index + 1}",
      "nbSacsAchetes": 10 + index,
      "nbSacsRembourses": index,
      "poidsTotal": (10 + index) * 65,
      "prixUnitaire": 1500 + (index * 100),
      "valeurTotale": (10 + index) * (1500 + (index * 100)),
      "montantPaye": ((10 + index) * (1500 + (index * 100))) - 2000,
      "image": null,
      "status": "En attente",
    };
    return Recu.fromJson(data);
  });
}
