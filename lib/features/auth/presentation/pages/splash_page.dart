import 'package:agent_relais/features/auth/presentation/bloc/login_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/route_constants.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Wait a bit to show the splash screen
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Trigger auth check
    context.read<LoginBloc>().add(CheckAuthStatus());

    // Wait for the auth check result
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final state = context.read<LoginBloc>().state;

    if (state is LoginSuccess) {
      // User is authenticated, go to home
      Navigator.pushReplacementNamed(context, RouteConstants.home);
    } else {
      // No valid session, go to login
      Navigator.pushReplacementNamed(context, RouteConstants.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo.png", height: 100),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Color(0xFF0E8446)),
          ],
        ),
      ),
    );
  }
}
