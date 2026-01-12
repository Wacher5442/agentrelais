import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/route_constants.dart';

class HeaderCard extends StatelessWidget {
  final String user;
  final String subtitle;

  const HeaderCard({super.key, required this.user, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: AssetImage("assets/images/background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bienvenue, $user",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, RouteConstants.profil);
              },
              child: Text(
                "Bouaké",
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ),
          Positioned(
            bottom: 35,
            right: 35,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, RouteConstants.profil);
              },
              child: Icon(Icons.person_outline, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
