import 'package:agent_relais/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/models/recu_model.dart';
import '../../domain/entities/home_stats.dart';
import '../bloc/acheteur_home_bloc.dart';
import '../widgets/header_card.dart';
import '../widgets/home_card.dart';
import '../widgets/status_card.dart'; // Importez le BLoC

class AcheteurHomePage extends StatefulWidget {
  const AcheteurHomePage({super.key});

  @override
  State<AcheteurHomePage> createState() => _AcheteurHomePageState();
}

class _AcheteurHomePageState extends State<AcheteurHomePage> {
  final TextEditingController searchController = TextEditingController();
  String? selectedValue;

  // Modifié pour utiliser de vrais statuts pour le filtre
  final List<String> items = [
    "Tous les statuts",
    "Validé",
    "En attente",
    "Rejeté",
  ];

  @override
  void initState() {
    super.initState();
    // Déclenche le premier chargement des données
    context.read<AcheteurHomeBloc>().add(const AcheteurHomeDataFetched());
  }

  void _fetchData() {
    context.read<AcheteurHomeBloc>().add(
      AcheteurHomeDataFetched(
        search: searchController.text,
        filter: selectedValue == "Tous les statuts" ? null : selectedValue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeaderCard(
              user: "ASCACI SCOOPS",
              subtitle: "Parcours Acheteur",
            ),
            const SizedBox(height: 20),

            BlocBuilder<AcheteurHomeBloc, AcheteurHomeState>(
              builder: (context, state) {
                if (state is HomeLoading && state is! HomeLoaded) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  );
                }
                if (state is HomeError) {
                  return Center(child: Text(state.message));
                }
                if (state is HomeLoaded) {
                  return _buildHomeContent(
                    state.homeData.stats,
                    state.homeData.receipts,
                  );
                }
                // Initial ou autres états
                return const Center(child: Text("Chargement des données..."));
              },
            ),
            // ---- Fin du contenu BLoC ----
          ],
        ),
      ),
    );
  }

  /// Widget pour afficher le contenu une fois chargé
  Widget _buildHomeContent(HomeStats stats, List<Recu> receipts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;
            double spacing = 10;
            double itemWidth = (maxWidth - 2 * spacing) / 2;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                StatusCard(
                  icon: Icons.check_circle,
                  label: "Reçus",
                  color: Color(0xFF5D8BCC),
                  value: stats.valides, // Données du BLoC
                  width: itemWidth,
                ),
                StatusCard(
                  icon: Icons.timelapse_sharp,
                  label: "Magasins",
                  color: secondaryColor,
                  value: stats.enAttente, // Données du BLoC
                  width: itemWidth,
                ),
                StatusCard(
                  icon: Icons.cancel,
                  label: "Pisteurs",
                  color: Color(0xFF058B65),
                  value: stats.reclassifyes, // Données du BLoC
                  width: itemWidth,
                ),
                StatusCard(
                  icon: Icons.track_changes,
                  label: "Transferts",
                  color: Color(0xFFBA28D7),
                  value: stats.reclassifyes, // Données du BLoC
                  width: itemWidth,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          "Accès rapide",
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 15),

        InkWell(
          onTap: () {
            Navigator.pushNamed(context, RouteConstants.addReceipt);
          },
          child: HomeCards(
            title: "Mes reçus",
            subtitle: "",
            icon: Icons.receipt_long_rounded,
            subtitleStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),
        HomeCards(
          title: "Mes pisteurs",
          subtitle: "",
          icon: Icons.people,
          subtitleStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        HomeCards(
          title: "Mes magasins",
          subtitle: "",
          icon: Icons.store,
          subtitleStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, RouteConstants.transfert);
          },
          child: HomeCards(
            title: "Fiches de transfert",
            subtitle: "",
            icon: Icons.fire_truck,
            subtitleStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
