import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../bloc/home_bloc.dart';
import '../../widgets/header_card.dart';
import '../../widgets/home_card.dart';

class AgentRelaisDashboard extends StatelessWidget {
  final String userName;
  final String role;

  const AgentRelaisDashboard({
    super.key,
    required this.userName,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, homeState) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 70),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec les infos utilisateur passées en paramètres
                HeaderCard(user: userName, subtitle: role),
                const SizedBox(height: 15),

                // Statistiques de base - Clickable
                InkWell(
                  onTap: () async {
                    // Navigate to all fiches (no filter)
                    await Navigator.pushNamed(
                      context,
                      RouteConstants.transfert,
                    );
                    if (context.mounted) {
                      context.read<HomeBloc>().add(LoadHomeStats());
                    }
                  },
                  child: HomeCards(
                    title: "Fiches ajoutées",
                    subtitle: "${homeState.addedCount}",
                    icon: Icons.receipt_long_rounded,
                    iconColor: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                InkWell(
                  onTap: () async {
                    // Navigate to synchronized fiches only
                    await Navigator.pushNamed(
                      context,
                      RouteConstants.transfert,
                      arguments: {'statusFilter': 'synchronisé'},
                    );
                    if (context.mounted) {
                      context.read<HomeBloc>().add(LoadHomeStats());
                    }
                  },
                  child: HomeCards(
                    title: "Fiches synchronisées",
                    subtitle: "${homeState.syncedCount}",
                    icon: Icons.check_circle,
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  "Accès rapide",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 15),

                // Bouton Demandes de transfert
                InkWell(
                  onTap: () async {
                    await Navigator.pushNamed(
                      context,
                      RouteConstants.transfert,
                    );
                    if (context.mounted) {
                      context.read<HomeBloc>().add(LoadHomeStats());
                    }
                  },
                  child: HomeCards(
                    title: "Demandes de transfert",
                    subtitle: "Vérifier les fiches de transfert",
                    icon: Icons.receipt_long_rounded,
                    iconColor: Colors.white,
                    cardColor:
                        primaryColor, // Assurez-vous que primaryColor est accessible
                    isTrailing: true,
                    titleStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    subtitleStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Bouton Déclaration d'entrepôts
                InkWell(
                  onTap: () {
                    // Action future ici
                  },
                  child: HomeCards(
                    title: "Déclaration d’entrepôts",
                    subtitle: "Valider les entrepôts",
                    icon: Icons.storefront_outlined,
                    iconColor: Colors.white,
                    cardColor:
                        redColor, // Assurez-vous que redColor est accessible
                    isTrailing: true,
                    titleStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    subtitleStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Historique
                HomeCards(
                  title: "Historique des validations",
                  subtitle: "Consulter l'historique",
                  icon: Icons.history,
                  subtitleStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
