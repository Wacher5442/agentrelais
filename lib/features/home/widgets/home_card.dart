import 'package:agent_relais/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeCards extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color cardColor;
  final Color iconColor;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;
  final bool isTrailing;
  const HomeCards({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.cardColor = Colors.transparent,
    this.iconColor = greenSecondary,
    this.isTrailing = false,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
  }) : titleStyle = titleStyle ?? const TextStyle(),
       subtitleStyle = subtitleStyle ?? const TextStyle();

  @override
  Widget build(BuildContext context) {
    final effectiveTitleStyle = titleStyle.fontSize == null
        ? GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          )
        : titleStyle;

    final effectiveSubtitleStyle = subtitleStyle.fontSize == null
        ? GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          )
        : subtitleStyle;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1, color: Colors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: effectiveTitleStyle),
                  const SizedBox(height: 5),
                  Text(subtitle, style: effectiveSubtitleStyle),
                ],
              ),
            ),
            if (isTrailing) Icon(Icons.chevron_right, color: iconColor),
          ],
        ),
      ),
    );
  }
}
