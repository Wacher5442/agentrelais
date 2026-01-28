// lib/domain/entities/receipt.dart

class ReceiptEntity {
  final String numeroRecu; // ID principal
  final String campagne;
  final Map<String, dynamic> fields; // Tous les champs du reçu
  final String? photoPath;
  final String agentId;
  final String? status;

  ReceiptEntity({
    required this.numeroRecu,
    required this.campagne,
    required this.fields,
    required this.agentId,
    this.photoPath,
    this.status,
  });

  ReceiptEntity copyWith({
    String? numeroRecu,
    String? campagne,
    Map<String, dynamic>? fields,
    String? photoPath,
    String? agentId,
    String? status,
  }) {
    return ReceiptEntity(
      numeroRecu: numeroRecu ?? this.numeroRecu,
      campagne: campagne ?? this.campagne,
      fields: fields ?? this.fields,
      photoPath: photoPath ?? this.photoPath,
      agentId: agentId ?? this.agentId,
      status: status ?? this.status,
    );
  }
}
