import 'package:equatable/equatable.dart';

import 'receipt_entity.dart';

class TransfertEntity extends Equatable {
  final int? id;
  final String submissionId;
  final int formId;
  final String status;
  final String submissionMethod;
  final int createdAt;
  final int updatedAt;
  final String agentId;

  // Champs Métiers
  final String? numeroFiche;
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
  final String? photoFiche;

  // Configuration pour l'envoi partiel USSD
  final List<String>? ussdFields;

  const TransfertEntity({
    this.id,
    required this.submissionId,
    required this.formId,
    required this.status,
    required this.submissionMethod,
    required this.createdAt,
    required this.updatedAt,
    required this.agentId,
    this.numeroFiche,
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
    this.photoFiche,
    this.receipts = const [],
    this.ussdFields,
  });

  Map<String, dynamic> toFieldsJson() {
    return {
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
      'receipts': receipts.map((e) => e.toMap()).toList(),
    };
  }

  @override
  List<Object?> get props => [submissionId, status, createdAt];
}
