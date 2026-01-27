import 'dart:convert';
import 'dart:typed_data';

import '../../domain/entities/receipt_entity.dart';
import '../../domain/entities/transfert_entity.dart';

class TransfertModel extends TransfertEntity {
  final Uint8List? payload;
  final String? encodedPreview;
  final int? totalParts;
  final int? partsSent;
  final String? fieldsJson;

  const TransfertModel({
    super.id,
    required super.numeroFiche,
    required super.formId,
    required super.status,
    required super.submissionMethod,
    required super.createdAt,
    required super.updatedAt,
    required super.username,
    required super.bundleId,
    required super.campagne,
    super.typeTransfert,
    super.sticker,
    super.date,
    super.region,
    super.departement,
    super.sousPrefecture,
    super.village,
    super.destinationVille,
    super.destinateur,
    super.acheteur,
    super.contactAcheteur,
    super.codeAcheteur,
    super.nomMagasin,
    super.denomination,
    super.thDepart,
    super.sacs,
    super.poids,
    super.nomTransporteur,
    super.contactTransporteur,
    super.marqueCamion,
    super.immatriculation,
    super.remorque,
    super.avantCamion,
    super.nomChauffeur,
    super.permisConduire,
    super.prix,
    super.image,
    super.receipts = const [],
    super.destDateDechargement,
    super.destHeure,
    super.destNomExportateur,
    super.destCodeExportateur,
    super.destPortUsineDechargement,
    super.destPontBascule,
    super.destNomMagasin,
    super.destKor,
    super.destNombreSacsDecharges,
    super.destNombreSacsRembourses,
    super.destTauxHumidite,
    super.destPoidsBrut,
    super.destTare,
    super.destPoidsNet,
    super.destPrixKg,
    this.payload,
    this.encodedPreview,
    this.totalParts,
    this.partsSent,
    this.fieldsJson,
  });

  factory TransfertModel.fromMap(Map<String, dynamic> map) {
    final fields = jsonDecode(map['fieldsJson'] as String? ?? '{}');
    List<ReceiptEntity> receiptsList = [];
    final rawReceipts = map['receipts'] ?? fields['receipts'];
    if (rawReceipts != null) {
      receiptsList = (rawReceipts as List)
          .map((e) => ReceiptEntity.fromMap(e))
          .toList();
    }

    return TransfertModel(
      id: map['id'] as int?,
      numeroFiche: map['numeroFiche'] as String,
      formId: map['formId'] as int,
      status: map['status'] as String,
      submissionMethod: map['submissionMethod'] as String? ?? 'local',
      username: map['username'] as String,
      bundleId: map['bundle_id'] as String? ?? '',
      campagne: map['campagne'] as String? ?? '2025-2026',
      createdAt: map['createdAt'] as int,
      updatedAt: map['updatedAt'] as int,
      receipts: receiptsList,
      payload: map['payload'] as Uint8List?,
      encodedPreview: map['encodedPreview'] as String?,
      totalParts: map['totalParts'] as int?,
      partsSent: map['partsSent'] as int?,
      fieldsJson: map['fieldsJson'] as String?,

      // Extraction des champs métiers depuis le JSON fieldsJson ou map (si remote flatten)
      typeTransfert: map['typeTransfert'] ?? fields['typeTransfert'],
      sticker: map['sticker'] ?? fields['sticker'],
      date: map['date'] ?? fields['date'],
      region: map['region'] ?? fields['region'],
      departement: map['departement'] ?? fields['departement'],
      sousPrefecture: map['sousPrefecture'] ?? fields['sousPrefecture'],
      village: map['village'] ?? fields['village'],
      destinationVille: map['destinationVille'] ?? fields['destinationVille'],
      destinateur: map['destinateur'] ?? fields['destinateur'],
      acheteur: map['acheteur'] ?? fields['acheteur'],
      contactAcheteur: map['contactAcheteur'] ?? fields['contactAcheteur'],
      codeAcheteur: map['codeAcheteur'] ?? fields['codeAcheteur'],
      nomMagasin: map['nomMagasin'] ?? fields['nomMagasin'],
      denomination: map['denomination'] ?? fields['denomination'],
      thDepart: map['thDepart'] ?? fields['thDepart'],
      sacs: map['sacs'] ?? fields['sacs'],
      poids: map['poids'] ?? fields['poids'],
      nomTransporteur: map['nomTransporteur'] ?? fields['nomTransporteur'],
      contactTransporteur:
          map['contactTransporteur'] ?? fields['contactTransporteur'],
      marqueCamion: map['marqueCamion'] ?? fields['marqueCamion'],
      immatriculation: map['immatriculation'] ?? fields['immatriculation'],
      remorque: map['remorque'] ?? fields['remorque'],
      avantCamion: map['avantCamion'] ?? fields['avantCamion'],
      nomChauffeur: map['nomChauffeur'] ?? fields['nomChauffeur'],
      permisConduire: map['permisConduire'] ?? fields['permisConduire'],
      prix: map['prix'] ?? fields['prix'],
      image: map['image'] ?? fields['image'],

      // Champs Destination
      destDateDechargement:
          map['dest_date_dechargement'] ?? fields['dest_date_dechargement'],
      destHeure: map['dest_heure'] ?? fields['dest_heure'],
      destNomExportateur:
          map['dest_nom_exportateur'] ?? fields['dest_nom_exportateur'],
      destCodeExportateur:
          map['dest_code_exportateur'] ?? fields['dest_code_exportateur'],
      destPortUsineDechargement:
          map['dest_port_usine_dechargement'] ??
          fields['dest_port_usine_dechargement'],
      destPontBascule: map['dest_pont_bascule'] ?? fields['dest_pont_bascule'],
      destNomMagasin: map['dest_nom_magasin'] ?? fields['dest_nom_magasin'],
      destKor: map['dest_kor'] ?? fields['dest_kor'],
      destNombreSacsDecharges:
          map['dest_nombre_sacs_decharges'] ??
          fields['dest_nombre_sacs_decharges'],
      destNombreSacsRembourses:
          map['dest_nombre_sacs_rembourses'] ??
          fields['dest_nombre_sacs_rembourses'],
      destTauxHumidite:
          map['dest_taux_humidite'] ?? fields['dest_taux_humidite'],
      destPoidsBrut: map['dest_poids_brut'] ?? fields['dest_poids_brut'],
      destTare: map['dest_tare'] ?? fields['dest_tare'],
      destPoidsNet: map['dest_poids_net'] ?? fields['dest_poids_net'],
      destPrixKg: map['dest_prix_kg'] ?? fields['dest_prix_kg'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numeroFiche': numeroFiche,
      'formId': formId,
      'status': status,
      'submissionMethod': submissionMethod,
      'typeTransfert': typeTransfert,
      'username': username,
      'bundle_id': bundleId,
      'campagne': campagne,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'payload': payload,
      'encodedPreview': encodedPreview,
      'totalParts': totalParts,
      'partsSent': partsSent,
      'fieldsJson': fieldsJson,
      'image': image,
    };
  }
}
