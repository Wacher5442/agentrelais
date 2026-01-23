import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'tlv_protocol.dart';

class TlvFieldMappings {
  // --- TAGS EXISTANTS & NOUVEAUX ---
  static const int numeroFiche = 1;
  static const int date = 2;
  static const int typeTransfert = 3;
  static const int sticker = 4;
  static const int sousPrefecture = 5;
  static const int acheteur = 6;
  static const int destinateur = 7;
  static const int sacs = 8;
  static const int poids = 9;
  static const int prix = 10;
  static const int remorque = 11;

  // Nouveaux champs ajoutés
  static const int region = 12;
  static const int departement = 13;
  static const int village = 14;
  static const int destinationVille = 15;
  static const int codeAcheteur = 16;
  static const int nomMagasin = 17;
  static const int immatriculation = 18;
  static const int chauffeur = 19;
  static const int thDepart = 20;
  static const int nomTransporteur = 21;
  static const int contactTransporteur = 22;
  static const int marqueCamion = 23;
  static const int avantCamion = 24;
  static const int denominationProduit = 25;
  static const int permisConduire = 26;

  // Types des métadonnées (200-255)
  // static const int submissionId = 200;
  static const int agentId = 200;
  static const int campagne = 201;
  static const int receiptCount = 203;

  static Uint8List _utf8(String? s) => Uint8List.fromList(utf8.encode(s ?? ''));

  /// Convertit le DTO en liste TLV.
  /// Si le filtre 'keysToKeep' est fourni, seuls ces champs seront inclus (utile pour USSD)
  static List<TlvField> mapFromDto(
    Map<String, dynamic> json,
    String agentId,
    String campagne,
    String receiptCount, {
    List<String>? keysToKeep,
  }) {
    // Définition de tous les champs possibles mappés à leurs tags
    final allPossibleFields = <String, TlvField>{
      'numeroFiche': TlvField(numeroFiche, _utf8(json['numeroFiche'])),
      'date': TlvField(date, _utf8(json['date'])),
      'typeTransfert': TlvField(typeTransfert, _utf8(json['typeTransfert'])),
      'sticker': TlvField(sticker, _utf8(json['sticker'])),
      'sousPrefecture': TlvField(sousPrefecture, _utf8(json['sousPrefecture'])),
      'region': TlvField(region, _utf8(json['region'])),
      'departement': TlvField(departement, _utf8(json['departement'])),
      'village': TlvField(village, _utf8(json['village'])),
      'destinationVille': TlvField(
        destinationVille,
        _utf8(json['destinationVille']),
      ),
      'acheteur': TlvField(acheteur, _utf8(json['acheteur'])),
      'codeAcheteur': TlvField(codeAcheteur, _utf8(json['codeAcheteur'])),
      'nomMagasin': TlvField(nomMagasin, _utf8(json['nomMagasin'])),
      'destinateur': TlvField(destinateur, _utf8(json['destinateur'])),
      'remorque': TlvField(remorque, _utf8(json['remorque'])),
      'immatriculation': TlvField(
        immatriculation,
        _utf8(json['immatriculation']),
      ),
      'nomChauffeur': TlvField(chauffeur, _utf8(json['nomChauffeur'])),
      'denominationProduit': TlvField(
        denominationProduit,
        _utf8(json['denomination']),
      ),
      'sacs': TlvField(sacs, _utf8(json['sacs'])),
      'poids': TlvField(poids, _utf8(json['poids'])),
      'prix': TlvField(prix, _utf8(json['prix'])),
    };

    List<TlvField> fields = [
      TlvField(TlvFieldMappings.agentId, _utf8(agentId)),
      TlvField(TlvFieldMappings.campagne, _utf8(campagne)),

      TlvField(TlvFieldMappings.agentId, _utf8(agentId)),
    ];

    // Si on a une liste blanche de clés (pour l'USSD), on filtre
    if (keysToKeep != null) {
      for (var key in keysToKeep) {
        if (allPossibleFields.containsKey(key)) {
          fields.add(allPossibleFields[key]!);
        }
      }
      log("keysToKeep 1 $keysToKeep");
    } else {
      // Sinon on prend tout (pour le stockage local binaire)
      fields.addAll(allPossibleFields.values);
    }

    log("fields ussd $fields");

    return fields.where((field) => field.value.isNotEmpty).toList();
  }
}
