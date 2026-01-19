import 'package:agent_relais/core/constants/colors.dart';
import 'package:agent_relais/features/home/widgets/header_card.dart';
import 'package:agent_relais/features/home/widgets/home_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agent_relais/features/home/bloc/home_bloc.dart';
import 'package:agent_relais/features/transfert/data/datasources/local/transfert_local_datasource.dart';
import 'package:agent_relais/core/db/db_helper.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/models/recu_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController(
    text: '',
  );

  String? selectedValue;

  final List<String> items = ["Tous les magasins", "Option 2", "Option 3"];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        localDataSource: TransfertLocalDataSourceImpl(DbHelper.instance),
      )..add(LoadHomeStats()),
      child: Scaffold(
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.symmetric(horizontal: 19, vertical: 70),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HeaderCard(
                    user: "Kouassi Jean",
                    subtitle: "Parcours Agent Relais",
                  ),
                  const SizedBox(height: 15),
                  HomeCards(
                    title: "Fiches ajoutées",
                    subtitle: "${state.addedCount}",
                    icon: Icons.receipt_long_rounded,
                    iconColor: Colors.black,
                  ),
                  const SizedBox(height: 15),
                  HomeCards(
                    title: "Fiches synchronisées",
                    subtitle: "${state.syncedCount}",
                    icon: Icons.check_circle,
                  ),
                  // const SizedBox(height: 15),
                  // HomeCards(
                  //   title: "Entrepôts à valider",
                  //   subtitle: "10",
                  //   icon: Icons.storefront_outlined,
                  //   iconColor: Colors.black,
                  // ),
                  const SizedBox(height: 20),
                  Text(
                    "Accès rapide",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 15),
                  InkWell(
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        RouteConstants.transfert,
                      );
                      // Refresh stats when returning
                      if (context.mounted) {
                        context.read<HomeBloc>().add(LoadHomeStats());
                      }
                    },
                    child: HomeCards(
                      title: "Demandes de transfert",
                      subtitle: "Vérifier les fiches de transfert",
                      icon: Icons.receipt_long_rounded,
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
                  InkWell(
                    // onTap: () {
                    //   Navigator.pushNamed(context, RouteConstants.addTransfert);
                    // },
                    child: HomeCards(
                      title: "Déclaration d’entrepôts",
                      subtitle: "Valider les entrepôts",
                      icon: Icons.storefront_outlined,
                      iconColor: Colors.white,
                      cardColor: redColor,
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
      ),
    );
  }

  List<Recu> receipts = [];
  final List<String> statuses = ['En attente', 'Validé', 'Rejeté'];
  @override
  void initState() {
    super.initState();
    receipts = List.generate(5, (index) {
      final randomStatus = statuses[index % statuses.length];

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
        "status": randomStatus,
      };
      return Recu.fromJson(data);
    });
  }
}
