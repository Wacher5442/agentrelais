import 'package:equatable/equatable.dart';

class ChargementEntity extends Equatable {
  final dynamic numeroFiche;
  final dynamic bundleId;
  final dynamic campagne;
  final dynamic sticker;
  final dynamic status;
  final dynamic typeTransfert;
  final dynamic date;
  final dynamic region;
  final dynamic departement;
  final dynamic sousPrefecture;
  final dynamic village;
  final dynamic destinationVille;
  final dynamic destinateur;
  final dynamic acheteur;
  final dynamic contactAcheteur;
  final dynamic codeAcheteur;
  final dynamic nomMagasin;
  final dynamic denomination;
  final dynamic thDepart;
  final dynamic sacs;
  final dynamic poids;
  final dynamic nomTransporteur;
  final dynamic contactTransporteur;
  final dynamic marqueCamion;
  final dynamic immatriculation;
  final dynamic remorque;
  final dynamic avantCamion;
  final dynamic nomChauffeur;
  final dynamic permisConduire;
  final dynamic prix;
  final dynamic image;

  // Destination Fields
  final dynamic destDateDechargement;
  final dynamic destHeure;
  final dynamic destNomExportateur;
  final dynamic destCodeExportateur;
  final dynamic destPortUsineDechargement;
  final dynamic destPontBascule;
  final dynamic destNomMagasin;
  final dynamic destKor;
  final num? destNombreSacsDecharges;
  final num? destNombreSacsRembourses;
  final num? destTauxHumidite;
  final num? destPoidsBrut;
  final num? destTare;
  final num? destPoidsNet;
  final num? destPrixKg;
  final num? destTauxDefectueux;
  final num? destGrainage;
  final dynamic destObservations;
  final dynamic regionLibelle;
  final dynamic departementLibelle;
  final dynamic typeTransfertLibelle;
  final dynamic sousPrefectureLibelle;
  final dynamic villageLibelle;
  final dynamic acheteurLibelle;
  final dynamic campagneLibelle;
  final dynamic magasinLibelle;

  const ChargementEntity({
    required this.numeroFiche,
    required this.bundleId,
    required this.campagne,
    required this.sticker,
    required this.status,
    required this.typeTransfert,
    this.date,
    this.region,
    this.departement,
    this.sousPrefecture,
    this.village,
    this.destinationVille,
    this.destinateur,
    this.acheteur,
    this.contactAcheteur,
    this.codeAcheteur,
    this.nomMagasin,
    this.denomination,
    this.thDepart,
    this.sacs,
    this.poids,
    this.nomTransporteur,
    this.contactTransporteur,
    this.marqueCamion,
    this.immatriculation,
    this.remorque,
    this.avantCamion,
    this.nomChauffeur,
    this.permisConduire,
    this.prix,
    this.image,
    this.destDateDechargement,
    this.destHeure,
    this.destNomExportateur,
    this.destCodeExportateur,
    this.destPortUsineDechargement,
    this.destPontBascule,
    this.destNomMagasin,
    this.destKor,
    this.destNombreSacsDecharges,
    this.destNombreSacsRembourses,
    this.destTauxHumidite,
    this.destPoidsBrut,
    this.destTare,
    this.destPoidsNet,
    this.destPrixKg,
    this.destTauxDefectueux,
    this.destGrainage,
    this.destObservations,
    this.regionLibelle,
    this.departementLibelle,
    this.typeTransfertLibelle,
    this.sousPrefectureLibelle,
    this.villageLibelle,
    this.acheteurLibelle,
    this.campagneLibelle,
    this.magasinLibelle,
  });

  ChargementEntity copyWith({
    dynamic numeroFiche,
    dynamic campagne,
    dynamic sticker,
    dynamic status,
    dynamic typeTransfert,
    dynamic date,
    dynamic region,
    dynamic departement,
    dynamic sousPrefecture,
    dynamic village,
    dynamic destinationVille,
    dynamic destinateur,
    dynamic acheteur,
    dynamic contactAcheteur,
    dynamic codeAcheteur,
    dynamic nomMagasin,
    dynamic denomination,
    dynamic thDepart,
    dynamic sacs,
    dynamic poids,
    dynamic nomTransporteur,
    dynamic contactTransporteur,
    dynamic marqueCamion,
    dynamic immatriculation,
    dynamic remorque,
    dynamic avantCamion,
    dynamic nomChauffeur,
    dynamic permisConduire,
    dynamic prix,
    dynamic image,
    dynamic destDateDechargement,
    dynamic destHeure,
    dynamic destNomExportateur,
    dynamic destCodeExportateur,
    dynamic destPortUsineDechargement,
    dynamic destPontBascule,
    dynamic destNomMagasin,
    dynamic destKor,
    dynamic destNombreSacsDecharges,
    dynamic destNombreSacsRembourses,
    dynamic destTauxHumidite,
    dynamic destPoidsBrut,
    dynamic destTare,
    dynamic destPoidsNet,
    dynamic destPrixKg,
    dynamic destTauxDefectueux,
    dynamic destGrainage,
    dynamic destObservations,
    dynamic regionLibelle,
    dynamic departementLibelle,
    dynamic typeTransfertLibelle,
    dynamic sousPrefectureLibelle,
    dynamic villageLibelle,
    dynamic acheteurLibelle,
    dynamic campagneLibelle,
    dynamic magasinLibelle,
  }) {
    return ChargementEntity(
      numeroFiche: numeroFiche ?? this.numeroFiche,
      bundleId: bundleId ?? bundleId,
      campagne: campagne ?? this.campagne,
      sticker: sticker ?? this.sticker,
      status: status ?? this.status,
      typeTransfert: typeTransfert ?? this.typeTransfert,
      date: date ?? this.date,
      region: region ?? this.region,
      departement: departement ?? this.departement,
      sousPrefecture: sousPrefecture ?? this.sousPrefecture,
      village: village ?? this.village,
      destinationVille: destinationVille ?? this.destinationVille,
      destinateur: destinateur ?? this.destinateur,
      acheteur: acheteur ?? this.acheteur,
      contactAcheteur: contactAcheteur ?? this.contactAcheteur,
      codeAcheteur: codeAcheteur ?? this.codeAcheteur,
      nomMagasin: nomMagasin ?? this.nomMagasin,
      denomination: denomination ?? this.denomination,
      thDepart: thDepart ?? this.thDepart,
      sacs: sacs ?? this.sacs,
      poids: poids ?? this.poids,
      nomTransporteur: nomTransporteur ?? this.nomTransporteur,
      contactTransporteur: contactTransporteur ?? this.contactTransporteur,
      marqueCamion: marqueCamion ?? this.marqueCamion,
      immatriculation: immatriculation ?? this.immatriculation,
      remorque: remorque ?? this.remorque,
      avantCamion: avantCamion ?? this.avantCamion,
      nomChauffeur: nomChauffeur ?? this.nomChauffeur,
      permisConduire: permisConduire ?? this.permisConduire,
      prix: prix ?? this.prix,
      image: image ?? this.image,
      destDateDechargement: destDateDechargement ?? this.destDateDechargement,
      destHeure: destHeure ?? this.destHeure,
      destNomExportateur: destNomExportateur ?? this.destNomExportateur,
      destCodeExportateur: destCodeExportateur ?? this.destCodeExportateur,
      destPortUsineDechargement:
          destPortUsineDechargement ?? this.destPortUsineDechargement,
      destPontBascule: destPontBascule ?? this.destPontBascule,
      destNomMagasin: destNomMagasin ?? this.destNomMagasin,
      destKor: destKor ?? this.destKor,
      destNombreSacsDecharges:
          destNombreSacsDecharges ?? this.destNombreSacsDecharges,
      destNombreSacsRembourses:
          destNombreSacsRembourses ?? this.destNombreSacsRembourses,
      destTauxHumidite: destTauxHumidite ?? this.destTauxHumidite,
      destPoidsBrut: destPoidsBrut ?? this.destPoidsBrut,
      destTare: destTare ?? this.destTare,
      destPoidsNet: destPoidsNet ?? this.destPoidsNet,
      destPrixKg: destPrixKg ?? this.destPrixKg,
      destTauxDefectueux: destTauxDefectueux ?? this.destTauxDefectueux,
      destGrainage: destGrainage ?? this.destGrainage,
      destObservations: destObservations ?? this.destObservations,
      regionLibelle: regionLibelle ?? this.regionLibelle,
      departementLibelle: departementLibelle ?? this.departementLibelle,
      typeTransfertLibelle: typeTransfertLibelle ?? this.typeTransfertLibelle,
      sousPrefectureLibelle:
          sousPrefectureLibelle ?? this.sousPrefectureLibelle,
      villageLibelle: villageLibelle ?? this.villageLibelle,
      acheteurLibelle: acheteurLibelle ?? this.acheteurLibelle,
      campagneLibelle: campagneLibelle ?? this.campagneLibelle,
      magasinLibelle: magasinLibelle ?? this.magasinLibelle,
    );
  }

  // Helper method to convert to field map for API patching
  Map<String, dynamic> toFieldsJson() {
    return {
      'dest_date_dechargement': destDateDechargement,
      'dest_heure': destHeure,
      'dest_nom_exportateur': destNomExportateur,
      'dest_code_exportateur': destCodeExportateur,
      'dest_port_usine_dechargement': destPortUsineDechargement,
      'dest_pont_bascule': destPontBascule,
      'dest_nom_magasin': destNomMagasin,
      'dest_kor': destKor,
      'dest_nombre_sacs_decharges': destNombreSacsDecharges,
      'dest_nombre_sacs_rembourses': destNombreSacsRembourses,
      'dest_taux_humidite': destTauxHumidite,
      'dest_poids_brut': destPoidsBrut,
      'dest_tare': destTare,
      'dest_poids_net': destPoidsNet,
      'dest_prix_kg': destPrixKg,
      'dest_taux_defectueux': destTauxDefectueux,
      'dest_grainage': destGrainage,
      'dest_observations': destObservations,
      'regionLibelle': regionLibelle,
      'departementLibelle': departementLibelle,
      'typeTransfertLibelle': typeTransfertLibelle,
      'sousPrefectureLibelle': sousPrefectureLibelle,
      'villageLibelle': villageLibelle,
      'acheteurLibelle': acheteurLibelle,
      'campagneLibelle': campagneLibelle,
      'magasinLibelle': magasinLibelle,
    };
  }

  @override
  List<Object?> get props => [
    numeroFiche, bundleId, sticker, status, typeTransfert,
    destKor, destPoidsNet, // Add significant fields for comparison if needed
  ];
}
