import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/check_auth_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthUseCase checkAuthUseCase;

  LoginBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.checkAuthUseCase,
  }) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    final result = await loginUseCase(
      LoginParams(username: event.username, password: event.password),
    );

    result.fold((failure) => emit(LoginFailure(message: failure.message)), (
      user,
    ) {
      // Save Active Region
      log("Region: ${event.region}");
      log("user place of work: ${user.placeOfWork}");

      String? activeRegion = event.region;
      if (activeRegion == null || activeRegion.isEmpty) {
        activeRegion = user.placeOfWork;
      }

      if (activeRegion != null && activeRegion.isNotEmpty) {
        loginUseCase.repository.saveActiveRegion(activeRegion);
      }

      emit(LoginSuccess(user: user, activeRegion: activeRegion ?? ''));
    });
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<LoginState> emit,
  ) async {
    final result = await checkAuthUseCase(NoParams());
    result.fold((failure) => emit(LoginInitial()), (user) async {
      if (user != null) {
        final activeRegion = await checkAuthUseCase.repository
            .getActiveRegion();
        emit(
          LoginSuccess(
            user: user,
            activeRegion: activeRegion ?? user.placeOfWork ?? '',
          ),
        );
      } else {
        emit(LoginInitial());
      }
    });
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<LoginState> emit,
  ) async {
    await logoutUseCase(NoParams());
    emit(LoginInitial());
  }
}
