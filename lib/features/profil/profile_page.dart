import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/route_constants.dart';
import '../../core/widgets/button_widget.dart';
import '../home/bloc/home_bloc.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/stats_card.dart';
import 'package:agent_relais/features/auth/presentation/bloc/login_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // On rafraîchit les stats au chargement de la page
    context.read<HomeBloc>().add(LoadHomeStats());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginInitial) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteConstants.login,
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(automaticallyImplyLeading: false),
        body: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, loginState) {
            String name = "Guest";
            String code = "N/A";
            String location = "Côte d'Ivoire";
            String role = "agent";
            String campagne = "N/A";

            if (loginState is LoginSuccess) {
              name = "${loginState.user.firstName} ${loginState.user.lastName}";
              code = loginState.user.agentCode ?? "N/A";
              role = loginState.user.roles.first.name ?? "agent";
              campagne = loginState.campagne;
            }

            // On imbrique le HomeBloc pour récupérer les stats
            return BlocBuilder<HomeBloc, HomeState>(
              builder: (context, homeState) {
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 19,
                    vertical: 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileHeaderCard(
                        user: name,
                        subtitle: code,
                        location: location,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Mes informations",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Affichage dynamique des stats selon le rôle
                      if (role.toLowerCase() == "agent")
                        StatsCard(
                          icon: Icons.emoji_events_outlined,
                          title: "Statistiques",
                          items: {
                            "Fiches totale :": homeState.addedCount,
                            "Fiches synchronisées :": homeState.syncedCount,
                          },
                        ),

                      if (role == "Prestataire")
                        StatsCard(
                          icon: Icons.emoji_events_outlined,
                          title: "Statistiques",
                          items: {
                            "Fiches totale :": 1,
                            "Fiches validées :": 1,
                            "En attente :": 10,
                          },
                        ),

                      const SizedBox(height: 20),
                      StatsCard(
                        icon: Icons.info_outline,
                        title: "Information application",
                        items: {
                          "Version :": "1.0.0",
                          "Dernière synchro :":
                              "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute}",
                          "Statut :": "Connecté au SND",
                          "Campagne active :": campagne,
                        },
                      ),
                      const SizedBox(height: 20),

                      // Section Commodité (si applicable)
                      if (loginState is LoginSuccess &&
                          loginState.commodities.isNotEmpty) ...[
                        // ... (ton code de dropdown reste identique)
                      ],

                      const SizedBox(height: 40),
                      CustomButton(
                        buttonColor: Colors.red,
                        text: "Déconnecter",
                        textColor: Colors.white,
                        onPressed: () {
                          context.read<LoginBloc>().add(LogoutRequested());
                        },
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
