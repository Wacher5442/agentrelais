import 'dart:developer';

import 'package:agent_relais/features/auth/presentation/bloc/login_bloc.dart';
import 'package:agent_relais/core/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/widgets/button_widget.dart';
import '../../../../core/widgets/input_field.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController(
    text: '',
  );
  final TextEditingController passwordController = TextEditingController(
    text: '',
  );

  // Variables pour les nouveaux champs
  String? selectedUserType;
  String? selectedRegionCode;

  final List<String> userTypes = ['Agent', 'Prestataire', 'Acheteur'];

  // Liste des régions au format demandé
  final List<Map<String, String>> regionsList = [
    {"id": "1", "name": "Agnéby-Tiassa", "code": "1"},
    {"id": "2", "name": "Bafing", "code": "2"},
    {"id": "3", "name": "N'Zi", "code": "3"},
    {"id": "4", "name": "Bélier", "code": "4"},
    {"id": "5", "name": "Béré", "code": "5"},
    {"id": "6", "name": "Bounkani", "code": "6"},
    {"id": "7", "name": "Cavally", "code": "7"},
    {"id": "8", "name": "Folon", "code": "8"},
    {"id": "9", "name": "Gbeke", "code": "9"},
    {"id": "10", "name": "Gbokle", "code": "10"},
    {"id": "11", "name": "Goh", "code": "11"},
    {"id": "12", "name": "Gontougo", "code": "12"},
    {"id": "13", "name": "Grands-Ponts", "code": "13"},
    {"id": "14", "name": "Guémon", "code": "14"},
    {"id": "15", "name": "Hambol", "code": "15"},
    {"id": "16", "name": "Haut-Sassandra", "code": "16"},
    {"id": "17", "name": "Iffou", "code": "17"},
    {"id": "18", "name": "Indénié-Djuablin", "code": "18"},
    {"id": "19", "name": "Kabadougou", "code": "19"},
    {"id": "20", "name": "Bagoué", "code": "20"},
    {"id": "21", "name": "La Mé", "code": "21"},
    {"id": "22", "name": "Lôh-Djiboua", "code": "22"},
    {"id": "23", "name": "Marahoué", "code": "23"},
    {"id": "24", "name": "Mouronou", "code": "24"},
    {"id": "25", "name": "Nawa", "code": "25"},
    {"id": "26", "name": "Poro", "code": "26"},
    {"id": "27", "name": "San-Pédro", "code": "27"},
    {"id": "28", "name": "Sud-Comoé", "code": "28"},
    {"id": "29", "name": "Tchologo", "code": "29"},
    {"id": "30", "name": "Tonkpi", "code": "30"},
    {"id": "31", "name": "Worodougou", "code": "31"},
    {"id": "32", "name": "Ypala-Ouaré", "code": "32"},
  ];

  bool passwordVisible = false;
  bool showEye = false;

  void togglePassword() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  final _formKey = GlobalKey<FormState>();

  // Helper pour le style des Dropdowns pour matcher tes InputFields
  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(),
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            if (state.user.mustChangePassword) {
              Navigator.pushReplacementNamed(
                context,
                RouteConstants.changePassword,
              );
            } else {
              final userRole = state.user.roles.isNotEmpty
                  ? state.user.roles.first.name
                  : '';
              if (userRole.toLowerCase() == 'agent') {
                Navigator.pushReplacementNamed(context, RouteConstants.sync);
              } else {
                Navigator.pushReplacementNamed(context, RouteConstants.home);
              }
            }
          } else if (state is LoginFailure) {
            CustomSnackbar.showError(context, state.message);
          }
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset("assets/images/logo.png"),
                      SizedBox(height: 30),
                      Text(
                        "Connexion",
                        style: GoogleFonts.poppins(
                          fontSize: 35,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Accédez facilement à votre espace personnel afin de gérer vos affaires.",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 40),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // --- CHAMP TYPE UTILISATEUR ---
                            DropdownButtonFormField<String>(
                              value: selectedUserType,
                              decoration: _dropdownDecoration(
                                "Type d'utilisateur",
                              ),
                              items: userTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedUserType = value;
                                  if (value != 'Agent')
                                    selectedRegionCode = null;
                                });
                              },
                              validator: (value) =>
                                  value == null ? "Sélectionnez un type" : null,
                            ),

                            // --- CHAMP RÉGION (Affiché uniquement si Agent) ---
                            if (selectedUserType == 'Agent') ...[
                              SizedBox(height: 24),
                              DropdownButtonFormField<String>(
                                value: selectedRegionCode,
                                decoration: _dropdownDecoration("Région"),
                                items: regionsList.map((region) {
                                  return DropdownMenuItem(
                                    value: region['code'],
                                    child: Text(region['name']!),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedRegionCode = value;
                                  });
                                },
                                validator: (value) => value == null
                                    ? "Sélectionnez une région"
                                    : null,
                              ),
                            ],

                            SizedBox(height: 24),
                            InputField(
                              hintText: "Code utilisateur",
                              label: "Code utilisateur",
                              suffixIcon: SizedBox(),
                              controller: usernameController,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return "Code utilisateur requis";
                                return null;
                              },
                            ),
                            SizedBox(height: 24),
                            InputField(
                              hintText: "Mot de passe",
                              label: "Mot de passe",
                              controller: passwordController,
                              obscureText: !passwordVisible,
                              onchange: (value) {
                                if (value.isNotEmpty)
                                  setState(() => showEye = true);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return "Mot de passe requis";
                                return null;
                              },
                              suffixIcon: showEye
                                  ? IconButton(
                                      color: greyColor,
                                      icon: Icon(
                                        passwordVisible
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                      onPressed: togglePassword,
                                    )
                                  : Text(''),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 50),
                      BlocBuilder<LoginBloc, LoginState>(
                        builder: (context, state) {
                          if (state is LoginLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return CustomButton(
                            buttonColor: primaryColor,
                            text: "Se connecter",
                            textColor: Colors.white,
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                log("region: $selectedRegionCode");
                                context.read<LoginBloc>().add(
                                  LoginSubmitted(
                                    username: usernameController.text,
                                    password: passwordController.text,
                                    // On envoie le code de la région ou vide si pas agent
                                    region: selectedRegionCode ?? "20",
                                  ),
                                );
                              } else {
                                CustomSnackbar.showError(
                                  context,
                                  "Veuillez remplir tous les champs",
                                );
                              }
                            },
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Vous n'avez pas de compte ?",
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              "Contacter votre acheteur",
                              style: TextStyle(
                                fontSize: 14,
                                color: secondaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
