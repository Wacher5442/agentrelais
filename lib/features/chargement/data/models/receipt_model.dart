import 'package:equatable/equatable.dart';

class ReceiptModel extends Equatable {
  final String numeroRecu;
  final String? campagne;
  final String? bundleId;
  final String? image;
  final String? date;
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
  final dynamic nbSacsAchetes;
  final dynamic nbSacsRembourses;
  final dynamic poidsTotal;
  final dynamic prixUnitaire;
  final dynamic valeurTotale;
  final dynamic montantPaye;

  const ReceiptModel({
    required this.numeroRecu,
    this.campagne,
    this.bundleId,
    this.image,
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
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    return ReceiptModel(
      numeroRecu: json['numeroRecu']?.toString() ?? '',
      campagne: json['campagne']?.toString(),
      bundleId: json['bundle_id']?.toString(),
      image: json['image']?.toString(),
      date: json['date']?.toString(),
      departement: json['departement']?.toString(),
      typeTransfert: json['typeTransfert']?.toString(),
      sousPrefecture: json['sousPrefecture']?.toString(),
      village: json['village']?.toString(),
      numeroAgrement: json['numeroAgrement']?.toString(),
      nomAcheteur: json['nomAcheteur']?.toString(),
      nomPisteur: json['nomPisteur']?.toString(),
      contactPisteur: json['contactPisteur']?.toString(),
      nomProducteur: json['nomProducteur']?.toString(),
      villageProducteur: json['villageProducteur']?.toString(),
      contactProducteur: json['contactProducteur']?.toString(),
      nbSacsAchetes: json['nbSacsAchetes'],
      nbSacsRembourses: json['nbSacsRembourses'],
      poidsTotal: json['poidsTotal'],
      prixUnitaire: json['prixUnitaire'],
      valeurTotale: json['valeurTotale'],
      montantPaye: json['montantPaye'],
    );
  }

  @override
  List<Object?> get props => [numeroRecu, bundleId, image];
}
