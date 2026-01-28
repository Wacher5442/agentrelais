import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agent_relais/features/home/bloc/home_bloc.dart';
import 'package:agent_relais/features/transfert/data/datasources/local/transfert_local_datasource.dart';
import 'package:agent_relais/features/auth/presentation/bloc/login_bloc.dart';
import 'package:agent_relais/core/db/db_helper.dart';

import 'dashboard/agent_dashboard.dart';
import 'dashboard/prestataire_dashboard.dart';

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
            String role = "Agent";
            if (loginState is LoginSuccess) {
              userName =
                  "${loginState.user.firstName} ${loginState.user.lastName}";
              role = loginState.user.roles.isNotEmpty
                  ? loginState.user.roles.first.name
                  : "Agent";

              return BlocProvider(
                create: (context) => HomeBloc(
                  localDataSource: TransfertLocalDataSourceImpl(
                    DbHelper.instance,
                  ),
                )..add(LoadHomeStats()),
                child: _buildRoleView(role, loginState),
              );
            }
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoleView(String role, LoginSuccess state) {
    switch (role) {
      case "Prestataire":
        return PrestataireDashboard(userName: state.user.firstName, role: role);
      case "Agent":
      default:
        return AgentRelaisDashboard(userName: state.user.firstName, role: role);
    }
  }
}
