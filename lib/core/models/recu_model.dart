class Recu {
  final String numeroRecu;
  final String date;
  final String departement;
  final String sousPrefecture;
  final String village;
  final String numeroAgrement;
  final String nomAcheteur;
  final String nomPisteur;
  final String contactPisteur;
  final String nomProducteur;
  final String villageProducteur;
  final String contactProducteur;
  final int nbSacsAchetes;
  final int nbSacsRembourses;
  final double poidsTotal;
  final double prixUnitaire;
  final double valeurTotale;
  final double montantPaye;
  final String? image;
  final String status;

  Recu({
    required this.numeroRecu,
    required this.date,
    required this.departement,
    required this.sousPrefecture,
    required this.village,
    required this.numeroAgrement,
    required this.nomAcheteur,
    required this.nomPisteur,
    required this.contactPisteur,
    required this.nomProducteur,
    required this.villageProducteur,
    required this.contactProducteur,
    required this.nbSacsAchetes,
    required this.nbSacsRembourses,
    required this.poidsTotal,
    required this.prixUnitaire,
    required this.valeurTotale,
    required this.montantPaye,
    this.image,
    this.status = "En attente",
  });

  factory Recu.fromJson(Map<String, dynamic> json) {
    return Recu(
      numeroRecu: json["numeroRecu"],
      date: json["date"],
      departement: json["departement"],
      sousPrefecture: json["sousPrefecture"],
      village: json["village"],
      numeroAgrement: json["numeroAgrement"],
      nomAcheteur: json["nomAcheteur"],
      nomPisteur: json["nomPisteur"],
      contactPisteur: json["contactPisteur"],
      nomProducteur: json["nomProducteur"],
      villageProducteur: json["villageProducteur"],
      contactProducteur: json["contactProducteur"],
      nbSacsAchetes: json["nbSacsAchetes"],
      nbSacsRembourses: json["nbSacsRembourses"],
      poidsTotal: json["poidsTotal"].toDouble(),
      prixUnitaire: json["prixUnitaire"].toDouble(),
      valeurTotale: json["valeurTotale"].toDouble(),
      montantPaye: json["montantPaye"].toDouble(),
      image: json["image"],
      status: json["status"],
    );
  }
}
