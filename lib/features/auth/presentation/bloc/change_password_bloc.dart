import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/change_password_usecase.dart';

part 'change_password_event.dart';
part 'change_password_state.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final ChangePasswordUseCase changePasswordUseCase;

  ChangePasswordBloc({required this.changePasswordUseCase})
    : super(ChangePasswordInitial()) {
    on<ChangePasswordSubmitted>(_onChangePasswordSubmitted);
  }

  Future<void> _onChangePasswordSubmitted(
    ChangePasswordSubmitted event,
    Emitter<ChangePasswordState> emit,
  ) async {
    emit(ChangePasswordLoading());
    final result = await changePasswordUseCase(
      ChangePasswordParams(
        userId: event.userId,
        newPassword: event.newPassword,
      ),
    );

    result.fold(
      (failure) => emit(ChangePasswordFailure(message: failure.message)),
      (_) => emit(ChangePasswordSuccess()),
    );
  }
}
