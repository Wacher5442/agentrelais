part of 'acheteur_home_bloc.dart';

abstract class AcheteurHomeState extends Equatable {
  const AcheteurHomeState();
  @override
  List<Object> get props => [];
}

class AcheteurHomeInitial extends AcheteurHomeState {}

class HomeLoading extends AcheteurHomeState {}

class HomeLoaded extends AcheteurHomeState {
  final HomeData homeData;
  const HomeLoaded(this.homeData);
  @override
  List<Object> get props => [homeData];
}

class HomeError extends AcheteurHomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object> get props => [message];
}
