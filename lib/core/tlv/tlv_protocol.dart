// lib/core/tlv/tlv_protocol.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:base32/base32.dart';
import 'package:uuid/uuid.dart';

// 1. Enum d'encodage UNIFIÉ
enum TlvEncoderType { base64Url, base32 }

class TlvField {
  final int type;
  final Uint8List value;
  TlvField(this.type, this.value);
}

/// Calcule le checksum (Somme Modulo 256)
int computeChecksum(Uint8List bytes) {
  int sum = 0;
  for (final b in bytes) sum = (sum + b) & 0xFF;
  return sum;
}

/// Construit la portion [TLV_1][TLV_2]...[TLV_N]
Uint8List buildTlvPayload(List<TlvField> fields) {
  final builder = BytesBuilder();
  for (final f in fields) {
    if (f.value.length > 255) {
      // Sécurité : le protocole L (Length) est sur 1 octet
      throw Exception(
        "Champ TLV (type=${f.type}) trop long: ${f.value.length} octets",
      );
    }
    builder.addByte(f.type & 0xFF);
    builder.addByte(f.value.length & 0xFF);
    builder.add(f.value);
  }
  return builder.toBytes();
}

/// Construit le message binaire complet avec en-tête et checksum
Uint8List buildMessage({
  required int ver,
  required int formId,
  required int totalParts,
  required int partIndex,
  required List<TlvField> tlvFields,
}) {
  final b = BytesBuilder();
  // En-tête (5 octets)
  b.addByte(ver & 0xFF);
  b.addByte(formId & 0xFF);
  b.addByte(totalParts & 0xFF);
  b.addByte(partIndex & 0xFF);
  b.addByte(tlvFields.length & 0xFF);

  // Charge utile (N octets)
  b.add(buildTlvPayload(tlvFields));

  // Checksum (1 octet)
  final payload = b.toBytes();
  final checksum = computeChecksum(payload);

  final fb = BytesBuilder();
  fb.add(payload);
  fb.addByte(checksum);
  return fb.toBytes();
}

/// Encodeur UNIFIÉ
String encodeBytes(Uint8List bytes, TlvEncoderType t) {
  switch (t) {
    case TlvEncoderType.base64Url:
      return base64UrlEncode(bytes);
    case TlvEncoderType.base32:
      return base32.encode(bytes);
  }
}

/// Génère un ID de soumission unique
String generateShortSubmissionId() {
  final u = Uuid().v4().replaceAll('-', '').toUpperCase();
  return u.substring(0, 12);
}
