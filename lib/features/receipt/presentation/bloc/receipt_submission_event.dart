import '../dtos/receipt_form_data.dart';

abstract class ReceiptSubmissionEvent {}

class SubmitReceiptEvent extends ReceiptSubmissionEvent {
  final ReceiptFormData form;

  SubmitReceiptEvent(this.form);
}

class RetryPendingReceiptsEvent extends ReceiptSubmissionEvent {}
