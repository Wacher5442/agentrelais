import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../auth/presentation/bloc/login_bloc.dart';
import '../bloc/sync_bloc.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  @override
  void initState() {
    super.initState();
    _checkRoleAndSync();
  }

  void _checkRoleAndSync() {
    // Check if user is an agent before syncing
    final loginBloc = context.read<LoginBloc>();
    final loginState = loginBloc.state;

    if (loginState is LoginSuccess) {
      final userRole = loginState.user.roles.isNotEmpty
          ? loginState.user.roles.first.name
          : '';

      // Only agents should sync, others go directly to home
      if (userRole.toLowerCase() != 'agent') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, RouteConstants.home);
        });
        return;
      }
    }

    // Start sync for agents
    context.read<SyncBloc>().add(const SyncStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<SyncBloc, SyncState>(
        listener: (context, state) {
          if (state is SyncSuccess) {
            Navigator.pushReplacementNamed(context, RouteConstants.home);
          }
        },
        builder: (context, state) {
          String message = "Préparation...";
          double progress = 0;

          if (state is SyncInProgress) {
            message = state.message;
            progress = state.progress;
          } else if (state is SyncFailure) {
            bool isNoInternet = state.message.contains(
              "connexion",
            ); // Détection simple

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isNoInternet
                          ? Icons.wifi_off_rounded
                          : Icons.cloud_off_rounded,
                      size: 80,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isNoInternet ? "Hors ligne" : "Erreur Serveur",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<SyncBloc>().add(const SyncStarted()),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        "RÉESSAYER",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E8446),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/logo.png", height: 80),
                const SizedBox(height: 50),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  color: const Color(0xFF0E8446),
                  minHeight: 10,
                ),
                const SizedBox(height: 10),
                Text("${(progress * 100).toInt()}%"),
              ],
            ),
          );
        },
      ),
    );
  }
}
