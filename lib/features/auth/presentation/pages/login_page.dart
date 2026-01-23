import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(),
      body: Stack(
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
                              } else if (value.length < 4) {
                                return "Le code ne peut être inférieur à 4 chiffres";
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

                    CustomButton(
                      buttonColor: primaryColor,
                      text: "Se connecter",
                      textColor: Colors.white,
                      onPressed: () async {
                        Navigator.pushNamed(context, RouteConstants.home);
                        // if (_formKey.currentState?.validate() ?? false) {
                        //   Navigator.pushNamed(context, RouteConstants.home);
                        // } else {
                        //   setState(() {});
                        //   CustomSnackbar.showError(
                        //     context,
                        //     "Veuillez renseigner les champs obligatoire",
                        //   );
                        // }
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
    );
  }

  final _formKey = GlobalKey<FormState>();
}
