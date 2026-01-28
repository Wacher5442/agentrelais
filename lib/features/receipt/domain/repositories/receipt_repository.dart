// lib/domain/repositories/receipt_repository.dart

import '../entities/receipt.dart';

/// Énumération des statuts pour la logique métier
class ReceiptStatus {
  static const String draft = 'draft';
  static const String pending = 'en_attente';
  static const String synced = 'synchronise';
  static const String failed = 'echec';
}

/// Résultat d'une soumission
class SubmissionResult {
  final String numeroRecu;
  final bool success;
  final String message;

  SubmissionResult({
    required this.numeroRecu,
    required this.success,
    required this.message,
  });
}

abstract class ReceiptRepository {
  /// Soumet un reçu (sauvegarde locale + tentative d'envoi HTTP)
  Future<SubmissionResult> submitReceipt(ReceiptEntity receipt);

  /// Synchronise tous les reçus en attente
  Future<int> syncPendingReceipts();

  /// Récupère tous les reçus
  Future<List<ReceiptEntity>> getAllReceipts();

  /// Récupère un reçu par son numéro
  Future<ReceiptEntity?> getReceiptByNumero(String numeroRecu);
}
