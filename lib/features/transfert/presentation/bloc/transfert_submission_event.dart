import 'package:equatable/equatable.dart';

import '../../domain/entities/transfert_entity.dart';

abstract class TransfertSubmissionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmitTransfertEvent extends TransfertSubmissionEvent {
  final TransfertEntity transfert;
  final bool forceUssd;

  SubmitTransfertEvent(this.transfert, {this.forceUssd = false});

  @override
  List<Object?> get props => [transfert, forceUssd];
}

class RetryPendingTransfertsEvent extends TransfertSubmissionEvent {}
