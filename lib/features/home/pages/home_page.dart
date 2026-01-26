import 'package:agent_relais/core/constants/colors.dart';
import 'package:agent_relais/features/home/widgets/header_card.dart';
import 'package:agent_relais/features/home/widgets/home_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agent_relais/features/home/bloc/home_bloc.dart';
import 'package:agent_relais/features/transfert/data/datasources/local/transfert_local_datasource.dart';
import 'package:agent_relais/features/auth/presentation/bloc/login_bloc.dart';
import 'package:agent_relais/core/db/db_helper.dart';

import '../../../core/constants/route_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Check Auth Status on Init
    context.read<LoginBloc>().add(CheckAuthStatus());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        localDataSource: TransfertLocalDataSourceImpl(DbHelper.instance),
      )..add(LoadHomeStats()),
      child: Scaffold(
        body: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, loginState) {
            String userName = "Utilisateur";
            String role = "Agent Relais";
            if (loginState is LoginSuccess) {
              userName =
                  "${loginState.user.firstName} ${loginState.user.lastName}";
              role = loginState.user.roles.isNotEmpty
                  ? loginState.user.roles.first.name
                  : "Agent Relais";
            }

            return BlocBuilder<HomeBloc, HomeState>(
              builder: (context, homeState) {
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.symmetric(horizontal: 19, vertical: 70),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeaderCard(user: userName, subtitle: role),
                      const SizedBox(height: 15),
                      HomeCards(
                        title: "Fiches ajoutées",
                        subtitle: "${homeState.addedCount}",
                        icon: Icons.receipt_long_rounded,
                        iconColor: Colors.black,
                      ),
                      const SizedBox(height: 15),
                      HomeCards(
                        title: "Fiches synchronisées",
                        subtitle: "${homeState.syncedCount}",
                        icon: Icons.check_circle,
                      ),

                      // Example Role Based Visibility
                      if (role == "CONTROLEUR" || role == "DELEGUE") ...[
                        const SizedBox(height: 15),
                        HomeCards(
                          title: "Fiches rejetées",
                          subtitle: "0",
                          icon: Icons.cancel,
                          iconColor: Colors.red,
                        ),
                      ],

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
            );
          },
        ),
      ),
    );
  }
}
