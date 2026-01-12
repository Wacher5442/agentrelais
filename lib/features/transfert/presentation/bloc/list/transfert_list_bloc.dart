import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/usecase.dart';
import '../../../domain/entities/transfert_entity.dart';
import '../../../domain/usecases/get_transferts_usecase.dart';

// Events
abstract class TransfertListEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadTransfertsEvent extends TransfertListEvent {}

// States
abstract class TransfertListState extends Equatable {
  @override
  List<Object> get props => [];
}

class TransfertListInitial extends TransfertListState {}

class TransfertListLoading extends TransfertListState {}

class TransfertListLoaded extends TransfertListState {
  final List<TransfertEntity> transferts;
  TransfertListLoaded(this.transferts);

  @override
  List<Object> get props => [transferts];
}

class TransfertListError extends TransfertListState {
  final String message;
  TransfertListError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class TransfertListBloc extends Bloc<TransfertListEvent, TransfertListState> {
  final GetTransfertsUseCase getTransfertsUseCase;

  TransfertListBloc({required this.getTransfertsUseCase})
    : super(TransfertListInitial()) {
    on<LoadTransfertsEvent>(_onLoadTransferts);
  }

  Future<void> _onLoadTransferts(
    LoadTransfertsEvent event,
    Emitter<TransfertListState> emit,
  ) async {
    emit(TransfertListLoading());
    final result = await getTransfertsUseCase(NoParams());

    result.fold(
      (failure) => emit(TransfertListError(failure.message)),
      (data) => emit(TransfertListLoaded(data)),
    );
  }
}
