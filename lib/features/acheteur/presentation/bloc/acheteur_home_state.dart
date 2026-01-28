part of 'acheteur_home_bloc.dart';

abstract class AcheteurHomeState extends Equatable {
  const AcheteurHomeState();
  @override
  List<Object> get props => [];
}

/// État initial
class AcheteurHomeInitial extends AcheteurHomeState {}

/// État de chargement
class HomeLoading extends AcheteurHomeState {}

/// État de succès
class HomeLoaded extends AcheteurHomeState {
  final HomeData homeData;
  const HomeLoaded(this.homeData);
  @override
  List<Object> get props => [homeData];
}

/// État d'erreur
class HomeError extends AcheteurHomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object> get props => [message];
}
