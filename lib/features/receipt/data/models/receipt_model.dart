// lib/data/models/receipt_model.dart

class ReceiptModel {
  final String numeroRecu; // ID principal
  final String campagne;
  final String bundleId;
  final String? imagePath;
  final DateTime? date;
  final String? departement;
  final String? typeTransfert;
  final String? sousPrefecture;
  final String? village;
  final String? numeroAgrement;
  final String? nomAcheteur;
  final String? nomPisteur;
  final String? contactPisteur;
  final String? nomProducteur;
  final String? villageProducteur;
  final String? contactProducteur;
  final int? nbSacsAchetes;
  final int? nbSacsRembourses;
  final double? poidsTotal;
  final double? prixUnitaire;
  final double? valeurTotale;
  final double? montantPaye;
  final String status; // 'draft', 'en_attente', 'synchronise', 'echec'
  final String agentId;
  final int createdAt;
  final int updatedAt;

  ReceiptModel({
    required this.numeroRecu,
    required this.campagne,
    required this.bundleId,
    this.imagePath,
    this.date,
    this.departement,
    this.typeTransfert,
    this.sousPrefecture,
    this.village,
    this.numeroAgrement,
    this.nomAcheteur,
    this.nomPisteur,
    this.contactPisteur,
    this.nomProducteur,
    this.villageProducteur,
    this.contactProducteur,
    this.nbSacsAchetes,
    this.nbSacsRembourses,
    this.poidsTotal,
    this.prixUnitaire,
    this.valeurTotale,
    this.montantPaye,
    required this.status,
    required this.agentId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'numeroRecu': numeroRecu,
    'campagne': campagne,
    'bundleId': bundleId,
    'imagePath': imagePath,
    'date': date?.millisecondsSinceEpoch,
    'departement': departement,
    'typeTransfert': typeTransfert,
    'sousPrefecture': sousPrefecture,
    'village': village,
    'numeroAgrement': numeroAgrement,
    'nomAcheteur': nomAcheteur,
    'nomPisteur': nomPisteur,
    'contactPisteur': contactPisteur,
    'nomProducteur': nomProducteur,
    'villageProducteur': villageProducteur,
    'contactProducteur': contactProducteur,
    'nbSacsAchetes': nbSacsAchetes,
    'nbSacsRembourses': nbSacsRembourses,
    'poidsTotal': poidsTotal,
    'prixUnitaire': prixUnitaire,
    'valeurTotale': valeurTotale,
    'montantPaye': montantPaye,
    'status': status,
    'agentId': agentId,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  static ReceiptModel fromMap(Map<String, dynamic> m) => ReceiptModel(
    numeroRecu: m['numeroRecu'] as String,
    campagne: m['campagne'] as String,
    bundleId: m['bundleId'] as String,
    imagePath: m['imagePath'] as String?,
    date: m['date'] != null
        ? DateTime.fromMillisecondsSinceEpoch(m['date'] as int)
        : null,
    departement: m['departement'] as String?,
    typeTransfert: m['typeTransfert'] as String?,
    sousPrefecture: m['sousPrefecture'] as String?,
    village: m['village'] as String?,
    numeroAgrement: m['numeroAgrement'] as String?,
    nomAcheteur: m['nomAcheteur'] as String?,
    nomPisteur: m['nomPisteur'] as String?,
    contactPisteur: m['contactPisteur'] as String?,
    nomProducteur: m['nomProducteur'] as String?,
    villageProducteur: m['villageProducteur'] as String?,
    contactProducteur: m['contactProducteur'] as String?,
    nbSacsAchetes: m['nbSacsAchetes'] as int?,
    nbSacsRembourses: m['nbSacsRembourses'] as int?,
    poidsTotal: m['poidsTotal'] as double?,
    prixUnitaire: m['prixUnitaire'] as double?,
    valeurTotale: m['valeurTotale'] as double?,
    montantPaye: m['montantPaye'] as double?,
    status: m['status'] as String,
    agentId: m['agentId'] as String,
    createdAt: m['createdAt'] as int,
    updatedAt: m['updatedAt'] as int,
  );

  /// Convertit le modèle en JSON pour l'API
  Map<String, dynamic> toApiJson() => {
    'numeroRecu': numeroRecu,
    'campagne': campagne,
    'bundle_id': bundleId,
    'image': null, // Sera rempli par le datasource
    'date': date?.toIso8601String(),
    'departement': departement,
    'typeTransfert': typeTransfert,
    'sousPrefecture': sousPrefecture,
    'village': village,
    'numeroAgrement': numeroAgrement,
    'nomAcheteur': nomAcheteur,
    'nomPisteur': nomPisteur,
    'contactPisteur': contactPisteur,
    'nomProducteur': nomProducteur,
    'villageProducteur': villageProducteur,
    'contactProducteur': contactProducteur,
    'nbSacsAchetes': nbSacsAchetes,
    'nbSacsRembourses': nbSacsRembourses,
    'poidsTotal': poidsTotal,
    'prixUnitaire': prixUnitaire,
    'valeurTotale': valeurTotale,
    'montantPaye': montantPaye,
  };

  ReceiptModel copyWith({
    String? numeroRecu,
    String? campagne,
    String? bundleId,
    String? imagePath,
    DateTime? date,
    String? departement,
    String? typeTransfert,
    String? sousPrefecture,
    String? village,
    String? numeroAgrement,
    String? nomAcheteur,
    String? nomPisteur,
    String? contactPisteur,
    String? nomProducteur,
    String? villageProducteur,
    String? contactProducteur,
    int? nbSacsAchetes,
    int? nbSacsRembourses,
    double? poidsTotal,
    double? prixUnitaire,
    double? valeurTotale,
    double? montantPaye,
    String? status,
    String? agentId,
    int? createdAt,
    int? updatedAt,
  }) {
    return ReceiptModel(
      numeroRecu: numeroRecu ?? this.numeroRecu,
      campagne: campagne ?? this.campagne,
      bundleId: bundleId ?? this.bundleId,
      imagePath: imagePath ?? this.imagePath,
      date: date ?? this.date,
      departement: departement ?? this.departement,
      typeTransfert: typeTransfert ?? this.typeTransfert,
      sousPrefecture: sousPrefecture ?? this.sousPrefecture,
      village: village ?? this.village,
      numeroAgrement: numeroAgrement ?? this.numeroAgrement,
      nomAcheteur: nomAcheteur ?? this.nomAcheteur,
      nomPisteur: nomPisteur ?? this.nomPisteur,
      contactPisteur: contactPisteur ?? this.contactPisteur,
      nomProducteur: nomProducteur ?? this.nomProducteur,
      villageProducteur: villageProducteur ?? this.villageProducteur,
      contactProducteur: contactProducteur ?? this.contactProducteur,
      nbSacsAchetes: nbSacsAchetes ?? this.nbSacsAchetes,
      nbSacsRembourses: nbSacsRembourses ?? this.nbSacsRembourses,
      poidsTotal: poidsTotal ?? this.poidsTotal,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
      valeurTotale: valeurTotale ?? this.valeurTotale,
      montantPaye: montantPaye ?? this.montantPaye,
      status: status ?? this.status,
      agentId: agentId ?? this.agentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
