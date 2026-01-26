import 'package:agent_relais/features/auth/presentation/bloc/login_bloc.dart';
import 'package:agent_relais/core/widgets/custom_snackbar.dart';
import 'package:agent_relais/features/reference_data/presentation/bloc/sync_bloc.dart';
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
  final TextEditingController regionController = TextEditingController(
    text: '',
  );

  bool passwordVisible = false;
  bool showEye = false;

  void togglePassword() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  final _formKey = GlobalKey<FormState>();

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
              Navigator.pushReplacementNamed(context, RouteConstants.home);
            }
          } else if (state is LoginFailure) {
            CustomSnackbar.showError(context, state.message);
          }
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () {},
                            child: Image.asset("assets/images/logo.png"),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Connexion",
                            style: GoogleFonts.poppins(
                              fontSize: 35,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Text(
                              "Accédez facilement à votre espace personnel afin de gérer vos affaires.",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 48),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            InputField(
                              hintText: "Code utilisateur",
                              label: "Code utilisateur",
                              suffixIcon: SizedBox(),
                              controller: usernameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Code utilisateur requis";
                                } else if (value.length < 3) {
                                  return "Le code ne peut être inférieur à 3 caractères";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 32),
                            InputField(
                              hintText: "Mot de passe",
                              label: "Mot de passe",
                              controller: passwordController,
                              obscureText: !passwordVisible,
                              onchange: (value) {
                                if (value.isNotEmpty) {
                                  setState(() {
                                    showEye = true;
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Mot de passe requis";
                                } else if (value.length < 4) {
                                  return "Le code ne peut être inférieur à 4 caractères";
                                }
                                return null;
                              },
                              suffixIcon: showEye
                                  ? IconButton(
                                      color: greyColor,
                                      splashRadius: 1,
                                      icon: Icon(
                                        passwordVisible
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                      onPressed: togglePassword,
                                    )
                                  : Text(''),
                            ),
                            SizedBox(height: 32),
                            InputField(
                              hintText: "Région",
                              label: "Région",
                              suffixIcon: SizedBox(),
                              controller: regionController,
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
                                context.read<LoginBloc>().add(
                                  LoginSubmitted(
                                    username: usernameController.text,
                                    password: passwordController.text,
                                    region: regionController.text,
                                  ),
                                );
                              } else {
                                CustomSnackbar.showError(
                                  context,
                                  "Veuillez renseigner les champs obligatoire",
                                );
                              }
                            },
                          );
                        },
                      ),

                      SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 45),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Vous n'avez pas de compte ?",
                              style: TextStyle(
                                fontFamily: 'FiraSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                // _getBatteryLevel();
                              },
                              child: Text(
                                "Contacter votre acheteur",
                                style: TextStyle(
                                  fontFamily: 'FiraSans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: secondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
