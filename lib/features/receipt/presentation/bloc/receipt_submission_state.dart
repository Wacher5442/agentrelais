import '../../domain/repositories/receipt_repository.dart';

abstract class ReceiptSubmissionState {}

class ReceiptInitial extends ReceiptSubmissionState {}

class ReceiptSubmitting extends ReceiptSubmissionState {}

class ReceiptSubmissionSuccess extends ReceiptSubmissionState {
  final SubmissionResult result;

  ReceiptSubmissionSuccess(this.result);
}

class ReceiptSubmissionFailure extends ReceiptSubmissionState {
  final String message;

  ReceiptSubmissionFailure(this.message);
}

class ReceiptSyncInProgress extends ReceiptSubmissionState {}

class ReceiptSyncSuccess extends ReceiptSubmissionState {
  final int syncedCount;

  ReceiptSyncSuccess(this.syncedCount);
}

class ReceiptSyncFailure extends ReceiptSubmissionState {
  final String message;

  ReceiptSyncFailure(this.message);
}
