import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/widgets/button_widget.dart';

class ConfirmationPage extends StatelessWidget {
  const ConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 0),
            child: Column(
              children: [
                SizedBox(height: 20),
                Center(child: Image.asset("assets/images/logo.png")),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 370,
                  decoration: BoxDecoration(
                    color: greenSection,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Icon(Icons.check),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 100,
                          vertical: 10,
                        ),
                        child: Text(
                          "Reçu enregistré avec succès !",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: greenSecondary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                        child: Text(
                          "Votre reçu bord champ a été enregistré dans le système.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(right: 20, left: 20, top: 30),
                        decoration: BoxDecoration(
                          color: Color(0XFFB4D9C6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Icon(Icons.cloud_outlined, color: greenSecondary),
                              Text(
                                "Reçu transmis au système SND",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: greenSecondary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),

                              Text(
                                "Reçu transmis au système SND",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: greenSecondary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 55,
                    vertical: 40,
                  ),
                  child: CustomButton(
                    buttonColor: primaryColor,
                    text: "Retourner",
                    textColor: Colors.white,
                    height: 50,
                    onPressed: () async {
                      Navigator.pushNamed(context, RouteConstants.home);
                    },
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
