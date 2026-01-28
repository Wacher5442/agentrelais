class ReceiptFormData {
  String? numeroRecu;
  String? campagne;
  String? date;
  String? departement;
  String? sousPrefecture;
  String? village;
  String? numeroAgrement;
  String? nomAcheteur;
  String? nomPisteur;
  String? contactPisteur;
  String? nomProducteur;
  String? villageProducteur;
  String? contactProducteur;
  String? nbSacsAchetes;
  String? nbSacsRembourses;
  String? poidsTotal;
  String? prixUnitaire;
  String? valeurTotale;
  String? montantPaye;
  String? photoPath;
  String? agentId;

  ReceiptFormData();

  Map<String, dynamic> toJson() => {
    'numeroRecu': numeroRecu,
    'campagne': campagne,
    'date': date,
    'departement': departement,
    'sousPrefecture': sousPrefecture,
    'village': village,
    'numeroAgrement': numeroAgrement,
    'nomAcheteur': nomAcheteur,
    'nomPisteur': nomPisteur,
    'contactPisteur': contactPisteur,
    'nomProducteur': nomProducteur,
    'villageProducteur': villageProducteur,
    'contactProducteur': contactProducteur,
    'nbSacsAchetes': nbSacsAchetes != null
        ? int.tryParse(nbSacsAchetes!)
        : null,
    'nbSacsRembourses': nbSacsRembourses != null
        ? int.tryParse(nbSacsRembourses!)
        : null,
    'poidsTotal': poidsTotal != null ? double.tryParse(poidsTotal!) : null,
    'prixUnitaire': prixUnitaire != null
        ? double.tryParse(prixUnitaire!)
        : null,
    'valeurTotale': valeurTotale != null
        ? double.tryParse(valeurTotale!)
        : null,
    'montantPaye': montantPaye != null ? double.tryParse(montantPaye!) : null,
  };
}
