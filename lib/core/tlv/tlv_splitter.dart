// lib/core/tlv/tlv_splitter.dart
import 'tlv_protocol.dart';

/// Découpe une liste de champs TLV en N parties.
List<List<TlvField>> splitFieldsByEncodedLimit({
  required List<TlvField> allFields,
  required int ver,
  required int formId,
  required int limitChars,
  required TlvEncoderType encoderType,
}) {
  final parts = <List<TlvField>>[];
  final remaining = List<TlvField>.from(allFields);

  while (remaining.isNotEmpty) {
    final current = <TlvField>[];
    for (int i = 0; i < remaining.length; i++) {
      final testList = [...current, remaining[i]];

      // On simule un en-tête pour estimer la taille
      final testMessage = buildMessage(
        ver: ver,
        formId: formId,
        totalParts: 1, // L'estimation se fait avec totalParts=1
        partIndex: 1, // et partIndex=1
        tlvFields: testList,
      );

      final encoded = encodeBytes(testMessage, encoderType);

      if (encoded.length <= limitChars) {
        // Le champ rentre, on l'ajoute à la partie courante
        current.add(remaining[i]);
      } else {
        // Le champ ne rentre pas, on arrête de remplir cette partie
        break;
      }
    }

    if (current.isEmpty) {
      // Un seul champ est déjà trop gros
      throw Exception(
        'Un champ TLV (type=${remaining.first.type}) est trop large pour la limite de $limitChars caractères.',
      );
    }

    parts.add(List<TlvField>.from(current));
    // On retire les champs qui ont été ajoutés à la partie
    remaining.removeRange(0, current.length);
  }
  return parts;
}
