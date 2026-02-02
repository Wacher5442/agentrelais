import '../entities/receipt.dart';

class ReceiptStatus {
  static const String draft = 'draft';
  static const String pending = 'en_attente';
  static const String synced = 'synchronise';
  static const String failed = 'echec';
}

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
  Future<SubmissionResult> submitReceipt(ReceiptEntity receipt);

  Future<int> syncPendingReceipts();

  Future<List<ReceiptEntity>> getAllReceipts();

  Future<ReceiptEntity?> getReceiptByNumero(String numeroRecu);
}
