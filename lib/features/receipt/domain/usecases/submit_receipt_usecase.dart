// lib/domain/usecases/submit_receipt_usecase.dart

import '../entities/receipt.dart';
import '../repositories/receipt_repository.dart';

class SubmitReceiptUseCase {
  final ReceiptRepository repo;

  SubmitReceiptUseCase({required this.repo});

  /// Exécute la soumission d'un reçu
  Future<SubmissionResult> execute({
    required String numeroRecu,
    required String campagne,
    required Map<String, dynamic> fields,
    required String agentId,
    String? photoPath,
  }) async {
    // 1. Créer l'entité métier
    final receipt = ReceiptEntity(
      numeroRecu: numeroRecu,
      campagne: campagne,
      fields: fields,
      agentId: agentId,
      photoPath: photoPath,
    );

    // 2. Déléguer au repository
    try {
      return await repo.submitReceipt(receipt);
    } catch (e) {
      throw Exception('Échec de la soumission: ${e.toString()}');
    }
  }
}
