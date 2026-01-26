import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/route_constants.dart';
import '../../core/widgets/button_widget.dart';
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
        appBar: AppBar(title: Text("Profil")),
        body: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            String name = "Guest";
            String code = "N/A";
            String location = "N/A";

            if (state is LoginSuccess) {
              name = "${state.user.firstName} ${state.user.lastName}";
              code = state.user.agentCode ?? "N/A";
              // We don't have location in user entity directly unless stored in metadata?
              // assuming user has it or we hardcode for now
              location = "Côte d'Ivoire";
            }

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.symmetric(horizontal: 19, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileHeaderCard(
                    user: name,
                    subtitle: code,
                    location: location,
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
                    icon: Icons.info_outline,
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
                    onPressed: () {
                      context.read<LoginBloc>().add(LogoutRequested());
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
