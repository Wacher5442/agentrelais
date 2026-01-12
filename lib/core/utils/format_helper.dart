import 'package:intl/intl.dart';

class FormatHelper {
  /// Formate un nombre avec les séparateurs de milliers (ex: 150 000)
  static String formatMontant(num montant, {String locale = 'fr_FR'}) {
    final format = NumberFormat.decimalPattern(locale);
    return format.format(montant);
  }

  /// Formate un poids (en KG)
  static String formatPoids(num poids) {
    return '${formatMontant(poids)} KG';
  }

  /// Formate un montant avec la devise FCFA
  static String formatMontantFcfa(num montant) {
    return '${formatMontant(montant)} FCFA';
  }

  static String formatToJmmaaaa({DateTime? date}) {
    final d = date ?? DateTime.now();

    final jour = d.day.toString().padLeft(2, '0');
    final mois = d.month.toString().padLeft(2, '0');
    final annee = d.year.toString().substring(2); // 2 derniers chiffres

    return "$jour$mois$annee";
  }
}
