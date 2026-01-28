part of 'acheteur_home_bloc.dart';

abstract class AcheteurHomeEvent extends Equatable {
  const AcheteurHomeEvent();
  @override
  List<Object?> get props => [];
}

/// Événement pour charger (ou recharger) les données
class AcheteurHomeDataFetched extends AcheteurHomeEvent {
  final String? search;
  final String? filter;

  const AcheteurHomeDataFetched({this.search, this.filter});

  @override
  List<Object?> get props => [search, filter];
}
