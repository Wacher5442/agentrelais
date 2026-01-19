import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agent_relais/features/transfert/data/datasources/local/transfert_local_datasource.dart';

// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object> get props => [];
}

class LoadHomeStats extends HomeEvent {}

// State
class HomeState extends Equatable {
  final int addedCount;
  final int syncedCount;
  final bool isLoading;

  const HomeState({
    this.addedCount = 0,
    this.syncedCount = 0,
    this.isLoading = false,
  });

  HomeState copyWith({int? addedCount, int? syncedCount, bool? isLoading}) {
    return HomeState(
      addedCount: addedCount ?? this.addedCount,
      syncedCount: syncedCount ?? this.syncedCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [addedCount, syncedCount, isLoading];
}

// Bloc
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final TransfertLocalDataSource localDataSource;

  HomeBloc({required this.localDataSource}) : super(const HomeState()) {
    on<LoadHomeStats>(_onLoadHomeStats);
  }

  Future<void> _onLoadHomeStats(
    LoadHomeStats event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      // "Fiches ajoutées" = Total transfers in local DB (or maybe excluding deleted?)
      // Let's assume all transfers for now.
      final total = await localDataSource.countTransfertsByStatus([]);

      // "Fiches synchronisées" = status 'synchronisé'
      final synced = await localDataSource.countTransfertsByStatus([
        'synchronisé',
      ]);

      emit(
        state.copyWith(
          addedCount: total,
          syncedCount: synced,
          isLoading: false,
        ),
      );
    } catch (e) {
      // Handle error silently or add error state
      emit(state.copyWith(isLoading: false));
    }
  }
}
