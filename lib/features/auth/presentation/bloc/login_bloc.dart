import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/commodity_entity.dart';
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
    on<CommodityChanged>(_onCommodityChanged);
  }

  Future<void> _onCommodityChanged(
    CommodityChanged event,
    Emitter<LoginState> emit,
  ) async {
    final currentState = state;
    if (currentState is LoginSuccess) {
      await loginUseCase.repository.setSelectedCommodity(event.commodityCode);

      // Resolve NEW active campaign
      final campaignResult = await loginUseCase.repository.getActiveCampaign();
      String campagne = '2025-2026';

      campaignResult.fold((failure) => null, (campaign) {
        if (campaign != null) {
          campagne = campaign.code;
        }
      });

      // Refresh state with new campaign
      emit(
        LoginSuccess(
          user: currentState.user,
          activeRegion: currentState.activeRegion,
          campagne: campagne,
          commodities: currentState.commodities,
        ),
      );
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    final result = await loginUseCase(
      LoginParams(username: event.username, password: event.password),
    );

    await result.fold(
      (failure) async => emit(LoginFailure(message: failure.message)),
      (user) async {
        // Save Active Region
        log("Region: ${event.region}");
        log("user place of work: ${user.placeOfWork}");

        String? activeRegion = event.region;
        if (activeRegion == null || activeRegion.isEmpty) {
          activeRegion = user.placeOfWork;
        }

        if (activeRegion != null && activeRegion.isNotEmpty) {
          await loginUseCase.repository.saveActiveRegion(activeRegion);
        }

        log("--------------- save region ok -----------------");
        // --- Dynamic Data Sync ---
        // Fetch commodities and open campaigns
        // final commoditiesResult = await loginUseCase.repository
        //     .fetchAndStoreCommodities();
        // await loginUseCase.repository.fetchAndStoreOpenCampaigns();

        log("--------------- fetch commodities ok -----------------");

        // List<CommodityEntity> commodities = [];
        // commoditiesResult.fold((f) => null, (list) => commodities = list);

        // Resolve active campaign based on selected commodity (default: ANACARDE)
        final campaignResult = await loginUseCase.repository
            .getActiveCampaign();
        String campagne = '2025-2026'; // Default fallback

        log("--------------- campaignResult ok -----------------");

        campaignResult.fold(
          (failure) =>
              log("Failed to get dynamic campaign: ${failure.message}"),
          (campaign) {
            if (campaign != null) {
              campagne = campaign.code;
            }
          },
        );

        emit(
          LoginSuccess(
            user: user,
            activeRegion: activeRegion ?? '',
            campagne: campagne,
            // commodities: commodities,
          ),
        );
      },
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<LoginState> emit,
  ) async {
    final result = await checkAuthUseCase(NoParams());
    await result.fold((failure) async => emit(LoginInitial()), (user) async {
      if (user != null) {
        final activeRegion = await checkAuthUseCase.repository
            .getActiveRegion();

        // Ensure dynamic data is synced
        // final commoditiesResult = await checkAuthUseCase.repository
        //     .fetchAndStoreCommodities();
        // await checkAuthUseCase.repository.fetchAndStoreOpenCampaigns();

        // List<CommodityEntity> commodities = [];
        // commoditiesResult.fold((f) => null, (list) => commodities = list);

        // Resolve active campaign
        final campaignResult = await checkAuthUseCase.repository
            .getActiveCampaign();
        String campagne = '2025-2026';

        campaignResult.fold((failure) => null, (campaign) {
          if (campaign != null) {
            campagne = campaign.code;
          }
        });

        emit(
          LoginSuccess(
            user: user,
            activeRegion: activeRegion ?? user.placeOfWork ?? '',
            campagne: campagne,
            // commodities: commodities,
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
