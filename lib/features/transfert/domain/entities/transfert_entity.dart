import 'package:equatable/equatable.dart';

import 'receipt_entity.dart';

class TransfertEntity extends Equatable {
  final int? id;
  final String numeroFiche; // Now required, primary identifier
  final int formId;
  final String status;
  final String submissionMethod;
  final int createdAt;
  final int updatedAt;
  final String username; // Replaced agentId
  final String bundleId; // Concatenation of receipt numbers
  final String campagne; // Dynamic campaign period

  // Champs Métiers
  final String? typeTransfert;
  final String? sticker;
  final String? date;
  final String? region;
  final String? departement;
  final String? sousPrefecture;
  final String? village;
  final String? destinationVille;
  final String? destinateur; // Usine/Exportateur
  final String? acheteur;
  final String? contactAcheteur;
  final String? codeAcheteur;
  final String? nomMagasin;
  final String? denomination;
  final String? thDepart;
  final String? sacs;
  final String? poids;
  final String? nomTransporteur;
  final String? contactTransporteur;
  final String? marqueCamion;
  final String? immatriculation;
  final String? remorque;
  final String? avantCamion;
  final String? nomChauffeur;
  final String? permisConduire;
  final String? prix;
  final List<ReceiptEntity> receipts;
  final String? image; // Renamed from photoFiche

  // Champs Déchargement (Destination)
  final String? destDateDechargement;
  final String? destHeure;
  final String? destNomExportateur;
  final String? destCodeExportateur;
  final String? destPortUsineDechargement;
  final String? destPontBascule;
  final String? destNomMagasin;
  final String? destKor;
  final num? destNombreSacsDecharges;
  final num? destNombreSacsRembourses;
  final num? destTauxHumidite;
  final num? destPoidsBrut;
  final num? destTare;
  final num? destPoidsNet;
  final num? destPrixKg;

  // Configuration pour l'envoi partiel USSD
  final List<String>? ussdFields;

  const TransfertEntity({
    this.id,
    required this.numeroFiche,
    required this.formId,
    required this.status,
    required this.submissionMethod,
    required this.createdAt,
    required this.updatedAt,
    required this.username,
    required this.bundleId,
    required this.campagne,
    this.typeTransfert,
    this.sticker,
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
    this.receipts = const [],
    this.ussdFields,
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
  });

  Map<String, dynamic> toFieldsJson() {
    return {
      'form_id': formId,
      'bundle_id': bundleId,
      'campagne': campagne,
      'numeroFiche': numeroFiche,
      'typeTransfert': typeTransfert,
      'sticker': sticker,
      'date': date,
      'region': region,
      'departement': departement,
      'sousPrefecture': sousPrefecture,
      'village': village,
      'destinationVille': destinationVille,
      'destinateur': destinateur,
      'acheteur': acheteur,
      'contactAcheteur': contactAcheteur,
      'codeAcheteur': codeAcheteur,
      'nomMagasin': nomMagasin,
      'denomination': denomination,
      'thDepart': thDepart,
      'sacs': sacs,
      'poids': poids,
      'nomTransporteur': nomTransporteur,
      'contactTransporteur': contactTransporteur,
      'marqueCamion': marqueCamion,
      'immatriculation': immatriculation,
      'remorque': remorque,
      'avantCamion': avantCamion,
      'nomChauffeur': nomChauffeur,
      'permisConduire': permisConduire,
      'prix': prix,
      'image': image,
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
      'receipts': receipts.map((e) => e.toMap()).toList(),
    };
  }

  TransfertEntity copyWith({
    int? id,
    String? numeroFiche,
    int? formId,
    String? status,
    String? submissionMethod,
    int? createdAt,
    int? updatedAt,
    String? username,
    String? bundleId,
    String? campagne,
    String? typeTransfert,
    String? sticker,
    String? date,
    String? region,
    String? departement,
    String? sousPrefecture,
    String? village,
    String? destinationVille,
    String? destinateur,
    String? acheteur,
    String? contactAcheteur,
    String? codeAcheteur,
    String? nomMagasin,
    String? denomination,
    String? thDepart,
    String? sacs,
    String? poids,
    String? nomTransporteur,
    String? contactTransporteur,
    String? marqueCamion,
    String? immatriculation,
    String? remorque,
    String? avantCamion,
    String? nomChauffeur,
    String? permisConduire,
    String? prix,
    String? image,
    List<ReceiptEntity>? receipts,
    List<String>? ussdFields,
    String? destDateDechargement,
    String? destHeure,
    String? destNomExportateur,
    String? destCodeExportateur,
    String? destPortUsineDechargement,
    String? destPontBascule,
    String? destNomMagasin,
    String? destKor,
    num? destNombreSacsDecharges,
    num? destNombreSacsRembourses,
    num? destTauxHumidite,
    num? destPoidsBrut,
    num? destTare,
    num? destPoidsNet,
    num? destPrixKg,
  }) {
    return TransfertEntity(
      id: id ?? this.id,
      numeroFiche: numeroFiche ?? this.numeroFiche,
      formId: formId ?? this.formId,
      status: status ?? this.status,
      submissionMethod: submissionMethod ?? this.submissionMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      username: username ?? this.username,
      bundleId: bundleId ?? this.bundleId,
      campagne: campagne ?? this.campagne,
      typeTransfert: typeTransfert ?? this.typeTransfert,
      sticker: sticker ?? this.sticker,
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
      receipts: receipts ?? this.receipts,
      ussdFields: ussdFields ?? this.ussdFields,
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
    );
  }

  @override
  List<Object?> get props => [numeroFiche, status, createdAt];
}
