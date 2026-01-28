import 'package:agent_relais/features/acheteur/domain/usecases/get_home_data_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'acheteur_event_home.dart';
part 'acheteur_home_state.dart';

class AcheteurHomeBloc extends Bloc<AcheteurHomeEvent, AcheteurHomeState> {
  final GetHomeDataUseCase getHomeDataUseCase;

  AcheteurHomeBloc({required this.getHomeDataUseCase})
    : super(AcheteurHomeInitial()) {
    on<AcheteurHomeDataFetched>(_onHomeDataFetched);
  }

  Future<void> _onHomeDataFetched(
    AcheteurHomeDataFetched event,
    Emitter<AcheteurHomeState> emit,
  ) async {
    emit(HomeLoading());
    final result = await getHomeDataUseCase(
      HomeDataParams(search: event.search, filter: event.filter),
    );

    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (homeData) => emit(HomeLoaded(homeData)),
    );
  }
}
