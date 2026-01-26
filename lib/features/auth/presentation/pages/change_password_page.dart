import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/route_constants.dart';
import '../bloc/change_password_bloc.dart';
import '../bloc/login_bloc.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Changement de mot de passe"),
        centerTitle: true,
        automaticallyImplyLeading: false, // Prevent going back without changing
      ),
      body: BlocListener<ChangePasswordBloc, ChangePasswordState>(
        listener: (context, state) {
          if (state is ChangePasswordLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is ChangePasswordFailure) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ChangePasswordSuccess) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Mot de passe changé avec succès !"),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate to Home
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteConstants.home,
              (route) => false,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Image.asset("assets/images/logo.png"),
                    ),
                  ],
                ),
                const Text(
                  "Vous devez changer votre mot de passe pour continuer.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Nouveau mot de passe",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer un nouveau mot de passe";
                    }
                    if (value.length < 4) {
                      return "Le mot de passe doit contenir au moins 4 caractères";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Confirmer le mot de passe",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return "Les mots de passe ne correspondent pas";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              // Get User ID from LoginBloc
                              final loginState = context
                                  .read<LoginBloc>()
                                  .state;
                              if (loginState is LoginSuccess) {
                                context.read<ChangePasswordBloc>().add(
                                  ChangePasswordSubmitted(
                                    userId: loginState.user.id,
                                    newPassword: _newPasswordController.text,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Erreur: Utilisateur non trouvé.",
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Changer le mot de passe"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
