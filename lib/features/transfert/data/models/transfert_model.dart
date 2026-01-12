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
    required super.submissionId,
    required super.formId,
    required super.status,
    required super.submissionMethod,
    required super.createdAt,
    required super.updatedAt,
    required super.agentId,
    super.numeroFiche,
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
    super.receipts = const [],
    this.payload,
    this.encodedPreview,
    this.totalParts,
    this.partsSent,
    this.fieldsJson,
  });

  factory TransfertModel.fromMap(Map<String, dynamic> map) {
    final fields = jsonDecode(map['fieldsJson'] as String? ?? '{}');

    // Deserialize receipts from fieldsJson or a separate column if we added one.
    // For now, let's assume they are part of fieldsJson or we need to parse them.
    // Since we are refactoring, let's assume we store them in fieldsJson for simplicity
    // or we can add a new column. Given the constraints, let's look for them in fieldsJson.

    List<ReceiptEntity> receiptsList = [];
    if (fields['receipts'] != null) {
      receiptsList = (fields['receipts'] as List)
          .map((e) => ReceiptEntity.fromMap(e))
          .toList();
    }

    return TransfertModel(
      id: map['id'] as int?,
      submissionId: map['submissionId'] as String,
      formId: map['formId'] as int,
      status: map['status'] as String,
      submissionMethod: map['submissionMethod'] as String? ?? 'local',
      agentId: map['agentId'] as String,
      createdAt: map['createdAt'] as int,
      updatedAt: map['updatedAt'] as int,
      receipts: receiptsList,
      payload: map['payload'] as Uint8List?,
      encodedPreview: map['encodedPreview'] as String?,
      totalParts: map['totalParts'] as int?,
      partsSent: map['partsSent'] as int?,
      fieldsJson: map['fieldsJson'] as String?,

      // Extraction des champs métiers depuis le JSON fieldsJson
      numeroFiche: fields['numeroFiche'],
      typeTransfert: map['typeTransfert'] ?? fields['typeTransfert'],
      sticker: fields['sticker'],
      date: fields['date'],
      region: fields['region'],
      departement: fields['departement'],
      sousPrefecture: fields['sousPrefecture'],
      village: fields['village'],
      destinationVille: fields['destinationVille'],
      destinateur: fields['destinateur'],
      acheteur: fields['acheteur'],
      contactAcheteur: fields['contactAcheteur'],
      codeAcheteur: fields['codeAcheteur'],
      nomMagasin: fields['nomMagasin'],
      denomination: fields['denomination'],
      thDepart: fields['thDepart'],
      sacs: fields['sacs'],
      poids: fields['poids'],
      nomTransporteur: fields['nomTransporteur'],
      contactTransporteur: fields['contactTransporteur'],
      marqueCamion: fields['marqueCamion'],
      immatriculation: fields['immatriculation'],
      remorque: fields['remorque'],
      avantCamion: fields['avantCamion'],
      nomChauffeur: fields['nomChauffeur'],
      permisConduire: fields['permisConduire'],
      prix: fields['prix'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'submissionId': submissionId,
      'formId': formId,
      'status': status,
      'submissionMethod': submissionMethod,
      'typeTransfert': typeTransfert,
      'agentId': agentId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'payload': payload,
      'encodedPreview': encodedPreview,
      'totalParts': totalParts,
      'partsSent': partsSent,
      'fieldsJson': fieldsJson,
    };
  }
}
