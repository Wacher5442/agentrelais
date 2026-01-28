import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/route_constants.dart';
import '../../bloc/home_bloc.dart';
import '../../widgets/header_card.dart';
import '../../widgets/home_card.dart';

class AcheteurDashboard extends StatelessWidget {
  final String userName;
  final String role;

  const AcheteurDashboard({
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

                // Chargements
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, RouteConstants.loadingList);
                  },
                  child: HomeCards(
                    title: "Chargements",
                    subtitle: "Liste des chargements en attente",
                    icon: Icons.upload_file,
                    iconColor: Colors.white,
                    cardColor: primaryColor,
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

                // Déchargements
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, RouteConstants.unloadingList);
                  },
                  child: HomeCards(
                    title: "Déchargements",
                    subtitle: "Liste des déchargements",
                    icon: Icons.download,
                    iconColor: Colors.white,
                    cardColor: const Color(
                      0xFFE5BE01,
                    ), // Gold color probably suitable
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
              ],
            ),
          );
        },
      ),
    );
  }
}
