import 'package:equatable/equatable.dart';

import '../../domain/repositories/transfert_repository.dart';

abstract class TransfertSubmissionState extends Equatable {
  @override
  List<Object?> get props => [];
}

// États initiaux et de soumission
class TransfertInitial extends TransfertSubmissionState {}

class TransfertSubmitting extends TransfertSubmissionState {}

class TransfertSubmissionSuccess extends TransfertSubmissionState {
  final SubmissionResult result;
  TransfertSubmissionSuccess(this.result);
  @override
  List<Object?> get props => [result];
}

class TransfertSubmissionFailure extends TransfertSubmissionState {
  final String message;
  TransfertSubmissionFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// États pour la synchronisation (Retry)
class TransfertSyncInProgress extends TransfertSubmissionState {}

class TransfertSyncSuccess extends TransfertSubmissionState {
  final int syncedCount;
  TransfertSyncSuccess(this.syncedCount);
  @override
  List<Object?> get props => [syncedCount];
}

class TransfertSyncFailure extends TransfertSubmissionState {
  final String message;
  TransfertSyncFailure(this.message);
  @override
  List<Object?> get props => [message];
}
